package grar.parser.component;

import grar.view.component.Widget;

import grar.util.ParseUtils;

import haxe.xml.Fast;

using StringTools;

class XmlToWidget {

	///
	// API
	//

	static public function parseWidgetData(f : Fast) : WidgetData {

		//var f : Fast = new Fast(xml);

		var wd : WidgetData = cast { };

		if (f != null) {

			if (!f.has.ref) {
//trace("f= "+f.x);
				throw "expected ref attribute not found";
			
			} else {

				wd.ref = f.att.ref;
			}

			// Scales
			wd.scale = f.has.scale ? Std.parseFloat(f.att.scale) : 1;
			wd.scaleX = f.has.scaleX ? Std.parseFloat(f.att.scaleX) : null;
			wd.scaleY = f.has.scaleY ? Std.parseFloat(f.att.scaleY) : null;
			wd.currentX = f.has.x ? f.att.x : null;
			wd.x = f.has.x ? f.att.x : "0";
			wd.y = f.has.y ? f.att.y : "0";

			// Transitions
			wd.transitionIn = f.has.transitionIn ? f.att.transitionIn : "";
			wd.transitionOut = f.has.transitionOut ? f.att.transitionOut : "";
			
			wd.alpha = f.has.alpha ? Std.parseFloat(f.att.alpha) : null;
			wd.rotation = f.has.rotation ? Std.parseFloat(f.att.rotation) : null;
			wd.transformation = f.has.transformation ? f.att.transformation : null;

			wd.filters = f.has.filters ? f.att.filters : null;

			if (f.has.border) {

				var params = f.att.border.split(",");
				var thickness = Std.parseFloat(params[0].trim());
				var borderColor = ParseUtils.parseColor(params[1].trim());
				wd.borderStyle = { thickness: thickness, color: borderColor };
			
			} else {

				wd.borderStyle = null;
			}
			wd.position = f.has.position ? Type.createEnum(Positioning, f.att.position.toUpperCase()) : null;
		}

		return wd;
	}
}