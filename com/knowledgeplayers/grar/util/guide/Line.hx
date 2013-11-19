package com.knowledgeplayers.grar.util.guide;

import com.knowledgeplayers.grar.display.component.TileImage;
import flash.display.DisplayObject;
import flash.geom.Point;

/**
* Utility to place items on a line
**/
class Line implements Guide{

	private var startPoint: Point;
	private var endPoint: Point;
	private var nextPoint: Point;
	private var objects: Array<DisplayObject>;
	private var center: Bool;

	/**
	* Constructor
	* @param    start: Start point of the line
	* @param    end: End point of the line
	* @param    centerObject:  Place center of the object on the curve instead of the top left corner. Default is false
	**/
	public function new(start: Point, end: Point, centerObject: Bool = false)
	{
		startPoint = start;
		endPoint = end;
		objects = new Array<DisplayObject>();
	}

	/**
	* @inherits
	**/
	// TODO tweens
	public function add(object:DisplayObject, ?tween:String, tile: Bool = false):DisplayObject
	{
		objects.push(object);
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
		return object;
	}

	private function getFragment(p1:Point, p2:Point, numFragment:Int):Point
	{
		return new Point((p2.x-p1.x)/numFragment, (p2.y-p1.y)/numFragment);
	}

}