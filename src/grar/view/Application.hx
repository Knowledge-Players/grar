package grar.view;

import aze.display.TilesheetEx;

import grar.view.component.container.WidgetContainer;
import grar.view.contextual.menu.MenuDisplay;
import grar.view.contextual.NotebookDisplay;
import grar.view.element.TokenNotification;
import grar.view.layout.Layout;
import grar.view.FilterData;
import grar.view.TransitionTemplate;
import grar.view.Display;

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

	public var transitions : StringMap<TransitionTemplate>;

	public var menuData (default, set) : Null<MenuData>;


	public var menu (default, set) : Null<MenuDisplay>;

	public var notebook (default, null) : Null<NotebookDisplay>;

	public var tokenNotification (default, null) : Null<TokenNotification>;

#if (flash || openfl)
	public var tokensImages (default, set) : Null<StringMap<{ small : BitmapData, large : BitmapData }>>;
#else
	public var tokensImages (default, set) : Null<StringMap<{ small : String, large : String }>>;
#end

	public var layouts (default, null) : Null<StringMap<Layout>> = null;

	
	///
	// GETTER / SETTER
	//

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

#if (flash || openfl)
	public function set_tokensImages(v : Null<StringMap<{small:BitmapData,large:BitmapData}>>) : Null<StringMap<{small:BitmapData,large:BitmapData}>> {
#else
	public function set_tokensImages(v : Null<StringMap<{small:String,large:String}>>) : Null<StringMap<{small:String,large:String}>> {
#end

		if (v == tokensImages) {

			return tokensImages;
		}
		tokensImages = v;

		onTokensImagesChanged();

		return tokensImages;
	}


	///
	// API
	//

	public function createTokenNotification(d : WidgetContainerData) : Void {

		tokenNotification = new TokenNotification(d);

		onTokenNotificationChanged();
	}

	public function createNotebook(d : DisplayData) : Void {

		var n : NotebookDisplay = new NotebookDisplay();

		n.setContent(d);

		this.notebook = n;

		onNotebookChanged();
	}

	public function createLayouts(lm : StringMap<LayoutData>) : Void {

		var l : StringMap<Layout> = new StringMap();

		for (lk in lm.keys()) {

			l.set(lk, new Layout(lm.get(lk)));
		}
		this.layouts = l;

		onLayoutsChanged();
	}

	public function createMenu(d : DisplayData) : Void {

		var m : MenuDisplay = new MenuDisplay();

		m.setContent(d);

		// TODO set callbacks on m
		// ...

		menu = m;
	}

	public function initMenu() : Void {

        if (menu != null) {

            menu.init(menuData);
        }
	}


	///
	// CALLBACKS
	//

	public dynamic function onTokenNotificationChanged() : Void { }

	public dynamic function onNotebookChanged() : Void { }

	public dynamic function onMenuChanged() : Void { }

	public dynamic function onMenuDataChanged() : Void { }

	public dynamic function onLayoutsChanged() : Void { }

	public dynamic function onTokensImagesChanged() : Void { }

}