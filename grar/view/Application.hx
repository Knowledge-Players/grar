package grar.view;

import grar.model.Config;
import js.html.Audio;
import js.html.Document;
import js.html.IFrameElement;
import js.html.UListElement;
import js.html.Element;
import js.html.Node;

import grar.model.contextual.MenuData;

import grar.util.TextDownParser;

import grar.view.contextual.MenuDisplay;
import grar.view.part.PartDisplay;

using StringTools;
using grar.util.HTMLTools;

// See if really need it
enum ContextualType {

	MENU;
	NOTEBOOK;
	INVENTORY;
}

/**
* Wrapper for crossbrowser fullscreen API
**/
typedef FullscreenAPI = {
	dynamic function requestFullscreen(): Void;
	dynamic function onFullscreenError(): Void;
	dynamic function exitFullscreen(): Void;
	dynamic function onFullscreenChange(): Void;
	var fullscreenElement: Element;
	var available: Bool;
}

/**
* Main view
**/
class Application {

	public function new(root: IFrameElement, config: Config)
	{
		this.root = root;
		document = root.contentDocument;
		this.config = config;
		isMobile = config.isMobile;

		menus = new Map();
		parser = new TextDownParser();

		findMenus(document);

		for(pb in document.getElementsByClassName("progressbar")){
			var bar: Element = null;
			if(pb.nodeType == Node.ELEMENT_NODE)
				bar = cast pb;
			else
				continue;

			bar.style.width = "0";
		}

		// Wrap different fullscreen APIs
		fullscreenApi = {requestFullscreen: null, onFullscreenError: null, fullscreenElement: null, exitFullscreen: null, onFullscreenChange: null, available: true};

		fullscreenApi.onFullscreenError = function(){
			trace("Unable to go fullscreen");
		}

		fullscreenApi.onFullscreenChange = function(){
			toggleFullscreen();
		}

		untyped __js__("
			if (this.root.mozRequestFullScreen){
				this.fullscreenApi.requestFullscreen = function() {root.mozRequestFullScreen();};
				this.fullscreenApi.exitFullscreen = function() {document.mozCancelFullScreen();};
				this.fullscreenApi.fullscreenElement = document.mozFullScreenElement;
				root.onmozfullscreenerror = this.fullscreenApi.onFullscreenError;
				document.onmozfullscreenchange = this.fullscreenApi.onFullscreenChange;
			}
			else if (this.root.webkitRequestFullscreen){
				this.fullscreenApi.requestFullscreen = function() {root.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);};
				this.fullscreenApi.exitFullscreen = function() {document.webkitExitFullscreen();};
				this.fullscreenApi.fullscreenElement = document.webkitFullscreenElement;
				document.onwebkitfullscreenchange = this.fullscreenApi.onFullscreenChange;
				root.onwebkitfullscreenerror = this.fullscreenApi.onFullscreenError;
			}
			else if (this.root.msRequestFullscreen){
				this.fullscreenApi.requestFullscreen = function() {root.msRequestFullscreen();};
				this.fullscreenApi.exitFullscreen = function() {document.msExitFullscreen();};
				this.fullscreenApi.fullscreenElement = document.msFullscreenElement;
				document.onmsfullscreenchange = this.fullscreenApi.onFullscreenChange;
				root.onmsfullscreenerror = this.fullscreenApi.onFullscreenError;
			}
			else if(this.root.requestFullscreen){
				this.fullscreenApi.requestFullscreen = function() {root.requestFullscreen();};
				this.fullscreenApi.exitFullscreen = function() {document.exitFullscreen();};
				this.fullscreenApi.fullscreenElement = document.fullscreenElement;
				document.onfullscreenchange = this.fullscreenApi.onFullscreenChange;
				root.onfullscreenerror = this.fullscreenApi.onFullscreenError;
			}
			else{
				this.fullscreenApi.requestFullscreen = function() {console.log('No support for FullscreenAPI.')};
				this.fullscreenApi.exitFullscreen = function() {console.log('No support for FullscreenAPI.')};
				this.fullscreenApi.fullscreenElement = null;
				document.onfullscreenchange = function() {console.log('No support for FullscreenAPI.')};
				root.onfullscreenerror = function() {console.log('No support for FullscreenAPI.')};
				this.fullscreenApi.available = false;
			}");

		initSounds(document.body);
	}

	public var menuData (default, set) : Null<MenuData>;

	public var tokensImages (default, set) : Null<Map<String, { small : String, large : String }>>;

	public var tokenNotification (default, default) : Null<String>;

	/**
	* General volume of this application
	**/
	public var masterVolume (default, set): Float = 1;

	/**
	* Map of the menu views
	**/
	public var menus (default, null):Map<String, MenuDisplay>;

	/**
	* Current view of part
	**/
	public var partDisplay (get, null):PartDisplay;

	/**
	* Root document element of this application. Generally the document of the iFrame
	**/
	public var document(default, null): Document;

	/**
	* Is the module on a mobile?
	**/
	public var isMobile (default, null): Bool;

	/**
	* Theme of the module
	**/
	public var theme (default, set):Null<String>;

	/**
	* Is the application on fullscreen. Default is false
	**/
	public var isFullscreen (get, null):Bool = false;

	/**
	* The element currently in fullscreen
	**/
	public var fullscreenElement (get, null):Element;

	var root: IFrameElement;
	var fullscreenApi: FullscreenAPI;
	var parser: TextDownParser;
	var config: Config;

	///
	// GETTER / SETTER
	//

	private function set_menuData(v : Null<MenuData>) : Null<MenuData> {

		if (v == menuData)
			return menuData;

		menuData = v;
		onMenuDataChanged();

		return menuData;
	}

	private function set_tokensImages(v : Null<Map<String, {small:String,large:String}>>) : Null<Map<String, {small:String,large:String}>> {

		if (v == tokensImages) {

			return tokensImages;
		}
		tokensImages = v;

		return tokensImages;
	}

	private function get_partDisplay():PartDisplay
	{
		if(partDisplay == null)
			partDisplay = new PartDisplay(this, isMobile);
		return partDisplay;
	}

	private function set_masterVolume(vol:Float):Float
	{
		masterVolume = vol;
		onMasterVolumeChanged();
		return masterVolume;
	}

	private function get_isFullscreen():Bool
	{
		return isFullscreen;
	}

	private function set_theme(theme:String):String
	{
		return this.theme = theme;
	}

	private function get_fullscreenElement():Element
	{
		return fullscreenApi.fullscreenElement;
	}

	///
	// CALLBACKS
	//

	public dynamic function onMenuClicked(partId : String, menuId: String) : Void { }

	public dynamic function onMenuDataChanged() : Void { }

	public dynamic function onMasterVolumeChanged(): Void {}

	public dynamic function onPartLoaded() : Void { }


	///
	// API
	//

	public function updateModuleInfos(name:String, type:String, theme:String):Void
	{
		// Update module name
		for(p in document.getElementsByClassName("moduleName"))
			p.getElement().innerHTML = name;
		// Update module type
		for(p in document.getElementsByClassName("moduleType"))
			p.getElement().innerHTML = type;
			// Update module theme
		for(p in document.getElementsByClassName("moduleTheme"))
			p.getElement().innerHTML = theme;
	}

	public function updateChapterInfos(chapterName:String, activityName:String):Void
	{
		var html: String = "";
		// Update module name
		for(elem in parser.parse(chapterName))
			html += elem.innerHTML;
		for(p in document.getElementsByClassName("chapterName"))
			p.getElement().innerHTML = html;
		// Update module type
		html = "";
		for(elem in parser.parse(activityName))
			html += elem.innerHTML;
		for(p in document.getElementsByClassName("activityName"))
			p.getElement().innerHTML = html;

		var frames = document.getElementsByTagName("iframe");
		var iframe: IFrameElement = cast frames[frames.length-1];
		for(p in iframe.contentDocument.getElementsByClassName("activityName"))
			p.getElement().innerHTML = html;
	}

	/**
	* Initialize a part view
	* @param    ref: Reference to the HTML root of the view
	* @param    templateUri: HTML template to load in an iframe. If null, old template is kept
	* @param    forward: True if you're progressing forward in the module. Default is true.
	* @param    noReload: Prevent reloading a new view. Default is false.
	**/
	public function initPart(ref:String, ?templateUri: String, ?forward: Bool = true, ?noReload: Bool = false):Void
	{
		var container = document.getElementById(ref);
		if(!noReload && templateUri != null){
			if(container == null){
				throw "Unable to find part container '"+ref+"'.";
				return;
			}
			var partRoot = document.createIFrameElement();
			partRoot.setAttribute("seamless", "true");
			partRoot.setAttribute("allowfullscreen", "true");
			// Attribute for Safari
			partRoot.setAttribute("webkitallowfullscreen", "true");
			partRoot.src = templateUri;

			// Wait for template to load
			partRoot.onload = function(_){
				if(config.userAgentName == Navigator.IE)
					partRoot.contentDocument.body.classList.add("ie");

				partDisplay.init(partRoot);

				setHeadersState(partRoot.contentDocument.body);
				for(md in findMenus(partRoot.contentDocument)){
					initMenu(md, menuData.levels);
					md.setTitle(menuData.title);
				}

				// Transition
				var customTransition = partRoot.contentDocument.body.hasAttribute("data-transition") ? partRoot.contentDocument.body.getAttribute("data-transition") : null;
				// Setup transition between parts
				if(container.childNodes.length > 1){
					// 10s timeout
					var maxTime = 10000;
					#if (js || flash || flash8 || java)
					var timeOut = new haxe.Timer(maxTime);
					timeOut.run = function(){
						timeOut.stop();
						throw "Time Out! Nothing happened for "+(maxTime/1000)+"s. Verify your CSS transition.";
					}
					#end

					var listener = null;
					listener = function(_){
						#if (js || flash || flash8 || java)
						timeOut.stop();
						#end
						container.removeEventListener('transitionend', listener);
						container.removeEventListener('webkitTransitionEnd', listener);
						if(forward){
							container.style.transition = "none";
							// Remove old iframe (= previous part display)
							//container.removeChild(container.firstChild);
							/*if(customTransition != null)
								container.classList.remove("next"+customTransition);
							else
								container.classList.remove("nextTransition");*/
						}
						else{
							// Remove old iframe (= previous part display)
							container.removeChild(container.lastChild);

							container.style.left = "";
							/*if(customTransition != null)
								container.classList.remove("previous"+customTransition);
							else
								container.classList.remove("previousTransition");*/
						}
						onPartLoaded();
					}
					container.addEventListener("transitionend",listener);
					container.addEventListener("webkitTransitionEnd",listener);

					/*if(forward){
						container.style.transition = "";
						if(customTransition != null)
							container.classList.add("next"+customTransition);
						else
							container.classList.add("nextTransition");
					}
					else{
						// Need to wait for next frame to see the animation
						var firstFrame = true;
						var update = null;
						update = function(_){
							if(firstFrame){
								firstFrame = false;
								root.contentWindow.requestAnimationFrame(update);
							}
							else{
								container.style.transition = "";
								if(customTransition != null)
									container.classList.add("previous"+customTransition);
								else
								container.classList.add("previousTransition");
							}
							return true;
						};
						root.contentWindow.requestAnimationFrame(update);
					}*/
					sendNewPartHook();
				}
				else
					onPartLoaded();
			}
			if(forward || !container.hasChildNodes())
				container.appendChild(partRoot);
			else{
				container.insertBefore(partRoot, container.childNodes[0]);
				container.style.left = "-100%";
			}
		}
		else{
			partDisplay.init(ref);
			if(container == null){
				var iframe: IFrameElement = cast document.getElementsByTagName("iframe")[0];
				setHeadersState(iframe.contentDocument.getElementById(ref));
			}
			else
				setHeadersState(container);
			onPartLoaded();
		}
	}

	public function requestFullscreen():Void
	{
		document.body.classList.add("fullscreenOn");
		if(fullscreenApi.available)
			fullscreenApi.requestFullscreen();
		else
			toggleFullscreen();
	}

	public function exitFullscreen():Void
	{
		if(fullscreenApi.available)
			fullscreenApi.exitFullscreen();
		else
			toggleFullscreen();
	}

	public function initMenu(display: MenuDisplay, levels: Array<LevelData>) : Void
	{
		var templates = new Map<String, Element>();
		var root = display.root;

		var hasProgress = false;
		var offset = 0.0;
		var previousLeft = 0.0;
		if(root.hasAttribute("data-menu-type") && root.getAttribute("data-menu-type").toLowerCase() == "progressbar"){
			hasProgress = true;
			// Count all item number
			var nbItem = 0;
			for(l in levels){
				if(l.items != null)
					for(i in l.items)
						nbItem++;
			}
			offset = 100/nbItem;
			previousLeft = offset/2;
		}

		var itemNum = 1;
		for(l in levels){
			var t = display.document.getElementById(display.ref+"_"+l.name);
			var newLevel: Element = null;
			if(t != null){
				//root.appendChild(t.parentNode);
				templates[l.name] = t;
                //use of Std.instance
                var node = t.cloneNode(true);
				newLevel = cast node;
				t.parentNode.appendChild(newLevel);
				// Set part name
				var name = "";
				for(elem in display.markupParser.parse(l.partName))
					name += elem.innerHTML;
				for(node in newLevel.getElementsByClassName("numbering"))
					node.getElement().innerHTML = itemNum < 10 ? '0'+ itemNum : Std.string(itemNum);
				newLevel.innerHTML += name;
				newLevel.removeAttribute("id");
			}

			// TODO recursive function for unlimited sub levels
			// Sub list
			if(l.items != null){
				var sublist: UListElement = null;
				if(newLevel != null){
					sublist = display.document.createUListElement();
					newLevel.appendChild(sublist);
				}

				for(i in l.items){
					var st = display.document.getElementById(display.ref+"_"+i.name);
					if(st != null){
						templates[i.name] = st;
						var newSubLevel: Element = cast st.cloneNode(true);
						if(sublist != null)
							sublist.appendChild(newSubLevel);
						else if(st != null)
							st.parentNode.appendChild(newSubLevel);
						else
							root.appendChild(newSubLevel);

						// Set subpart name
						var name = "";
						for(elem in display.markupParser.parse(i.partName))
							name += elem.innerHTML;
						name += "</a>";
						newSubLevel.innerHTML += "<a>"+name+"</a>";
						newSubLevel.id = display.ref+"_"+i.id;
						newSubLevel.classList.add(i.icon);
						if(!hasProgress)
							newSubLevel.onclick = function(_) onMenuClicked(i.id, display.ref);
						if(hasProgress){
							newSubLevel.style.left = previousLeft+'%';
							previousLeft += offset;
						}
					}
				}
			}
			itemNum++;
		}

		for(t in templates)
			t.parentNode.removeChild(t);
	}

	/**
    * Activate a token of the inventory
    * @param    tokenName : Name of the token to activate
    **/
	public function setActivateToken(t : grar.model.InventoryToken) : Void {

		if (tokenNotification != null) {

			// TODO show notification div
			//currentLayout.zones.get(mainLayoutRef).addChild(tokenNotification);

			// TODO set src attr
			//tokenNotification.setToken(t.name, t.icon);
		}
		// TODO Notebook controller ?
		//notebook.setActivateToken(t);
	}

	public function getElementById(id:String):Element
	{
		return document.getElementById(id);
	}

	/**
	* Initialize UI sounds in the given element
	* @param    rootElement: Parent element whom children will be initialized
	**/
	public function initSounds(rootElement: Element):Void
	{
		// Calculate relative url
		var baseURI: String;
		var iframeURI: String;
		if(root.baseURI != null){
			baseURI = root.baseURI;
			iframeURI = rootElement.baseURI;
		}
		// IE fix
		else{
			baseURI = document.referrer;
			iframeURI = untyped __js__("this.document.URL");
		}

		var appURI = baseURI.substr(0, baseURI.lastIndexOf("/"));
		var prefix: String = null;
		var base = iframeURI.replace(appURI, "");
		prefix = base.substr(1, base.lastIndexOf("/"));

		var play = function(soundUrl: String){
			var audio = new Audio();
			audio.src = prefix+soundUrl;
			audio.volume = masterVolume;
			audio.play();
		};

		// Hover SFX
		var hovers = rootElement.querySelectorAll("[data-sound-hover]");
		for(h in hovers){
			var elem = h.getElement();
			elem.onmouseover = function(_) play(elem.getAttribute("data-sound-hover"));
		}

		// Click SFX
		var clicks = rootElement.querySelectorAll("[data-sound-click]");
		for(c in clicks){
			var elem = c.getElement();
			elem.onclick = function(_) play(elem.getAttribute("data-sound-click"));
		}
	}

	// HOOKS

	public dynamic function sendReadyHook():Void
	{
	}

	public dynamic function sendNewPartHook():Void
	{
	}

	public dynamic function sendFullscreenHook(): Void {}

	///
	// Internals
	//

	private function toggleFullscreen():Void
	{
		isFullscreen = !isFullscreen;
		document.body.classList.toggle("fullscreenOn", isFullscreen);
		if(!isFullscreen)
			partDisplay.removeFullscreenState();
		sendFullscreenHook();
	}

	private function setHeadersState(partRoot: Element):Void
	{
		if(partRoot == null)
			return;

		// If header state need to be updated
		if(doUpdateHeadersIN(partRoot) == null){
			var newHeader = null;
			var i = 0;
			while(i < partRoot.children.length && newHeader == null){
				var childElement = partRoot.children[i].getElement();
				newHeader = doUpdateHeadersIN(childElement);
				i++;
			}
		}


		// Update theme if any
		if(theme != null){
			partRoot.classList.add(theme);
			root.contentDocument.body.classList.add(theme);
		}
	}

	private function doUpdateHeadersIN(elem:Element):Element
	{
		var newHeader: Element = null;
		if(elem.hasAttribute("data-header-state")){
			var headers = document.getElementsByTagName("header");
			newHeader = headers[0].cloneNode(true).getElement();
			newHeader.classList.remove("hidden");

			// Update header
			for(h in elem.ownerDocument.getElementsByTagName("header"))
				h.parentNode.removeChild(h);

			newHeader.classList.add(elem.getAttribute("data-header-state"));
			elem.parentElement.insertBefore(newHeader, elem.parentElement.childNodes[0]);
		}

		return newHeader;
	}

	private function findMenus(doc:Document):Array<MenuDisplay>
	{
		var a = [];
		for(m in doc.getElementsByClassName("menu")){
			var menu: Element = null;
			if(m.nodeType == Node.ELEMENT_NODE)
				menu = cast m;
			else
				continue;

			var display = new MenuDisplay(this, doc);

			// Parser
			display.markupParser = parser;

			display.ref = menu.id;
			menus[menu.id] = display;
			a.push(display);
		}
		return a;
	}
}