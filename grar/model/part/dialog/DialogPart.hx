package grar.model.part.dialog;

import grar.model.part.Pattern;
import grar.model.part.Part;

class DialogPart extends Part {

	public function new(pd : PartData) { super(pd); }

	override public function restart() : Void {

		super.restart();

		switch (elements[elemIndex]) {

			case Pattern(p):

				p.restart();

			default: // nothing
		}
	}
}