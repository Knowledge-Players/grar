package grar.model.part.strip;

import grar.model.part.Part;

class StripPart extends Part {

	public function new(pd : PartData) { super(pd); }

	/**
     * @return true
	 **/
	override public function isStrip() : Bool {

		return true;
	}
}