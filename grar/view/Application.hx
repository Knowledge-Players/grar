package grar.view;

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
}

/**
* Main view
**/
class Application {

	public function new(root: IFrameElement, ?mobile: Bool = false)
	{
		this.root = root;
		document = root.contentDocument;
		isMobile = mobile;

		menus = new Map();
		for(m in document.getElementsByClassName("menu")){
			var menu: Element = null;
			if(m.nodeType == Node.ELEMENT_NODE)
				menu = cast m;
			else
				continue;

			var display = new MenuDisplay(this);

			// Parser
			display.markupParser = new TextDownParser();

			display.ref = menu.id;
			menus[menu.id] = display;
		}
		for(pb in document.getElementsByClassName("progressbar")){
			var bar: Element = null;
			if(pb.nodeType == Node.ELEMENT_NODE)
				bar = cast pb;
			else
				continue;

			bar.style.width = "0";
		}

		// Wrap different fullscreen APIs
		fullscreenApi = {requestFullscreen: null, onFullscreenError: null, fullscreenElement: null, exitFullscreen: null, onFullscreenChange: null};

		fullscreenApi.onFullscreenError = function(){
			trace("Unable to go fullscreen");
		}

		fullscreenApi.onFullscreenChange = function(){
			trace("Going fullscreen! Or not...");
			isFullscreen = !isFullscreen;
			document.body.classList.toggle("fullscreenOn", isFullscreen);
			if(!isFullscreen)
				partDisplay.removeFullscreenState();
		}

		untyped __js__("if (this.root.mozRequestFullScreen){
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
			else{
				this.fullscreenApi.requestFullscreen = function() {root.requestFullscreen();};
				this.fullscreenApi.exitFullscreen = function() {document.exitFullscreen();};
				this.fullscreenApi.fullscreenElement = document.fullscreenElement;
				document.onfullscreenchange = this.fullscreenApi.onFullscreenChange;
				root.onfullscreenerror = this.fullscreenApi.onFullscreenError;
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

	public var isFullscreen (get, null):Bool = false;

	var root: IFrameElement;
	var fullscreenApi: FullscreenAPI;

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
		// Update module name
		for(p in document.getElementsByClassName("chapterName"))
			p.getElement().innerHTML = chapterName;
		// Update module type
		for(p in document.getElementsByClassName("activityName"))
			p.getElement().innerHTML = activityName;
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
		if(container == null){
			trace("Unable to find part container '"+ref+"'.");
			return;
		}
		if(!noReload && templateUri != null){
			var partRoot = document.createIFrameElement();
			partRoot.setAttribute("seamless", "true");
			partRoot.setAttribute("allowfullscreen", "true");
			// Attribute for Safari
			partRoot.setAttribute("webkitallowfullscreen", "true");
			partRoot.src = templateUri;

			// Wait for template to load
			partRoot.onload = function(_){
				partDisplay.init(partRoot);
				// Setup transition between parts
				if(container.childNodes.length > 1){
					var listener = null;
					listener = function(_){
						container.removeEventListener('transitionend', listener);
						container.removeEventListener('webkitTransitionEnd', listener);
						if(forward){
							container.style.transition = "none";
							// Remove old iframe (= previous part display)
							container.removeChild(container.firstChild);
							container.classList.remove("nextTransition");
						}
						else{
							// Remove old iframe (= previous part display)
							container.removeChild(container.lastChild);

							container.style.left = "";
							container.classList.remove("previousTransition");
						}
						onPartLoaded();
					}
					container.addEventListener("transitionend",listener);
					container.addEventListener("webkitTransitionEnd",listener);

					if(forward){
						container.style.transition = "";
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
								container.classList.add("previousTransition");
							}
							return true;
						};
						root.contentWindow.requestAnimationFrame(update);
					}
				}
				else
					onPartLoaded();

				// If header state need to be updated
				for(child in partRoot.contentDocument.body.children){
					var childElement = child.getElement();
					if(childElement.hasAttribute("data-header-state")){
						var headers = document.getElementsByTagName("header");
						var newHeader = headers[0].cloneNode(true);
						newHeader.getElement().classList.remove("hidden");
						partRoot.contentDocument.body.insertBefore(newHeader, partRoot.contentDocument.body.childNodes[0]);

						// Update header
						for(h in partRoot.contentDocument.getElementsByTagName("header"))
							h.getElement().classList.add(childElement.getAttribute("data-header-state"));

						break;
					}
				}
			}
			if(forward || !container.hasChildNodes())
				container.appendChild(partRoot);
			else{
				container.insertBefore(partRoot, container.childNodes[0]);
				container.style.left = "-100%";
			}
		}
		else{
			partDisplay.init();
			onPartLoaded();
		}
	}

	public function requestFullscreen():Void
	{
		document.body.classList.add("fullscreenOn");
		fullscreenApi.requestFullscreen();
	}

	public function exitFullscreen():Void
	{
		fullscreenApi.exitFullscreen();
	}

	public function initMenu(ref: String, levels: Array<LevelData>) : Void
	{
		var templates = new Map<String, Element>();
		var root = document.getElementById(ref);

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
			var t = document.getElementById(ref+"_"+l.name);
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
				for(elem in menus[ref].markupParser.parse(l.partName))
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
					sublist = document.createUListElement();
					newLevel.appendChild(sublist);
				}

				for(i in l.items){
					var st = document.getElementById(ref+"_"+i.name);
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
						for(elem in menus[ref].markupParser.parse(i.partName))
							name += elem.innerHTML;
						name += "</a>";
						newSubLevel.innerHTML = "<a href='#'>"+name+"</a>";
						newSubLevel.id = ref+"_"+i.id;
						newSubLevel.classList.add(i.icon);
						if(!hasProgress)
							newSubLevel.onclick = function(_) onMenuClicked(i.id, ref);
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
		var appURI = root.baseURI.substr(0, root.baseURI.lastIndexOf("/"));
		var prefix: String = null;
		var base = rootElement.baseURI.replace(appURI, "");
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
}