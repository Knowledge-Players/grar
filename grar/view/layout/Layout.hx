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
	public function new( ? n : Null<String>, ? c : Null<Zone>, ? ld : Null<LayoutData>, at : aze.display.TilesheetEx) : Void {

		zones = new StringMap();

		if (ld != null) {

			content = new Zone(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
// 			content.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
			content.onNewZone = addZone;
			ld.content.applicationTilesheet = at;

			content.init(ld.content);

			this.name = ld.name;
		
		} else {

			this.name = n;
			this.content = c;
		}
	}

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

	public dynamic function onNewZone(z : Zone) { }

	public dynamic function onVolumeChangeRequested(v : Float) : Void { }

	public dynamic function onTransitionRequested(target : Dynamic, transition : String, ? delay : Float = 0) : IGenericActuator { return null; }

	public dynamic function onStopTransitionRequested(target : Dynamic, ? properties : Null<Dynamic>, ? complete : Bool = false, ? sendEvent : Bool = true) : Void {  }

	public dynamic function onLocalizedContentRequest(k : String) : String { return null; }

	public dynamic function onLocaleDataPathRequest(uri : String) : Void { }

	public dynamic function onRestoreLocaleRequest() : Void { }



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

		zone.onVolumeChangeRequested = onVolumeChangeRequested;

		onNewZone(zone);
	}
}