package grar.view;

import aze.display.TilesheetEx;

import motion.actuators.GenericActuator.IGenericActuator;

import com.knowledgeplayers.utils.assets.AssetsStorage;

import grar.model.localization.LocaleData;
import grar.model.part.Part;

import grar.view.component.ProgressBar;
import grar.view.component.container.WidgetContainer;
import grar.view.contextual.menu.MenuDisplay;
import grar.view.contextual.NotebookDisplay;
import grar.view.contextual.GlossaryDisplay;
import grar.view.contextual.BibliographyDisplay;
import grar.view.element.TokenNotification;
import grar.view.part.PartDisplay;
import grar.view.part.ActivityDisplay;
import grar.view.part.DialogDisplay;
import grar.view.part.IntroScreen;
import grar.view.part.StripDisplay;
import grar.view.layout.Layout;
import grar.view.layout.Zone;
import grar.view.style.StyleSheet;
import grar.view.style.Style;
import grar.view.tweening.Tweener;
import grar.view.FilterData;
import grar.view.TransitionTemplate;
import grar.view.ElementData;
import grar.view.Display;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.filters.GlowFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BitmapFilter;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.Lib;

import grar.util.DisplayUtils;

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

		this.callbacks = {

				onContextualDisplayRequested: function(c : ContextualType, ? ho : Bool = true){ this.displayContextual(c, ho); },
				onContextualHideRequested: function(c : ContextualType){ this.hideContextual(c); },
				onQuitGameRequested: function(){ this.onQuitGameRequested(); },
				onTransitionRequested: function(t : Dynamic, tt : String, de : Float = 0){ return this.onTransitionRequested(t, tt, de); },
				onStopTransitionRequested: function(t : Dynamic, ? p : Null<Dynamic>, ? c : Bool = false, ? se : Bool = true){ this.onStopTransitionRequested(t, p, c, se); },
				onRestoreLocaleRequest: function(){ this.onRestoreLocaleRequest(); },
				onLocalizedContentRequest: function(k:String){ return this.onLocalizedContentRequest(k); },
				onLocaleDataPathRequest: function(p:String){ this.onLocaleDataPathRequest(p); },
				onStylesheetRequest: function(s:String){ return this.getStyleSheet(s); },
				onFiltersRequest: function(fids:Array<String>){ return this.getFilters(fids); },
				onPartDisplayRequested: function(p:Part){ displayPart(p); },
				onNewZone: function(z:Zone){ zones.push(z); }
			};
	}

	/**
	 * The application tilesheet (previously in UIFactory)
	 */
	public var tilesheet (default, default) : TilesheetEx;

	public var filters (default, default) : Null<StringMap<BitmapFilter>>;

	public var menuData (default, set) : Null<MenuData>;

	public var stylesheets : Null<StringMap<StyleSheet>>;

	public var defaultStyleSheetName : Null<String> = null;

	public var localeData : LocaleData;

	private var stashedLocale : GenericStack<LocaleData>;


	public var menu (default, null) : Null<MenuDisplay>;

	public var notebook (default, null) : Null<NotebookDisplay>;

	public var tokenNotification (default, null) : Null<TokenNotification>;

#if (flash || openfl)
	public var tokensImages (default, set) : Null<StringMap<{ small : BitmapData, large : BitmapData }>>;
#else
	public var tokensImages (default, set) : Null<StringMap<{ small : String, large : String }>>;
#end

	public var layouts (default, null) : Null<StringMap<Layout>> = null;

	var zones : Array<Zone>;

	var progressBars : Array<ProgressBar>;


	// WIP

	var callbacks : grar.view.DisplayCallbacks;

	var tweener : Null<Tweener> = null;

	public var currentLayout : Null<Layout> = null;

	public var previousLayout : String = null; // FIXME shouldn't be here

	var parts : GenericStack<PartDisplay>;

	var startIndex:Int;

	private var lastContextual: Display;

	public var mainLayoutRef (default, default) : Null<String> = null;


	private var nbVolume:Float = 1;
	private var itemSoundChannel:SoundChannel;
	private var sounds:Map<String, Sound>;

	var glossary : Null<GlossaryDisplay> = null;

	var bibliography : Null<BibliographyDisplay> = null;

	
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

	public dynamic function onQuitGameRequested() : Void { }

	public dynamic function onActivateTokenRequested(tokenName : String) : Void { }

	public dynamic function onRestoreLocaleRequest() : Void { }

	public dynamic function onLocalizedContentRequest(k : String) : String { return null; }

	public dynamic function onLocaleDataPathRequest(uri : String) : Void { }

	public dynamic function onInterfaceLocaleDataPathRequest() : Void { }

	public dynamic function onSetBookmarkRequest(partId : String) : Void { }

	public dynamic function onGameOverRequested() : Void { }

	public dynamic function onMenuUpdateDynamicFieldsRequest() : Void { }

	public dynamic function onPartLoaded(p : Part) : Void { }


	///
	// API
	//

	public function setPartLoaded(part : Part, allItems : Array<grar.model.tracking.Trackable>, 
									allParts : Array<grar.model.part.Part>) : Void {

		for (pb in progressBars) {

			pb.setEnterPart(part, allItems, allParts);
		}
	}

	public function getFilters(filtersIds : Array<String>) : Array<BitmapFilter> {

		var result = new Array<BitmapFilter>();
		
		for (filter in filtersIds) {

			if (!filters.exists(filter)) {

				throw "no filter found for id '"+filter+"'";
			}

			result.push(filters.get(filter));
		}

		return result;
	}

	public function createFilters(f : StringMap<FilterData>) : Void {

		this.filters = new StringMap();

		for (fk in f.keys()) {

			var nf : BitmapFilter;

			switch (f.get(fk)) {

				case DropShadow(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject):

					var q = switch(quality){ case Low: BitmapFilterQuality.LOW; case Medium: BitmapFilterQuality.MEDIUM; case High: BitmapFilterQuality.HIGH; }

					nf = new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, q, inner, knockout, hideObject);

				case Blur(blurX, blurY, quality):

					var q = switch(quality){ case Low: BitmapFilterQuality.LOW; case Medium: BitmapFilterQuality.MEDIUM; case High: BitmapFilterQuality.HIGH; }

					nf = new BlurFilter(blurX, blurY, q);

				case Glow(color, alpha, blurX, blurY, strength, quality, inner, knockout):

					var q = switch(quality){ case Low: BitmapFilterQuality.LOW; case Medium: BitmapFilterQuality.MEDIUM; case High: BitmapFilterQuality.HIGH; }

					nf = new GlowFilter(color, alpha, blurX, blurY, strength, q, inner, knockout);

				case ColorMatrix(matrix):

					nf = new ColorMatrixFilter(matrix);

			}

			this.filters.set(fk, nf);
		}
	}

	public function initTweener(t : StringMap<TransitionTemplate>) : Void {

		this.tweener = new Tweener(t);
	}

	public function changeLayout(l : String) : Void { trace("CHANGE LAYOUT " + l);

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
			Lib.current.addChild(currentLayout.content); trace("Layout "+currentLayout.name+" just added");

		} else {

			previousLayout = currentLayout == null ? "default" : currentLayout.name;
		}
	}

	public function createStyles(ssds : Array<StyleSheetData>) : Void {

		var newStyles : StringMap<StyleSheet> = new StringMap();

		for (ssd in ssds) {

			var name = ssd.name;
			var styles = new StringMap();

			for (sd in ssd.styles) {
#if (flash || openfl)
				// set icon bitmap
				if (sd.iconSrc != null) {

					if (sd.iconSrc.indexOf(".") < 0) {

						sd.icon = DisplayUtils.getBitmapDataFromLayer(tilesheet, sd.iconSrc);
					}
				}
#end
				var s : Style =  new Style(sd);

				styles.set( s.name , s );
			}

			newStyles.set(name, new StyleSheet(name, styles));

			if (defaultStyleSheetName == null) {

				defaultStyleSheetName = name;
			}
		}

		stylesheets = newStyles;
//trace("styles ready");
		onStylesChanged();
	}

	public function createTokenNotification(d : WidgetContainerData) : Void {

		tokenNotification = new TokenNotification(callbacks, tilesheet, d);

		onTokenNotificationChanged();
	}

	public function createLayouts(lm : StringMap<LayoutData>) : Void {

		var l : StringMap<Layout> = new StringMap();
		zones = [];
		progressBars = [];

		for (lk in lm.keys()) {

			var nl : Layout = new Layout(callbacks, tilesheet, null, null, lm.get(lk));

			l.set(lk, nl);

			nl.onVolumeChangeRequested = changeVolume;
			nl.onNewProgressBar = function(pb : ProgressBar){ progressBars.push(pb); }
		}
		this.layouts = l;

		onLayoutsChanged();
	}

	public function createNotebook(d : DisplayData) : Void {

		var n : NotebookDisplay = new NotebookDisplay(callbacks, tilesheet);

		n.onClose = function() { doHideContextual(n); }
		n.onNotebookAdded = function() {

				for (z in zones) {

					z.setEnterNotebook();
				}
			}
		n.onNotebookRemoved = function() {

				for (z in zones) {

					z.setExitNotebook();
				}
			}
	
		if (d.filtersData != null) {

			d.filters = getFilters(d.filtersData);
		}

		n.setContent(d);

		this.notebook = n;

		onNotebookChanged();
	}

	public function createMenu(d : DisplayData) : Void {

		var m : MenuDisplay = new MenuDisplay(callbacks, tilesheet);

		m.onMenuAdded = function() { onMenuAdded(); }
		m.onMenuReady = function() {

				for (z in zones) {

					z.setEnterMenu();
				}
			}
		m.onMenuRemoved = function() {

				for (z in zones) {

					z.setExitMenu();
				}
			}
		m.onMenuClicked = function(partId : String) {

				onMenuClicked(partId);
			}
		m.onMenuHide = function() {

				doHideContextual(m);
			}
		m.onMenuButtonStateRequest = function(partId : String) { return onMenuButtonStateRequest(partId); }
	
		if (d.filtersData != null) {

			d.filters = getFilters(d.filtersData);
		}
		m.onUpdateDynamicFieldsRequest = function(){

				onMenuUpdateDynamicFieldsRequest();
			}

		m.setContent(d);

		menu = m;

		onMenuChanged();
	}

	public function startMenu() : Void {

		if (menu != null) {

			onInterfaceLocaleDataPathRequest();

			menu.init(menuData);

			onRestoreLocaleRequest();
		}
	}

	public function changeVolume(nb : Float = 0) : Void {

		nbVolume = nb;

		if (itemSoundChannel != null) {

			var soundControl = itemSoundChannel.soundTransform;
			soundControl.volume = nbVolume;
			itemSoundChannel.soundTransform = soundControl;
		}
	}

	/**
	* Pre load a sound. Then use playSound with the same url to play it
	* @param soundUrl : Path to the sound file
	**/
	public function loadSound(soundUrl:String):Void
	{
		if (soundUrl != null && soundUrl != "") {

			var sound = new Sound(new flash.net.URLRequest(soundUrl));
			sounds.set(soundUrl, sound);
		}
	}

	/**
    * Play a sound. May cause error if the sound is not preloaded with loadSound()
    * @param soundUrl : Path to the sound file
    **/
	public function playSound(soundUrl: String):Void
	{
		if (soundUrl != null) {

			stopSound();
			
			if (!sounds.exists(soundUrl)) {

				loadSound(soundUrl);
			}
			itemSoundChannel = sounds.get(soundUrl).play();
		}
	}

	/**
	* Stop currently playing sound
	**/
	public function stopSound() : Void {

		if (itemSoundChannel != null) {

			itemSoundChannel.stop();
		}
	}

	/**
    * Display a graphic representation of the given part
    * @param    part : The part to display
    * @param    interrupt : Stop current part to display the new one
    * @return true if the part can be displayed.
    */
	public function displayPart(part : Part, interrupt : Bool = false, startPosition : Int = -1) : Bool {

#if !kpdebug
		// Part doesn't meet the requirements to start
		if (!part.canStart()) {

			return false;
		}
#end
trace("display part "+part.id);
		if (interrupt) {

			var oldPart = parts.pop();

			if (oldPart != null) {

// 				oldPart.removeEventListener(PartEvent.EXIT_PART, onExitPart);
				oldPart.exitPart();
			}
		}
		if (!parts.isEmpty()) {

// 			parts.first().removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
			parts.first().onPartLoaded = function(){ trace("CHECK THIS !!!!"); }
		}
		// Display the new part
		var fp : PartDisplay = createPartDisplay(part);

		parts.add(fp);

		startIndex = startPosition;
		
//		parts.first().addEventListener(PartEvent.EXIT_PART, onExitPart);
		fp.onExit = function(){ onExitPart(parts.first().part.id); }

// 		parts.first().addEventListener(PartEvent.ENTER_SUB_PART, onEnterSubPart);
		fp.onEnterSubPart = function(sp : Part){ onEnterSubPart(sp); }

// 		parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		fp.onPartLoaded = function(){ onPartDisplayLoaded(fp); }

// 		parts.first().addEventListener(GameEvent.GAME_OVER, function(e:GameEvent) {...});
		fp.onGameOver = function(){ 

				onGameOverRequested();
			}

		fp.onTokenToActivate = onActivateTokenRequested;

		fp.onSoundToLoad = loadSound;
		fp.onSoundToPlay = playSound;

		fp.init();

		return true;
	}

	public function setGameOver() : Void {

		for (pb in progressBars) {

			pb.setGameOver();
		}
// 		dispatchEvent(new GameEvent(GameEvent.GAME_OVER)); TODO call setGameOver on ProgressBar
	}


	// WIP

	public function hideContextual(c : ContextualType) : Void {
	
		var cd : Display = getContextual(c);

		doHideContextual(cd);
	}

	public function displayContextual(c : ContextualType, ? hideOther : Bool = true) : Void {
	
		var cd : Display = getContextual(c);
trace("displayContextual "+cd);
		doDisplayContextual(cd, cd.layout, hideOther);
	}

	//private function onExitPart(event:Event) : Void {
	public function setFinishedPart(partId : String) : Void {
trace("setFinishedPart "+partId);
		var finishedPart = parts.pop();
		
		if (finishedPart.part.id != partId) {

			trace("WARNING "+finishedPart.part.id+" != "+partId);
		}
		if (menu != null) {

			menu.setPartFinished(partId);
		}
	}

	public function displayNext(previous : Part) : Void {

		if (!parts.isEmpty() && parts.first().part == previous.parent) {

			parts.first().visible = true;
			parts.first().nextElement();
			// if this part is not finished too
			if (parts.first() != null) {

				changeLayout(parts.first().layout);
			}

		} else {
trace("Game Over");
			// dispatchEvent(new GameEvent(GameEvent.GAME_OVER)); TODO call setGameOver on ProgressBar
		}
	}

	/**
    * Activate a token of the inventory
    * @param    tokenName : Name of the token to activate
    **/
	//public function activateToken(tokenName:String):Void
	public function setActivateToken(t : grar.model.InventoryToken) : Void {

		if (tokenNotification != null) {

			currentLayout.zones.get(mainLayoutRef).addChild(tokenNotification);

			tokenNotification.setToken(t.name, t.icon);
		}
		notebook.setActivateToken(t);
		// FIXME inventory.setActivateToken(t.id);
	}


	///
	// INTERNALS
	//

	function getStyleSheet(s : Null<String>) : StyleSheet {

		if (s == null) {

			s = defaultStyleSheetName;
		}

		return stylesheets.get(s);
	}

	function onPartDisplayLoaded(pd : PartDisplay) : Void {
trace("onPartLoaded "+pd.part.id);
		onSetBookmarkRequest(pd.part.id);

		//pd.removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
		pd.startPart(startIndex);

		if (pd.visible && pd.layout != null) {

			changeLayout(pd.layout);
		}
		currentLayout.zones.get(mainLayoutRef).addChild(pd);

		currentLayout.updateDynamicFields();

		onPartLoaded(pd.part);
	}

	function onEnterSubPart(part : Part) : Void {
trace("onEnterSubPart "+part.id);
		displayPart(part);
	}

	function createPartDisplay(part : Part) : Null<PartDisplay> {
trace("create part display for "+part.id);
		if (part == null) {

			return null;
		}
		part.restart();
	
		if (part.display.filtersData != null) {

			part.display.filters = getFilters(part.display.filtersData);
		}
		var creation : PartDisplay = null;

		if (part.isDialog()) {

			creation = new DialogDisplay(callbacks, tilesheet, part);
		
		} else if(part.isStrip()) {

			creation = new StripDisplay(callbacks, tilesheet, part);
		
		} else if(part.isActivity()) {

			creation = new ActivityDisplay(callbacks, tilesheet, part);
		
		} else {

			creation = new PartDisplay(callbacks, tilesheet, part);
		}

		return creation;
	}

	function onTransitionRequested(target : Dynamic, transition : String, delay : Float = 0) : IGenericActuator {

		return tweener.applyTransition(target, transition, delay);
	}

	function onStopTransitionRequested(target : Dynamic, ? properties : Null<Dynamic>, 
												? complete : Bool = false, ? sendEvent : Bool = true) : Void {

		tweener.stop(target, properties, complete, sendEvent);
	}


	// WIP

	function getContextual(c : ContextualType) : Display {

		switch (c) {

			case MENU:

				return menu;
			
			case NOTEBOOK:

				return notebook;
		}
		return null;
	}

	function doDisplayContextual(contextual : Display, ? layout : String, hideOther : Bool = true) : Void {

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
	}
}