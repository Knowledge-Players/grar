package grar;

import grar.model.Config;

class App {

	private var controller : Null<Controller>;

	static public function main() : Void {

		if (controller == null) {

			init();
		}
	}

	private function init() : Void {

		var c = new Config();

		// by default, grar starts with an asset-embedded structure.xml file
		c.parseConfigParameter( "structureUri", "structure.xml" );

		controller = new Controller(c);
	}
}