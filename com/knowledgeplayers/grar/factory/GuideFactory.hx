package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.util.guide.Curve;
import com.knowledgeplayers.grar.util.guide.Grid;
import flash.geom.Point;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.util.guide.Line;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.util.guide.Guide;

class GuideFactory
{
	public static function createGuide(guideType:String, guideFast: Fast):Guide
	{
		var creation: Guide = switch(guideType.toLowerCase()) {
			case "line": var start = ParseUtils.parseListOfIntValues(guideFast.att.start, ";");
				var end = ParseUtils.parseListOfIntValues(guideFast.att.end, ";");
				new Line(new Point(start[0], start[1]), new Point(end[0], end[1]), guideFast.has.center?guideFast.att.center=="true":false);
			case "grid":
				var grid = new Grid(Std.parseInt(guideFast.att.numRow), Std.parseInt(guideFast.att.numCol), guideFast.has.resize?guideFast.att.resize=="true":true);
				if(guideFast.has.width)
					grid.cellSize = {width: Std.parseFloat(guideFast.att.width), height: Std.parseFloat(guideFast.att.height)};
				if(guideFast.has.gapCol)
					grid.gapCol = Std.parseFloat(guideFast.att.gapCol);
                if(guideFast.has.decal)
                    grid.decal = Std.parseFloat(guideFast.att.decal);
				if(guideFast.has.gapRow)
					grid.gapRow = Std.parseFloat(guideFast.att.gapRow);
				if(guideFast.has.alignment)
					grid.setAlignment(guideFast.att.alignment);
				grid;
			case "curve":
				var curve = new Curve();
				if(guideFast.has.radius)
					curve.radius = Std.parseFloat(guideFast.att.radius);
				if(guideFast.has.minAngle)
					curve.minAngle = Std.parseFloat(guideFast.att.minAngle);
				if(guideFast.has.maxAngle)
					curve.maxAngle = Std.parseFloat(guideFast.att.maxAngle);
				if(guideFast.has.centerObject)
					curve.centerObject = guideFast.att.centerObject == "true";
				curve;
			default: throw "[GuideFactory] " + guideType + ": Unsupported guide type";
		}
		if(guideFast.has.transitionIn)
			creation.transitionIn = guideFast.att.transitionIn;

		return creation;
	}

	public static function createGuideFromXml(xml:Fast):Guide
	{
		return createGuide(xml.att.type, xml);
	}
}