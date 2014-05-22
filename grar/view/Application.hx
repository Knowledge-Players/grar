package grar.view;

import js.Browser;
import js.html.UListElement;
import js.html.Element;
import js.html.Node;

import grar.model.contextual.MenuData;
import grar.model.localization.LocaleData;

import grar.view.style.TextDownParser;
import grar.view.contextual.MenuDisplay;
import grar.view.part.PartDisplay;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

// See if really need it
enum ContextualType {

	MENU;
	NOTEBOOK;
}

/**
* Main view
**/
class Application {

	public function new() {

		// note: if we were to support multi instances with GRAR,
		// we should pass here the targetted API's root element of
		// the GRAR instance.

		this.callbacks = {

				onQuitGameRequest: function(){ this.onQuitGameRequest(); },
				onSoundToLoad: function(sndUri:String){ loadSound(sndUri); },
				onSoundToPlay: function(sndUri:String){ playSound(sndUri); },
				onSoundToStop: function(){ stopSound(); },
				onActivateTokenRequest: function(tid : String){ onActivateTokenRequest(tid); }
			};

		menus = new Map();
		for(m in js.Browser.document.getElementsByClassName("menu")){
			var menu: Element = null;
			if(m.nodeType == Node.ELEMENT_NODE)
				menu = cast m;
			else
				continue;

			var display = new MenuDisplay();

			// Parser
			display.markupParser = new TextDownParser();

			display.ref = menu.id;
			menus[menu.id] = display;
		}
		for(pb in Browser.document.getElementsByClassName("progressbar")){
			var bar: Element = null;
			if(pb.nodeType == Node.ELEMENT_NODE)
				bar = cast pb;
			else
				continue;

			bar.style.width = "0";
		}
	}

	public var menuData (default, set) : Null<MenuData>;

	public var menus (default, null):Map<String, MenuDisplay>;

	public var defaultStyleSheetName : Null<String> = null;

	public var localeData : LocaleData;

	private var stashedLocale : GenericStack<LocaleData>;

	public var tokensImages (default, set) : Null<StringMap<{ small : String, large : String }>>;

	public var tokenNotification (default, default) : Null<String>;

	public var partDisplay (get, null):PartDisplay;

	// WIP

	var callbacks : grar.view.DisplayCallbacks;

	public var previousLayout : String = null;

	var startIndex:Int;

	public var mainLayoutRef (default, default) : Null<String> = null;

	private var nbVolume : Float = 1;


	///
	// GETTER / SETTER
	//

	public function set_menuData(v : Null<MenuData>) : Null<MenuData> {

		if (v == menuData) {

			return menuData;
		}
		menuData = v;

		onMenuDataChanged();

		return menuData;
	}

	public function set_tokensImages(v : Null<StringMap<{small:String,large:String}>>) : Null<StringMap<{small:String,large:String}>> {

		if (v == tokensImages) {

			return tokensImages;
		}
		tokensImages = v;

		onTokensImagesChanged();

		return tokensImages;
	}

	public function get_partDisplay():PartDisplay
	{
		if(partDisplay == null)
			partDisplay = new PartDisplay(callbacks);
		return partDisplay;
	}


	///
	// CALLBACKS
	//

	public dynamic function onMenuButtonStateRequest(partName : String) : { l : Bool, d : Bool } { return null; }

	public dynamic function onMenuClicked(partId : String, menuId: String) : Void { }

	public dynamic function onMenuAdded() : Void { }

	public dynamic function onExitPart(partId : String) : Void { }

	public dynamic function onTokenNotificationChanged() : Void { }

	public dynamic function onNotebookChanged() : Void { }

	public dynamic function onMenuChanged() : Void { }

	public dynamic function onMenuDataChanged() : Void { }

	public dynamic function onLayoutsChanged() : Void { }

	public dynamic function onTokensImagesChanged() : Void { }

	public dynamic function onStylesChanged() : Void { }

	public dynamic function onQuitGameRequest() : Void { }

	public dynamic function onActivateTokenRequest(tokenName : String) : Void { }

	public dynamic function onRestoreLocaleRequest() : Void { }

	public dynamic function onLocaleDataPathRequest(uri : String) : Void { }

	public dynamic function onInterfaceLocaleDataPathRequest() : Void { }

	public dynamic function onSetBookmarkRequest(partId : String) : Void { }

	public dynamic function onGameOverRequest() : Void { }

	public dynamic function onMenuUpdateDynamicFieldsRequest() : Void { }

	//public dynamic function onPartDisplayRequest(p : Part) : Void { }


	///
	// API
	//

	public function changeHeaderState(state : String) : Void {
		for(h in Browser.document.getElementsByTagName("header"))
			if(h.nodeType == Node.ELEMENT_NODE)
				// Override previous state
				cast(h, Element).className = state;
	}

	public function updateModuleInfos(name:String, type:String):Void
	{
		// Update module name
		for(p in Browser.document.getElementsByClassName("moduleName"))
			if(p.nodeType == Node.ELEMENT_NODE)
				cast(p, Element).innerHTML = name;
		// Update module type
		for(p in Browser.document.getElementsByClassName("moduleType"))
			if(p.nodeType == Node.ELEMENT_NODE)
				cast(p, Element).innerHTML = type;
	}

	public function updateChapterInfos(chapterName:String, activityName:String):Void
	{
		// Update module name
		for(p in Browser.document.getElementsByClassName("chapterName"))
			if(p.nodeType == Node.ELEMENT_NODE)
				cast(p, Element).innerHTML = chapterName;
		// Update module type
		for(p in Browser.document.getElementsByClassName("activityName"))
			if(p.nodeType == Node.ELEMENT_NODE)
				cast(p, Element).innerHTML = activityName;
	}

	public function initMenu(ref: String, levels: Array<LevelData>) : Void {
		var templates = new Map<String, Element>();

		var root = Browser.document.querySelector("#"+ref);


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
			var t = Browser.document.querySelector("#"+ref+"_"+l.name);
			var newLevel: Element = null;
			if(t != null){
				//root.appendChild(t.parentNode);
				templates[l.name] = t;
				newLevel = cast t.cloneNode(true);
				t.parentNode.appendChild(newLevel);
				// Set part name
				var name = "";
				for(elem in menus[ref].markupParser.parse(l.partName))
					name += elem.innerHTML;
				for(node in newLevel.querySelectorAll(".numbering"))
					if(node.nodeType == Node.ELEMENT_NODE)
						cast(node, Element).innerHTML = itemNum < 10 ? '0'+ itemNum : Std.string(itemNum);
				newLevel.innerHTML += name;
				newLevel.removeAttribute("id");
			}

			// TODO recursive function for unlimited sub levels
			// Sub list
			if(l.items != null){
				var sublist: UListElement = null;
				if(newLevel != null){
					sublist = Browser.document.createUListElement();
					newLevel.appendChild(sublist);
				}

				for(i in l.items){
					var st = Browser.document.querySelector("#"+ref+"_"+i.name);
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
						newSubLevel.id = i.id;
						newSubLevel.classList.add(i.icon);
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

	public function changeVolume(nb : Float = 0) : Void {

		nbVolume = nb;

		// TODO use sound
		/*if (itemSoundChannel != null) {

			var soundControl = itemSoundChannel.soundTransform;
			soundControl.volume = nbVolume;
			itemSoundChannel.soundTransform = soundControl;
		}*/
	}

	/**
	* Pre load a sound. Then use playSound with the same url to play it
	* @param soundUrl : Path to the sound file
	**/
	public function loadSound(soundUrl : String) : Void {

		// TODO use sound
		/*if (soundUrl != null && soundUrl != "") {

			var sound = new Sound(new flash.net.URLRequest(soundUrl));

			sounds.set(soundUrl, sound);
		}*/
	}

	/**
    * Play a sound. May cause error if the sound is not preloaded with loadSound()
    * @param soundUrl : Path to the sound file
    **/
	public function playSound(soundUrl : String) : Void {

		// TODO use sound
		/*if (soundUrl != null) {

			stopSound();

			if (!sounds.exists(soundUrl)) {

				loadSound(soundUrl);
			}
			itemSoundChannel = sounds.get(soundUrl).play();
		}*/
	}

	/**
	* Stop currently playing sound
	**/
	public function stopSound() : Void {
		// TODO use sound
		/*if (itemSoundChannel != null) {

			itemSoundChannel.stop();
		}*/
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
}