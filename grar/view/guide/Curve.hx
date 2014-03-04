package grar.view.guide;

import grar.view.component.TileImage;

import grar.util.MathUtils;

import flash.Lib;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.geom.Point;

typedef CurveData = {

	var radius : Null<Float>;
	var minAngle : Null<Float>;
	var maxAngle : Null<Float>;
	var centerObject : Null<Bool>;
	var transitionIn : Null<String>;
	@:optional var center : Null<Array<Int>>;
}

/**
* Utility to place items on a curve
**/
class Curve extends Guide
{

	//public function new(?center: Point, radius: Float = 1, minAngle: Float = 0, maxAngle: Float = 360, centerObject: Bool = false)
	public function new(callbacks : grar.view.DisplayCallbacks, d : CurveData) {

		super(callbacks);

		if (d.center != null) {

			this.center = new Point(d.center[0], d.center[1]);
		}
		this.radius = d.radius;
		this.minAngle = d.minAngle;
		this.maxAngle = d.maxAngle;
		this.centerObject = d.centerObject;

		this.objects = new Array();
		this.objToAngles = new Map();
	}

	/**
	* Upper value of the angle defining the curve
	**/
	public var maxAngle (default, default):Float;
	/**
	* Lesser value of the angle defining the curve
	**/
	public var minAngle (default, default):Float;
	/**
	* Center of the curve
	**/
	public var center (default, default):Point;
	/**
	* Radius of the curve
	**/
	public var radius (default, default):Float;
	/**
	* Center the object on the curve. Default is false
	**/
	public var centerObject (default, default):Bool;

	private var objects: Array<DisplayObject>;
	private var objToAngles : Map<DisplayObject, Float>;


	///
	// GETTER / SETTER
	//

	override public function set_x(x:Float):Float
	{
		center.x = x;
		return this.x = x;
	}

	override public function set_y(y:Float):Float
	{
		center.y = y;
		return this.y = y;
	}

	///
	// API
	//

	/**
	* @inherits
	**/
	override public function add(object:DisplayObject, ?tween:String, tile: Bool = false):DisplayObject
	{
		objects.push(object);
		var angle = (maxAngle - minAngle)/(2*objects.length);
		for(i in 0...objects.length){
			var a = MathUtils.degreeToRad(angle+(angle*2*i)+minAngle);
			if(tile){
				cast(objects[i], TileImage).set_x(Math.cos(a)*radius + center.x - (centerObject ? objects[i].width/2 : 0));
				cast(objects[i], TileImage).set_y(Math.sin(a)*radius + center.y - (centerObject ? objects[i].height/2 : 0));
			}
			else{
				objects[i].x = Math.cos(a)*radius + center.x - (centerObject ? objects[i].width/2 : 0);
				objects[i].y = Math.sin(a)*radius + center.y - (centerObject ? objects[i].height/2 : 0);
			}
			objToAngles.set(objects[i], a);
		}

		if (tween != null) {

// 			TweenManager.applyTransition(object, tween);
			onTransitionRequest(object, tween);
		
		} else if(transitionIn != null) {

// 			TweenManager.applyTransition(object, transitionIn);
			onTransitionRequest(object, transitionIn);
		}

		return object;
	}

	/**
	* Get an angle associated with an object
	* @param obj    :   Desired object
	* @return the angle for this object
	**/
	public function getAngle(obj: DisplayObject): Float
	{
		return objToAngles[obj];
	}

	/**
	* @return true if the object is in the curve
	**/
	public function contains(obj: DisplayObject): Bool
	{
		return objToAngles.exists(obj);
	}

	/**
	* Empty the curve
	**/
	public function flush():Void
	{
		for(obj in objects)
			obj = null;
		objects = new Array<DisplayObject>();
	}

	/**
	* Draw the curve for debugging purpose
	**/
	public function drawCurve():Void
	{
		var curve = new Shape();
		curve.graphics.lineStyle(2, 0);
		curve.graphics.moveTo(center.x+Math.cos(minAngle)*radius, center.y+Math.sin(minAngle)*radius);
		var segments:Int = 8;

		var theta:Float = (maxAngle-minAngle)/segments;
		var angle:Float = minAngle; // start drawing at angle ...

		var ctrlRadius:Float = radius/Math.cos(theta/2); // this gets the radius of the control point
		for (i in 0...segments) {
		// increment the angle
			angle += theta;
			var angleMid:Float = angle-(theta/2);
				// calculate our control point
			var cx:Float = center.x+Math.cos(angleMid)*(ctrlRadius);
			var cy:Float = center.y+Math.sin(angleMid)*(ctrlRadius);
				// calculate our end point
			var px:Float = center.x+Math.cos(angle)*radius;
			var py:Float = center.y+Math.sin(angle)*radius;
				// draw the circle segment
			curve.graphics.curveTo(cx, cy, px, py);
		}

		curve.graphics.moveTo(center.x-1, center.y-1);
		curve.graphics.lineTo(center.x+1, center.y+1);
		curve.graphics.moveTo(center.x-1, center.y+1);
		curve.graphics.lineTo(center.x+1, center.y-1);

		Lib.current.addChild(curve);
	}

	public function toString():String
	{
		return 'Curve: center ('+center.x+';'+center.y+') radius '+radius+' angles '+minAngle+'-'+maxAngle+' '+objects.length+' children';
	}
}
