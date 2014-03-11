package grar.parser;

import grar.view.guide.Guide;
import grar.view.guide.Line;
import grar.view.guide.Curve;
import grar.view.guide.Grid;

import grar.util.ParseUtils;

import haxe.xml.Fast;

class XmlToGuide {

	///
	// API
	//

	static public function parseGuideData(f : Fast) : GuideData {

		return doParseGuideData(f.att.type.toLowerCase(), f);
	}


	///
	// INTERNALS
	//

	public static function doParseGuideData(type : String, f : Fast) : GuideData {

		var creation : GuideData;

		switch(type) {

			case "line": 

				var d : LineData = {

						start: ParseUtils.parseListOfIntValues(f.att.start, ";"),
						end: ParseUtils.parseListOfIntValues(f.att.end, ";"),
						center: f.has.center ? f.att.center == "true" : null,
						transitionIn: f.has.transitionIn ? f.att.transitionIn : null
					};

				creation = Line(d);

				//creation = new Line( new Point(start[0], start[1]), new Point(end[0], end[1]), f.has.center ? f.att.center == "true" : false );
			
			case "grid":

				var d : GridData = {

						numRow: Std.parseInt(f.att.numRow),
						numCol: Std.parseInt(f.att.numCol),
						resize:  f.has.resize ? f.att.resize == "true" : true,
						width: f.has.width ? Std.parseFloat(f.att.width) : null,
						height: f.has.height ? Std.parseFloat(f.att.height) : null,
						gapCol: f.has.gapCol ? Std.parseFloat(f.att.gapCol) : null,
						gapRow: f.has.gapRow ? Std.parseFloat(f.att.gapRow) : null,
						alignment: f.has.alignment ? f.att.alignment : null,
						transitionIn: f.has.transitionIn ? f.att.transitionIn : null,
						cellWidth: f.has.width ? Std.parseFloat(f.att.width) : 0,
						cellHeight: f.has.height ? Std.parseFloat(f.att.height) : 0
					};

				creation = Grid(d);
			
				// var grid = new Grid( Std.parseInt(f.att.numRow), Std.parseInt(f.att.numCol), f.has.resize ? f.att.resize == "true" : true );
				/*
				if (f.has.width) {

					grid.cellSize = {width: Std.parseFloat(f.att.width), height: Std.parseFloat(f.att.height)};
				}
				if (f.has.gapCol) {

					grid.gapCol = Std.parseFloat(f.att.gapCol);
				}
				if (f.has.gapRow) {

					grid.gapRow = Std.parseFloat(f.att.gapRow);
				}
				if (f.has.alignment) {

					grid.setAlignment(f.att.alignment);
				}
				*/
			
			case "curve":

				var d : CurveData = {

						radius: f.has.radius ? Std.parseFloat(f.att.radius) : null,
						minAngle: f.has.minAngle ? Std.parseFloat(f.att.minAngle) : null,
						maxAngle: f.has.maxAngle ? Std.parseFloat(f.att.maxAngle) : null,
						centerObject: f.has.centerObject ?  f.att.centerObject == "true" : null,
						transitionIn: f.has.transitionIn ? f.att.transitionIn : null,
						center:	null
					};
			
				creation = Curve(d);
				/*
				var curve = new Curve();

				if (f.has.radius) {

					curve.radius = Std.parseFloat(f.att.radius);
				}
				if (f.has.minAngle) {

					curve.minAngle = Std.parseFloat(f.att.minAngle);
				}
				if (f.has.maxAngle) {

					curve.maxAngle = Std.parseFloat(f.att.maxAngle);
				}
				if (f.has.centerObject) {

					curve.centerObject = f.att.centerObject == "true";
				}

				creation = curve;
				*/
			
			default: throw "unexpected Guide type attribute: " + type;
		}
		//if (f.has.transitionIn) {

		//	creation.transitionIn = f.att.transitionIn;
		//}
		return creation;
	}
}
