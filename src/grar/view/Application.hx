package grar.view;

import aze.display.TilesheetEx;

import com.knowledgeplayers.utils.assets.AssetsStorage;

import grar.view.component.container.WidgetContainer;
import grar.view.contextual.menu.MenuDisplay;
import grar.view.contextual.NotebookDisplay;
import grar.view.element.TokenNotification;
import grar.view.layout.Layout;
import grar.view.style.StyleSheet;
import grar.view.style.Style;
import grar.view.FilterData;
import grar.view.TransitionTemplate;
import grar.view.Display;

#if (flash || openfl)
import flash.display.BitmapData;
import flash.display.Bitmap;
#end

import grar.util.DisplayUtils;

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

	public var stylesheets : Null<StringMap<StyleSheet>>;


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

	public function createStyles(ssds : Array<StyleSheetData>) : Void {

		var newStyles : StringMap<StyleSheet> = new StringMap();

		for (ssd in ssds) {

			var ss : StyleSheet = cast { };

			ss.name = ssd.name;
			ss.styles = new StringMap();

			for (sd in ssd.styles) {
#if (flash || openfl)
				// set background bitmap
				if (Std.parseInt(sd.backgroundSrc) != null) {

					sd.background = new Bitmap();
	#if !html
 					sd.background.opaqueBackground = Std.parseInt(sd.backgroundSrc);
	#end

				} else {

					sd.background = new Bitmap(AssetsStorage.getBitmapData(sd.backgroundSrc));

				}

				// set icon bitmap
				if (sd.iconSrc.indexOf(".") < 0) {

					sd.icon = DisplayUtils.getBitmapDataFromLayer(tilesheet, sd.iconSrc);
				
				} else {

					sd.icon = AssetsStorage.getBitmapData(sd.iconSrc);
				}
#end
				var s : Style =  new Style(sd);

				ss.styles.set( s.name , s );
			}

			newStyles.set(ss.name, ss);
		}

		stylesheets = newStyles;

		onStylesChanged();
	}

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

	public dynamic function onStylesChanged() : Void { }

}