package grar;

import grar.model.Config;
import grar.Controller;

class App {

	static public var controller : Null<Controller> = null;

	static public function main() : Void {

		if (controller == null) {
			#if (!js && cocktail)
			cocktail.api.Cocktail.boot();
			js.Browser.window.onload = function(_) init();
			#else
			init();
			#end
		}
	}

	static function init() : Void {

		var c = new Config();

		// by default, grar starts with an asset-embedded structure.xml file
		c.parseConfigParameter( "structureUri", "structure.xml" );

		// Bitrate
		#if js
		var bt = untyped __js__('typeof BITRATE != "undefined" ? BITRATE : null;');
		if(bt != null)
			c.parseConfigParameter( "bitrate", untyped __js__('BITRATE') );
		else{
			trace("No bitrate defined. Setting to default: 350");
			c.parseConfigParameter( "bitrate", "350" );
		}
		#else
		c.parseConfigParameter( "bitrate", "350" );
		#end
		controller = new Controller(c);
		controller.init();
	}
}