package grar.view;

import aze.display.TilesheetEx;

import com.knowledgeplayers.utils.assets.AssetsStorage;

import grar.model.localization.LocaleData;
import grar.model.part.Part;

import grar.view.component.container.WidgetContainer;
import grar.view.contextual.menu.MenuDisplay;
import grar.view.contextual.NotebookDisplay;
import grar.view.element.TokenNotification;
import grar.view.part.PartDisplay;
import grar.view.part.ActivityDisplay;
import grar.view.part.DialogDisplay;
import grar.view.part.IntroScreen;
import grar.view.part.StripDisplay;
import grar.view.layout.Layout;
import grar.view.style.StyleSheet;
import grar.view.style.Style;
import grar.view.FilterData;
import grar.view.TransitionTemplate;
import grar.view.Display;

import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.Lib;

import grar.util.DisplayUtils;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

class Application {
	
	public function new() {

		// note: if we were to support multi instances with GRAR, 
		// we should pass here the targetted API's root element of 
		// the GRAR instance.

		
		// WIP 

		this.parts = new GenericStack<PartDisplay>();
	}

	public var tilesheet (default, default) : TilesheetEx;

	public var filters (default, default) : StringMap<FilterData>;

	public var transitions : StringMap<TransitionTemplate>;

	public var menuData (default, set) : Null<MenuData>;

	public var stylesheets : Null<StringMap<StyleSheet>>;

	public var localeData : LocaleData;

	private var stashedLocale : GenericStack<LocaleData>;


	public var menu (default, set) : Null<MenuDisplay>;

	public var notebook (default, null) : Null<NotebookDisplay>;

	public var tokenNotification (default, null) : Null<TokenNotification>;

#if (flash || openfl)
	public var tokensImages (default, set) : Null<StringMap<{ small : BitmapData, large : BitmapData }>>;
#else
	public var tokensImages (default, set) : Null<StringMap<{ small : String, large : String }>>;
#end

	public var layouts (default, null) : Null<StringMap<Layout>> = null;


	// WIP

	public var currentLayout : Null<Layout> = null;

	public var previousLayout : String = null; // FIXME shouldn't be here

	var parts : GenericStack<PartDisplay>;

	var startIndex:Int;

	
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

	public function changeLayout(l : String) : Void {

		if (l == null) {

			l = "default";
		}
		if (currentLayout == null || l != currentLayout.name) {

			previousLayout = currentLayout == null ? "default" : currentLayout.name;
			
			if (currentLayout != null) {

				Lib.current.removeChild(currentLayout.content);
			}
			currentLayout = layouts.get(l);
			
			if (currentLayout == null) {

				throw "there is no layout '"+l+"'";
			}
			Lib.current.addChild(currentLayout.content);

		} else {

			previousLayout = currentLayout == null ? "default" : currentLayout.name;
		}
	}

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

		d.applicationTilesheet = tilesheet;

		n.setContent(d);

		n.onClose = function(){ hideContextual(n); }

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


	// WIP

	public function startMenu() : Void {

		if (menu != null) {

			menu.init(menuData);
		}
	}

	/**
    * Display a graphic representation of the given part
    * @param    part : The part to display
    * @param    interrupt : Stop current part to display the new one
    * @return true if the part can be displayed.
    */
	public function displayPart(part:Part, interrupt:Bool = false, startPosition:Int = -1):Bool
	{
		#if !kpdebug
		// Part doesn't meet the requirements to start
		if(!part.canStart())
			return false;
		#end

		if (interrupt) {

			var oldPart = parts.pop();

			if (oldPart != null) {

// FIXME				oldPart.removeEventListener(PartEvent.EXIT_PART, onExitPart);
				oldPart.exitPart();
			}
		}
		if (!parts.isEmpty()) {

// FIXME			parts.first().removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
		}
		// Display the new part
		parts.add(createPartDisplay(part));
trace("Part created");
		startIndex = startPosition;
		
// FIXME		parts.first().addEventListener(PartEvent.EXIT_PART, onExitPart);
// FIXME		parts.first().addEventListener(PartEvent.ENTER_SUB_PART, onEnterSubPart);
// FIXME		parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
// FIXME		parts.first().addEventListener(GameEvent.GAME_OVER, function(e:GameEvent)
// FIXME		{
// FIXME			game.connection.tracking.setStatus(true);
// FIXME			game.connection.computeTracking(game.stateInfos);
// FIXME			dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
// FIXME		});

		parts.first().init();

		return true;
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


	///
	// INTERNALS
	//


	// WIP

	function createPartDisplay(part:Part):Null<PartDisplay>
	{
		if(part == null)
			return null;
		part.restart();
		var creation:PartDisplay = null;
		if(part.isDialog())
			creation = new DialogDisplay(part);
		else if(part.isStrip())
			creation = new StripDisplay(part);
		else if(part.isActivity())
			creation = new ActivityDisplay(part);
		else
			creation = new PartDisplay(part);

		return creation;
	}

	private function hideContextual(contextual : Display) : Void {

// FIXME		if (layout.name == contextual.layout) {

// FIXME			layout.zones.get(game.ref).removeChild(cast(contextual, KpDisplay));
// FIXME			changeLayout(previousLayout);
// FIXME		}
	}

}