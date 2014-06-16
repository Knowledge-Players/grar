package grar;

import grar.model.Config;
import grar.Controller;


@:expose("grar")
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


		// TODO get as paramaters
		// Bitrate
		#if js
		// by default, grar starts with an asset-embedded structure.xml file
		var st = untyped __js__('typeof STRUCTURE != "undefined" ? STRUCTURE : null;');
		if(st != null)
			c.parseConfigParameter( "structureUri", untyped __js__('STRUCTURE') );
		else{
			trace("No structure defined. Setting to default: content/structure.xml");
			c.parseConfigParameter( "structureUri", "content/structure.xml" );
		}
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

		// TODO userAgent in Config

		controller = new Controller(c);
		controller.init();
	}

	///
	// Public API
	//

	public static function openMenu(ref:String):Void
	{
		controller.showMenu(ref);
	}

	public static function closeMenu(ref: String):Void
	{
		controller.hideMenu(ref);
	}

	public static function setMasterVolume(volume:Float):Void
	{
		controller.setMasterVolume(volume);
	}

	public static function getMasterVolume(): Float
	{
		return controller.getMasterVolume();
	}
}