package grar.view.layout;

import grar.view.Display.DisplayData;

import haxe.ds.StringMap;

import flash.Lib;

typedef LayoutData = {

	var name : String;
	var content : DisplayData;
}

class Layout {

//	public function new(?_name:String, ?_content:Zone, ?_fast:Fast):Void
	public function new( ? n : Null<String>, ? c : Null<Zone>, ? ld : Null<LayoutData>) : Void {

		zones = new StringMap();

		if (ld != null) {

			content = new Zone(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
// FIXME			content.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);

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
	// API
	//

	public function updateDynamicFields() : Void {

		for (zone in zones) {

			for (field in zone.dynamicFields) {

				// FIXME field.field.setContent(Localiser.instance.getItemContent(field.content));
				// FIXME field.field.updateX();
			}
		}
	}

	

	// FIXME private function onNewZone(e:LayoutEvent):Void
	// FIXME {
	// FIXME 	zones.set(e.ref, e.zone);
	// FIXME }
}