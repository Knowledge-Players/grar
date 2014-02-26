package com.knowledgeplayers.grar.util.guide;

import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.display.component.TileImage;
import flash.display.DisplayObject;
import flash.geom.Point;

/**
* Utility to place items on a line
**/
class Line implements Guide
{
	/**
    * X of the grid
    **/
	public var x (default, set_x):Float;
	/**
    * Y of the grid
    **/
	public var y (default, set_y):Float;

	public var transitionIn (default, default):String;

	private var startPoint: Point;
	private var endPoint: Point;
	private var nextPoint: Point;
	private var objects: List<DisplayObject>;
	private var center: Bool;

	/**
	* Constructor
	* @param    start: Start point of the line
	* @param    end: End point of the line
	* @param    centerObject:  Place center of the object on the curve instead of the top left corner. Default is false
	**/
	public function new(start: Point, end: Point, centerObject: Bool = false, ?transitionIn: String)
	{
		startPoint = start;
		endPoint = end;
		objects = new List<DisplayObject>();
		this.transitionIn = transitionIn;
	}

	public function set_x(x:Float):Float
	{
		startPoint.x = x;
		return this.x = x;
	}

	public function set_y(y:Float):Float
	{
		startPoint.y = y;
		return this.y = y;
	}

	/**
	* @inherits
	**/
	public function add(object:DisplayObject, ?tween:String, tile: Bool = false):DisplayObject
	{
		objects.add(object);
		var step = getFragment(startPoint, endPoint, objects.length+1);
		nextPoint = startPoint;
		for(obj in objects){
			nextPoint = nextPoint.add(step);
			if(tile){
				cast(obj, TileImage).set_x(nextPoint.x + (center ? obj.width/2 : 0));
				cast(obj, TileImage).set_y(nextPoint.y + (center ? obj.height/2 : 0));
			}
			else{
				obj.x = nextPoint.x + (center ? obj.width/2 : 0);
				obj.y = nextPoint.y + (center ? obj.height/2 : 0);
			}
		}
		if(tween != null)
			TweenManager.applyTransition(object, tween);
		else if(transitionIn != null)
			TweenManager.applyTransition(object, transitionIn);

		return object;
	}

	private function getFragment(p1:Point, p2:Point, numFragment:Int):Point
	{
		return new Point((p2.x-p1.x)/numFragment, (p2.y-p1.y)/numFragment);
	}

	public function getAllObjects():List<DisplayObject>
	{
		return objects;
	}

}