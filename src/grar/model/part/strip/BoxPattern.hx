package grar.model.part.strip;

import grar.model.part.Pattern;

class BoxPattern extends Pattern {

	public function new(pd : PatternData, b : String) {

		super(pd);

		this.background = b;
	}

	public var background (default, default) : String;
}