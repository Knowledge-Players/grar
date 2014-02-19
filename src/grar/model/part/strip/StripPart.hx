package grar.model.part.strip;

import grar.structure.part.Part;

class StripPart extends Part {

	public function new() { super(); }

	/**
     * @return true
	 **/
	override public function isStrip() : Bool {

		return true;
	}
}