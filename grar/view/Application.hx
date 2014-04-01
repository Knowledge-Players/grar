package grar.view;

import grar.model.contextual.MenuData;
import grar.model.localization.LocaleData;

import grar.view.part.PartDisplay;
import grar.view.part.ActivityDisplay;
import grar.view.part.DialogDisplay;
import grar.view.part.StripDisplay;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

// See if really need it
enum ContextualType {

	MENU;
	NOTEBOOK;
}

class Application {

	public function new() {

		// note: if we were to support multi instances with GRAR,
		// we should pass here the targetted API's root element of
		// the GRAR instance.

		this.parts = new GenericStack<PartDisplay>();
		//this.sounds = new StringMap();

		this.callbacks = {

				onContextualDisplayRequest: function(c : ContextualType, ? ho : Bool = true){ this.displayContextual(c, ho); },
				onContextualHideRequest: function(c : ContextualType){ this.hideContextual(c); },
				onQuitGameRequest: function(){ this.onQuitGameRequest(); },
				onSoundToLoad: function(sndUri:String){ loadSound(sndUri); },
				onSoundToPlay: function(sndUri:String){ playSound(sndUri); },
				onSoundToStop: function(){ stopSound(); },
				onActivateTokenRequest: function(tid : String){ onActivateTokenRequest(tid); }
			};
	}

	public var menuData (default, set) : Null<MenuData>;

	public var defaultStyleSheetName : Null<String> = null;

	public var localeData : LocaleData;

	private var stashedLocale : GenericStack<LocaleData>;

	public var tokensImages (default, set) : Null<StringMap<{ small : String, large : String }>>;

	public var tokenNotification (default, default) : Null<String>;

	public var partDisplay (get, null):PartDisplay;

	// WIP

	var callbacks : grar.view.DisplayCallbacks;

	public var previousLayout : String = null;

	var parts : GenericStack<PartDisplay>;

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

	public dynamic function onMenuClicked(partId : String) : Void { }

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

	public dynamic function onLocalizedContentRequest(k : String) : String { return null; }

	public dynamic function onLocaleDataPathRequest(uri : String) : Void { }

	public dynamic function onInterfaceLocaleDataPathRequest() : Void { }

	public dynamic function onSetBookmarkRequest(partId : String) : Void { }

	public dynamic function onGameOverRequest() : Void { }

	public dynamic function onMenuUpdateDynamicFieldsRequest() : Void { }

	//public dynamic function onPartDisplayRequest(p : Part) : Void { }


	///
	// API
	//

	public function changeLayout(l : String) : Void {

		// TODO show the selected div
	}

	public function startMenu() : Void {

		/*if (menu != null) {

			onInterfaceLocaleDataPathRequest();

			menu.init(menuData);

			onRestoreLocaleRequest();
		}*/
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

	public function setGameOver() : Void {

	}


	// WIP

	public function hideContextual(c : ContextualType) : Void {

		// TODO select the contextual and hide it
		/*var cd : Display = getContextual(c);

		doHideContextual(cd);*/
	}

	public function displayContextual(c : ContextualType, ? hideOther : Bool = true) : Void {

		// TODO select the contextual and show it
		/*var cd : Display = getContextual(c);

		doDisplayContextual(cd, cd.layout, hideOther);*/
	}

	/*public function setFinishedPart(partId : String) : Void {

		var finishedPart = parts.pop();

		if (finishedPart.part.id != partId) {

			trace("WARNING "+finishedPart.part.id+" != "+partId);
		}
		if (menu != null) {

			menu.setPartFinished(partId);
		}
	}*/

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


	///
	// INTERNALS
	//

	/*
	function onPartDisplayLoaded(pd : PartDisplay) : Void {

		onSetBookmarkRequest(pd.part.id);

		pd.startPart(startIndex);

		if (pd.visible && pd.layout != null) {

			changeLayout(pd.layout);
		}
		//currentLayout.zones.get(mainLayoutRef).addChild(pd);

		//currentLayout.updateDynamicFields();

		onPartLoaded(pd.part);
	}


	public function displayNext(previous : Part) : Void {

		if (!parts.isEmpty() && parts.first().part == previous.parent) {

			parts.first().visible = true;
			parts.first().nextElement();
			// if this part is not finished too
			if (parts.first() != null) {

				changeLayout(parts.first().layout);
			}

		}
	}

	function onEnterSubPart(part : Part) : Void {

		onPartDisplayRequest(part);
	}

	function createPartDisplay(part : Part) : Null<PartDisplay> {

		if (part == null) {

			return null;
		}
		part.restart();

		var creation : PartDisplay = null;

		if (part.isDialog()) {

			creation = new DialogDisplay(callbacks, part);

		} else if(part.isStrip()) {

			creation = new StripDisplay(callbacks, part);

		} else if(part.isActivity()) {

			creation = new ActivityDisplay(callbacks, part);

		} else {

			creation = new PartDisplay(callbacks, part);
		}

		return creation;
	}*/

	// WIP

	/*function getContextual(c : ContextualType) : Display {

		switch (c) {

			case MENU:

				return menu;

			case NOTEBOOK:

				return notebook;
		}
		return null;
	}*/

	/*function doDisplayContextual(contextual : Display, ? layout : String, hideOther : Bool = true) : Void {

		// Remove previous one
		if ( hideOther && lastContextual != null
			 && currentLayout.zones.get(mainLayoutRef).contains(lastContextual) && !parts.isEmpty() ) {

			doHideContextual(lastContextual);
		}

		// Change to selected layout
		if (layout != null) {

			changeLayout(layout);
		}
		currentLayout.zones.get(mainLayoutRef).addChild(contextual);

		lastContextual = contextual;

		currentLayout.updateDynamicFields();
	}

	private function doHideContextual(contextual : Display) : Void {

		if (currentLayout.name == contextual.layout) {

			currentLayout.zones.get(mainLayoutRef).removeChild(contextual);

			changeLayout(previousLayout);
		}
	}*/
}