package com.knowledgeplayers.grar.structure.activity.scanner;

import nme.geom.Point;
class ScannerPoint extends Point {

	/**
    * Content of the point
**/
	public var content (default, default):String;

	/**
    * Reference of the point
**/
	public var ref (default, default):String;

	/**
    * Reference of the textfield where the content will be displayed
**/
	public var textRef (default, default):String;


    public var viewed:Bool;
	/**
    * Constructor
    * @param x : X of the point
    * @param y : Y of the point
    * @param content : Content of the point
**/

	public function new(x:Float, y:Float, ref:String, textRef:String, ?content:String)
	{
		super(x, y);
		this.ref = ref;
		this.textRef = textRef;
		this.content = content;
        this.viewed = false;
	}
}
