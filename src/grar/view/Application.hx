package grar.view;

import aze.display.TilesheetEx;

import grar.view.contextual.menu.MenuDisplay;
import grar.view.contextual.NotebookDisplay;
import grar.view.element.TokenNotification;
import grar.view.layout.Layout;
import grar.view.FilterData;

#if (flash || openfl)
import flash.display.BitmapData;
#end

import haxe.ds.StringMap;

class Application {
	
	public function new() {

		// note: if we were to support multi instances with GRAR, 
		// we should pass here the targetted API's root element of 
		// the GRAR instance.
	}

	public var tilesheet (default, default) : TilesheetEx;

	public var filters (default, default) : StringMap<FilterData>;

	public var menuData (default, set) : Null<MenuDisplay.MenuData>;


	public var menu (default, set) : Null<MenuDisplay>;

	public var notebook (default, set) : Null<NotebookDisplay>;

	public var tokenNotification (default, set) : Null<TokenNotification>;

#if (flash || openfl)
	public var tokensImages (default, set) : Null<StringMap<{ small : BitmapData, large : BitmapData }>>;
#else
	public var tokensImages (default, set) : Null<StringMap<{ small : String, large : String }>>;
#end

	public var layouts (default, set) : Null<StringMap<Layout>> = null;

	
	///
	// GETTER / SETTER
	//

	public function set_layouts(v : Null<StringMap<Layout>>) : Null<StringMap<Layout>> {

		if (v == layouts) {

			return layouts;
		}
		layouts = v;

		onLayoutsChanged();

		return layouts;
	}

	public function set_menu(v : Null<MenuDisplay>) : Null<MenuDisplay> {

		if (v == menu) {

			return menu;
		}
		menu = v;

		onMenuChanged();

		return menu;
	}

	public function set_menuData(v : Null<MenuData>) : Null<MenuData> {

		if (v == menuData) {

			return menuData;
		}
		menuData = v;

		onMenuDataChanged();

		return menuData;
	}

	public function set_notebook(v : Null<NotebookDisplay>) : Null<NotebookDisplay> {

		if (v == notebook) {

			return notebook;
		}
		notebook = v;

		onNotebookChanged();

		return notebook;
	}

	public function set_tokenNotification(v : Null<TokenNotification>) : Null<TokenNotification> {

		if (v == tokenNotification) {

			return tokenNotification;
		}
		tokenNotification = v;

		onTokenNotificationChanged();

		return tokenNotification;
	}

#if (flash || openfl)
	public function set_tokensImages(v : Null<StringMap<small:BitmapData,large:BitmapData}>>) : Null<StringMap<{small:BitmapData,large:BitmapData}>> {
#else
	public function set_tokensImages(v : Null<StringMap<small:String,large:String}>>) : Null<StringMap<{small:String,large:String}>> {
#end

		if (v == tokensImage) {

			return tokensImage;
		}
		tokensImage = v;

		onTokensImageChanged();

		return tokensImage;
	}


	///
	// API
	//

	public function createMenu(d : DisplayData) : Void {

		var m : MenuDisplay = new MenuDisplay(d);

		// TODO set callbacks on m
		// ...

		menu = m;
	}


	///
	// CALLBACKS
	//

	public dynamic function onTokenNotificationChanged() : Void { }

	public dynamic function onNotebookChanged() : Void { }

	public dynamic function onMenuChanged() : Void { }

	public dynamic function onMenuDataChanged() : Void { }

	public dynamic function onLayoutsChanged() : Void { }

	public dynamic function onTokensImageChanged() : Void { }

}