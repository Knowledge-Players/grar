package grar;

import grar.model.Config;
import grar.Controller;

class App {

	static public var controller : Null<Controller> = null;

	static public function main() : Void {

		if (controller == null) {

			init();
		}
	}

	static function init() : Void {

		var c = new Config();

		// by default, grar starts with an asset-embedded structure.xml file
		c.parseConfigParameter( "structureUri", "structure.xml" );
		controller = new Controller(c);
		controller.init();
	}
}