package grar.view;

import grar.view.contextual.MenuDisplay;
import grar.view.Application.ContextualType;
import grar.view.part.PartDisplay;
import grar.model.localization.LocaleData;
import grar.model.contextual.MenuData;
import haxe.ds.GenericStack;
import haxe.ds.StringMap;

enum ContextualType {

	MENU;
	NOTEBOOK;
}
class Application{

	public function new(){

	}

	public var menuData (default, set) : Null<MenuData>;

	public var menus (default, null): Map<String, MenuDisplay>;

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


	public function set_menuData(v : Null<MenuData>) : Null<MenuData> {

		return menuData;
	}

	public function set_tokensImages(v : Null<StringMap<{small:String,large:String}>>) : Null<StringMap<{small:String,large:String}>> {


		return tokensImages;
	}

	public function get_partDisplay():PartDisplay
	{
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
	public function changeLayout(l : String) : Void {
	}

	public function initMenu(ref: String, datas: Array<grar.view.contextual.MenuDisplay.LevelData>) : Void {
	}

	public function changeVolume(nb : Float = 0) : Void {

	}

	/**
	* Pre load a sound. Then use playSound with the same url to play it
	* @param soundUrl : Path to the sound file
	**/
	public function loadSound(soundUrl : String) : Void {

	}

	/**
    * Play a sound. May cause error if the sound is not preloaded with loadSound()
    * @param soundUrl : Path to the sound file
    **/
	public function playSound(soundUrl : String) : Void {

	}

	/**
	* Stop currently playing sound
	**/
	public function stopSound() : Void {

	}

	public function setGameOver() : Void {

	}


	// WIP

	public function hideContextual(c : ContextualType) : Void {

	}

	public function displayContextual(c : ContextualType, ? hideOther : Bool = true) : Void {

	}
	/**
    * Activate a token of the inventory
    * @param    tokenName : Name of the token to activate
    **/
	public function setActivateToken(t : grar.model.InventoryToken) : Void {

	}
}