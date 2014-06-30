package grar.view;

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
}
class Application{

	public function new(root, ?mobile: Bool = false){

	}

	public var menuData (default, set) : Null<MenuData>;

	public var menus (default, null): Map<String, MenuDisplay>;

	public var defaultStyleSheetName : Null<String> = null;

	public var localeData : LocaleData;

	private var stashedLocale : GenericStack<LocaleData>;

	public var tokensImages (default, set) : Null<StringMap<{ small : String, large : String }>>;

	public var tokenNotification (default, default) : Null<String>;

	public var partDisplay (get, null):PartDisplay;

	public var previousLayout : String = null;

	var parts : GenericStack<PartDisplay>;

	var startIndex:Int;

	public var mainLayoutRef (default, default) : Null<String> = null;

	public var masterVolume(default, set) : Float = 1;

	public var document (default, null): Document;

	public var isMobile (default, default):Bool;


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


	///
	// CALLBACKS
	//

	public dynamic function onMenuClicked(partId : String, menuId: String) : Void { }

	public dynamic function onMenuDataChanged() : Void { }

	public dynamic function onMasterVolumeChanged(): Void {}

	public dynamic function onPartLoaded() : Void { }

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

	public function initMenu(ref: String, levels: Array<LevelData>) : Void {}
	public function initPart(ref:String, ?templateUri: String, ?forward: Bool = true, ?noReload: Bool = false):Void
	{}
	public function getElementById(id:String):Element
	{ return null;}
	public function initSounds(rootElement: Element):Void
	{}
}