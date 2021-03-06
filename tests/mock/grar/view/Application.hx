package grar.view;

import grar.model.Config;
import grar.view.contextual.MenuDisplay;
import grar.view.part.PartDisplay;
import grar.model.localization.LocaleData;
import grar.model.contextual.MenuData;
import haxe.ds.GenericStack;
import haxe.ds.StringMap;

typedef Element = String;
typedef Document = String;

enum ContextualType {

	MENU;
	NOTEBOOK;
	INVENTORY;
}
class Application{

	public function new(root, config: Config){

	}

	public var menuData (default, set) : Null<MenuData>;

	public var menus (default, null): Map<String, MenuDisplay>;

	public var localeData : LocaleData;

	private var stashedLocale : GenericStack<LocaleData>;

	public var tokensImages (default, set) : Null<StringMap<{ small : String, large : String }>>;

	public var tokenNotification (default, default) : Null<String>;

	public var partDisplay (get, null):PartDisplay;

	public var theme (default, set):Null<String>;

	var parts : GenericStack<PartDisplay>;

	var startIndex:Int;

	public var masterVolume(default, set) : Float = 1;

	public var document (default, null): Document;

	public var isMobile (default, default):Bool;

	/**
	* The element currently in fullscreen
	**/
	public var fullscreenElement (get, null):Element;

	/**
	* Is the application on fullscreen. Default is false
	**/
	public var isFullscreen (get, null):Bool = false;


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

	public function set_masterVolume(vol:Float):Float
	{
		return masterVolume = vol;
	}


	private function get_fullscreenElement():Element
	{
		return null;
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

	public dynamic function onTokenActivation(tokenId: String): Void {}

	/**
    * Activate a token of the inventory
    * @param    tokenName : Name of the token to activate
    **/
	public function setActivateToken(t : grar.model.InventoryToken) : Void {

	}
	public function updateChapterInfos(chapterName:String, activityName:String):Void
	{}
	public function changeHeaderState(state : String) : Void {}

	public function updateModuleInfos(name:String, type:String, theme:String):Void
	{}

	public function initMenu(display: MenuDisplay, levels: Array<LevelData>) : Void {}
	public function initPart(ref:String, ?templateUri: String, ?forward: Bool = true, ?noReload: Bool = false):Void
	{}
	public function getElementById(id:String):Element
	{ return null;}
	public function initSounds(rootElement: Element):Void
	{}
	public function requestFullscreen():Void
	{}
	public function exitFullscreen():Void
	{}

	private function set_theme(theme:String):String
	{
		return this.theme = theme;
	}

	// HOOKS

	public dynamic function sendReadyHook():Void
	{
	}

	public dynamic function sendNewPartHook():Void
	{
	}
	public dynamic function sendFullscreenHook(): Void {}

}