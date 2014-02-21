package grar.parser.component;

import grar.view.component.Widget;

import grar.util.ParseUtils;

import haxe.xml.Fast;

class XmlToWidget {

	///
	// API
	//

	static public function parseWidgetData(f : Fast) : WidgetData {

		//var f : Fast = new Fast(xml);

		var wd : WidgetData = { };

		if (f != null) {

			if (!f.has.ref) {

				throw "expected ref attribute not found";
			
			} else {

				wd.ref = f.att.ref;
			}

			// Scales
			if (f.has.scale) {

				wd.scale = Std.parseFloat(f.att.scale);
			
			} else {

				wd.scale = 1;
			}

			if (f.has.scaleX) {

				wd.scaleX = Std.parseFloat(f.att.scaleX);
			}
			if (f.has.scaleY) {

				wd.scaleY = Std.parseFloat(f.att.scaleY);
			}

			// Coordinates
			if (f.has.x) {

				wd.currentX = f.att.x;
				wd.x = f.att.x;
			}
			if (f.has.y) {

				wd.y = f.att.y
			}

			// Transitions
			wd.transitionIn = f.has.transitionIn ? f.att.transitionIn : "";
			wd.transitionOut = f.has.transitionOut ? f.att.transitionOut : "";

			if (f.has.alpha) {

				wd.alpha = Std.parseFloat(f.att.alpha);
			}
			if (f.has.rotation) {

				wd.rotation = Std.parseFloat(f.att.rotation);
			}
			if (f.has.transformation) {

				wd.transformation = f.att.transformation;
			}
			// FIXME if (f.has.filters) {

			// FIXME 	filters = FilterManager.getFilter(f.att.filters);
			// FIXME }
			if (f.has.border) {

				var params = f.att.border.split(",");
				var thickness = Std.parseFloat(params[0].trim());
				var borderColor = ParseUtils.parseColor(params[1].trim());
				borderStyle = { thickness: thickness, color: borderColor };
			}
			if (f.has.position) {

				position = Type.createEnum(Positioning, f.att.position.toUpperCase());
			}
		}
	}

	
}