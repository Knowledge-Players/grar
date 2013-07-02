package com.knowledgeplayers.grar.structure.activity.scanner;

import haxe.ds.GenericStack;
import haxe.xml.Fast;
import nme.geom.Point;

class Scanner extends Activity {
/**
    * Elements of the activity
    **/
    public var elements (default, null):Array<ScannerPoint>;

	public var pointVisible (default, default):Bool;

	public function new(content:String)
	{
        elements = new Array<ScannerPoint>();
		super(content);
	}

	public override function toString():String
	{
		return elements.toString();
	}

	// Private

	override private function parseContent(content:Xml):Void
	{
        super.parseContent(content);
		var fast = new Fast(content).node.Scanner;
		pointVisible = fast.att.pointVisible == "true";
		for(point in fast.nodes.Point){
            var elem = new ScannerPoint(Std.parseFloat(point.att.x), Std.parseFloat(point.att.y), point.att.ref, point.att.text, point.att.content);
			elements.push(elem);
		}
	}

}
