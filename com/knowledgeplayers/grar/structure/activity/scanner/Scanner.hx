package com.knowledgeplayers.grar.structure.activity.scanner;

import haxe.ds.GenericStack;
import haxe.xml.Fast;
import nme.geom.Point;

class Scanner extends Activity {
	public var pointsMap (default, null):GenericStack<ScannerPoint>;
	public var pointVisible (default, default):Bool;

	public function new(content:String)
	{
		pointsMap = new GenericStack<ScannerPoint>();
		super(content);
	}

	public override function toString():String
	{
		return pointsMap.toString();
	}

	// Private

	override private function parseContent(content:Xml):Void
	{
		var fast = new Fast(content).node.Scanner;
		pointVisible = fast.att.pointVisible == "true";
		for(point in fast.nodes.Point){
			pointsMap.add(new ScannerPoint(Std.parseFloat(point.att.x), Std.parseFloat(point.att.y), point.att.ref, point.att.text, point.att.content));
		}
	}
}