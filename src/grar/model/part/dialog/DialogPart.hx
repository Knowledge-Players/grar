package grar.model.part.dialog;

import grar.model.part.Pattern;
import grar.model.part.Part;

import haxe.xml.Fast;

class DialogPart extends Part {

	public function new() { super(); }

	override public function isDialog() : Bool {

		return true;
	}

	override public function restart() : Void {

		super.restart();

		switch (elements[elemIndex]) {

			case Pattern(p):

				p.restart();

			default: // nothing
		}
	}
}