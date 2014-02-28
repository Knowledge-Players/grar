package grar.view;

import aze.display.TilesheetEx;

import motion.actuators.GenericActuator.IGenericActuator;

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
import grar.view.tweening.Tweener;
import grar.view.FilterData;
import grar.view.TransitionTemplate;
import grar.view.ElementData;
import grar.view.Display;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
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
	GLOSSARY;
	BIBLIOGRAPHY;
	INVENTORY;
}

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

	public var menuData (default, set) : Null<MenuData>;

	public var stylesheets : Null<StringMap<StyleSheet>>;

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


	// WIP

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


	///
	// API
	//

	public function initTweener(t : StringMap<TransitionTemplate>) : Void {

		this.tweener = new Tweener(t);
	}

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
			Lib.current.addChild(currentLayout.content); trace("child added to Lib.current");

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
				if (sd.backgroundSrc != null) {

					if (Std.parseInt(sd.backgroundSrc) != null) {

						sd.background = new Bitmap();
	#if !html
 						sd.background.opaqueBackground = Std.parseInt(sd.backgroundSrc);
	#end

					} else {

						sd.background = new Bitmap(AssetsStorage.getBitmapData(sd.backgroundSrc));

					}
				}

				// set icon bitmap
				if (sd.iconSrc != null) {

					if (sd.iconSrc.indexOf(".") < 0) {

						sd.icon = DisplayUtils.getBitmapDataFromLayer(tilesheet, sd.iconSrc);
					
					} else {

						sd.icon = AssetsStorage.getBitmapData(sd.iconSrc);
					}
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

		tokenNotification.onTransitionRequested = onTransitionRequested;
		tokenNotification.onStopTransitionRequested = onStopTransitionRequested;

		onTokenNotificationChanged();
	}

	public function createLayouts(lm : StringMap<LayoutData>) : Void {

		var l : StringMap<Layout> = new StringMap();

		for (lk in lm.keys()) {

			var nl : Layout = new Layout(lm.get(lk), tilesheet);

			nl.onTransitionRequested = onTransitionRequested;
			nl.onStopTransitionRequested = onStopTransitionRequested;

			l.set(lk, nl);

			nl.onVolumeChangeRequested = changeVolume;
		}
		this.layouts = l;

		onLayoutsChanged();
	}

	public function createNotebook(d : DisplayData) : Void {

		var n : NotebookDisplay = new NotebookDisplay();

		n.onTransitionRequested = onTransitionRequested;
		n.onStopTransitionRequested = onStopTransitionRequested;

		n.onContextualDisplayRequested = function(c:ContextualType){ displayContextual(c); };
		n.onContextualHideRequested = hideContextual;
		n.onQuitGameRequested = onQuitGameRequested;

		n.onClose = function() { doHideContextual(n); }

		d.applicationTilesheet = tilesheet;

		n.setContent(d);

		n.onClose = function(){ doHideContextual(n); }

		this.notebook = n;

		onNotebookChanged();
	}

	public function createMenu(d : DisplayData) : Void {

		var m : MenuDisplay = new MenuDisplay();

		m.onTransitionRequested = onTransitionRequested;
		m.onStopTransitionRequested = onStopTransitionRequested;

		m.onContextualDisplayRequested = function(c:ContextualType){ displayContextual(c); };
		m.onContextualHideRequested = hideContextual;
		m.onQuitGameRequested = onQuitGameRequested;

		d.applicationTilesheet = tilesheet;

		m.setContent(d);

		// TODO set callbacks on m
		// ...

		// IN pipes
		// m.setPartFinished(partId) <= done

		menu = m;

		onMenuChanged();
	}

	public function initMenu() : Void {

        if (menu != null) {

            menu.init(menuData);
        }
	}


	// WIP


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
	public function stopSound():Void
	{
		if(itemSoundChannel != null)
			itemSoundChannel.stop();
	}

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
trace("display part "+part.id);

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
		var fp : PartDisplay = createPartDisplay(part);

		parts.add(fp);

		startIndex = startPosition;
		
//		parts.first().addEventListener(PartEvent.EXIT_PART, onExitPart);
		fp.onExit = function(){ onExitPart(parts.first().part.id); }
// FIXME		parts.first().addEventListener(PartEvent.ENTER_SUB_PART, onEnterSubPart);
		fp.onEnterSubPart = function(sp : Part){ /* TODO */ }
// FIXME		parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		fp.onPartLoaded = function(){ onPartLoaded(fp); }
// FIXME		parts.first().addEventListener(GameEvent.GAME_OVER, function(e:GameEvent) {...});
		fp.onGameOver = function(){ 

// FIXME				game.connection.tracking.setStatus(true);
// FIXME				game.connection.computeTracking(game.stateInfos);
// FIXME				dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
			}
/* TODO
*/
		fp.onTokenToActivate = onActivateTokenRequested;

		fp.onSoundToLoad = loadSound;
		fp.onSoundToPlay = playSound;

		fp.onTransitionRequested = onTransitionRequested;
		fp.onStopTransitionRequested = onStopTransitionRequested;

		fp.onContextualDisplayRequested = function(c:ContextualType){ displayContextual(c); };
		fp.onContextualHideRequested = hideContextual;
		fp.onQuitGameRequested = onQuitGameRequested;

		fp.init();

		return true;
	}


	public function hideContextual(c : ContextualType) : Void {
	
		var cd : Display = getContextual(c);

		doHideContextual(cd);
	}

	public function displayContextual(c : ContextualType, ? hideOther : Bool = true) : Void {
	
		var cd : Display = getContextual(c);

		doDisplayContextual(cd, cd.layout, hideOther);
	}

	//private function onExitPart(event:Event) : Void {
	public function setFinishedPart(partId : String) : Void {
		
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


	// WIP

	function onPartLoaded(pd : PartDisplay) : Void { trace("onPartLoaded "+pd.part.id);

		// TODO setBookmark(pd.part.id);

		//pd.removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
		pd.startPart(startIndex);

		if (pd.visible && pd.layout != null) {

			changeLayout(pd.layout);
		}
		currentLayout.zones.get(mainLayoutRef).addChild(pd);

		currentLayout.updateDynamicFields();

		// FIXME var event = new PartEvent(PartEvent.ENTER_PART);
		// FIXME event.part = partDisplay.part;
		// FIXME dispatchEvent(event);
	}

	function createPartDisplay(part : Part) : Null<PartDisplay> {
trace("create part display for "+part.id);
		if (part == null) {

			return null;
		}
		part.restart();

		part.display.applicationTilesheet = tilesheet;
		
		var creation : PartDisplay = null;

		if (part.isDialog()) {

			creation = new DialogDisplay(part);
		
		} else if(part.isStrip()) {

			creation = new StripDisplay(part);
		
		} else if(part.isActivity()) {

			creation = new ActivityDisplay(part);
		
		} else {

			creation = new PartDisplay(part);
		}

		return creation;
	}

	function getContextual(c : ContextualType) : Display {

		switch (c) {

			case MENU:

				return menu;
			
			case NOTEBOOK:

				return notebook;
			
			case GLOSSARY:

				// TODO doDisplayContextual(GlossaryDisplay.instance, GlossaryDisplay.instance.layout, hideOther);
			
			case BIBLIOGRAPHY:

				// TODO doDisplayContextual(BibliographyDisplay.instance, BibliographyDisplay.instance.layout, hideOther);
			
			case INVENTORY: // nothing ?

				//
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

	private function onTransitionRequested(target : Dynamic, transition : String, ? delay : Float = 0) : IGenericActuator {

		return tweener.applyTransition(target, transition, delay);
	}

	private function onStopTransitionRequested(target : Dynamic, ? properties : Null<Dynamic>, ? complete : Bool = false, ? sendEvent : Bool = true) : Void {

		tweener.stop(target, properties, complete, sendEvent);
	}
}