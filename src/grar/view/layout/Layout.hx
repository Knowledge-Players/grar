package grar.view.layout;

import haxe.ds.StringMap;

class Layout {

	public function new(c : Zone, n : String) : Void {

		this.content = c;
		this.name = n;
		this.zones = new StringMap();
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