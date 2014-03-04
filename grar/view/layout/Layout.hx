package grar.view.layout;

import motion.actuators.GenericActuator.IGenericActuator;

import grar.view.Display.DisplayData;

import haxe.ds.StringMap;

import flash.Lib;

typedef LayoutData = {

	var name : String;
	var content : DisplayData;
}

class Layout {

//	public function new(?_name:String, ?_content:Zone, ?_fast:Fast):Void
	public function new(callbacks : grar.view.DisplayCallbacks, at : aze.display.TilesheetEx, ? n : Null<String>, ? c : Null<Zone>, ? ld : Null<LayoutData>) : Void {

		zones = new StringMap();

		this.callbacks = callbacks;
		this.onContextualDisplayRequest = function(c : grar.view.Application.ContextualType, ? ho : Bool = true){ callbacks.onContextualDisplayRequest(c, ho); }
		this.onContextualHideRequest = function(c : grar.view.Application.ContextualType){ callbacks.onContextualHideRequest(c); }
		this.onQuitGameRequest = function(){ callbacks.onQuitGameRequest(); }
		this.onTransitionRequest = function(t : Dynamic, tt : String, ? de : Float = 0) { return callbacks.onTransitionRequest(t, tt, de); }
		this.onStopTransitionRequest = function(t : Dynamic, ? p : Null<Dynamic>, ? c : Bool = false, ? se : Bool = true){ callbacks.onStopTransitionRequest(t, p, c, se); }
		this.onRestoreLocaleRequest = function(){ callbacks.onRestoreLocaleRequest(); }
		this.onLocalizedContentRequest = function(k : String){ return callbacks.onLocalizedContentRequest(k); }
		this.onLocaleDataPathRequest = function(p:String){ callbacks.onLocaleDataPathRequest(p); }
		this.onStylesheetRequest = function(s:String){ return callbacks.onStylesheetRequest(s); }

		this.onNewZone = function(z:Zone){ callbacks.onNewZone(z); }

		if (ld != null) {

			content = new Zone(callbacks, at, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
// 			content.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
			content.onNewZone = function(r : String, z : Zone){ addZone(r, z); }
			content.onNewProgressBar = function(pb:grar.view.component.ProgressBar){ onNewProgressBar(pb); }

			content.init(ld.content);

			this.name = ld.name;

			onNewZone(content);
		
		} else {

			this.name = n;
			this.content = c;
		}
	}

	var callbacks : grar.view.DisplayCallbacks;

	/**
     * All the child zones of this layout
     **/
	public var zones : StringMap<Zone>;

	/**
     * Content of the layout
     **/
	public var content (get, null) : Zone;

	/**
     * Name of this layout
     **/
	public var name : String;


	///
	// GETTER / SETTER
	//

	public function get_content() : Zone {

		return content;
	}


	///
	// CALLBACKS
	//

	public dynamic function onNewProgressBar(b : grar.view.component.ProgressBar) { }

	public dynamic function onNewZone(z : Zone) { }

	public dynamic function onVolumeChangeRequest(v : Float) : Void { }

	

	public dynamic function onContextualDisplayRequest(c : grar.view.Application.ContextualType, ? hideOther : Bool = true) : Void { }

	public dynamic function onContextualHideRequest(c : grar.view.Application.ContextualType) : Void { }

	public dynamic function onQuitGameRequest() : Void { }

	public dynamic function onTransitionRequest(target : Dynamic, transition : String, ? delay : Float = 0) : IGenericActuator { return null; }

	public dynamic function onStopTransitionRequest(target : Dynamic, ? properties : Null<Dynamic>, ? complete : Bool = false, ? sendEvent : Bool = true) : Void {  }

	public dynamic function onRestoreLocaleRequest() : Void { }

	public dynamic function onLocalizedContentRequest(k : String) : String { return null; }

	public dynamic function onLocaleDataPathRequest(uri : String) : Void { }

	public dynamic function onStylesheetRequest(s : Null<String>) : grar.view.style.StyleSheet { return null; }



	///
	// API
	//

	public function setExitNotebook() : Void {

		for (z in zones) {

			z.setExitNotebook();
		}
	}

	public function setEnterNotebook() : Void {

		for (z in zones) {

			z.setEnterNotebook();
		}
	}

	public function setExitMenu() : Void {

		for (z in zones) {

			z.setExitMenu();
		}
	}

	public function setEnterMenu() : Void {

		for (z in zones) {

			z.setEnterMenu();
		}
	}

	public function updateDynamicFields() : Void {

		for (zone in zones) {

			for (field in zone.dynamicFields) {

				// field.field.setContent(Localiser.instance.getItemContent(field.content));
				field.field.setContent(onLocalizedContentRequest(field.content));
				
				field.field.updateX();
			}
		}
	}


	///
	// INTERNALS
	//

	private function addZone(ref : String, zone : Zone) : Void {

		zones.set(ref, zone);

		zone.onVolumeChangeRequest = onVolumeChangeRequest;

		onNewZone(zone);
	}
}