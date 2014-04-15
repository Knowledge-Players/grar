package grar.view.guide;

import util.Point;
import grar.util.MathUtils;

import js.html.Element;

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
	public function new(d : CurveData) {

		super();

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

	private var objects: Array<Element>;
	private var objToAngles : Map<Element, Float>;


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
	override public function add(object:Element):Element
	{
		objects.push(object);
		var angle = (maxAngle - minAngle)/(2*objects.length);
		for(i in 0...objects.length){
			var obj = objects[i];
			var rect = obj.getBoundingClientRect();
			var a = MathUtils.degreeToRad(angle+(angle*2*i)+minAngle);
			setCoordinates(obj, (Math.cos(a)*radius + center.x - (centerObject ? rect.width/2 : 0)), (Math.sin(a)*radius + center.y - (centerObject ? rect.height/2 : 0)));
			objToAngles.set(objects[i], a);
		}

		return object;
	}

	/**
	* Get an angle associated with an object
	* @param obj    :   Desired object
	* @return the angle for this object
	**/
	public function getAngle(obj: Element): Float
	{
		return objToAngles[obj];
	}

	/**
	* @return true if the object is in the curve
	**/
	public function contains(obj: Element): Bool
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
		objects = new Array<Element>();
	}

	public function toString():String
	{
		return 'Curve: center ('+center.x+';'+center.y+') radius '+radius+' angles '+minAngle+'-'+maxAngle+' '+objects.length+' children';
	}
}
