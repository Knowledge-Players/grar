package grar.view.guide;

// FIXME import com.knowledgeplayers.grar.display.TweenManager;
import grar.view.component.TileImage;

import flash.display.DisplayObject;
import flash.geom.Point;

typedef LineData = {

	var start : Array<Int>;
	var end : Array<Int>;
	var center : Null<Bool>;
	var transitionIn : Null<String>;
}

/**
* Utility to place items on a line
**/
class Line implements Guide {

	//public function new(start: Point, end: Point, centerObject: Bool = false, ?transitionIn: String)
	public function new(d : LineData) {

		startPoint = new Point(d.start[0],d.start[1]);
		endPoint = new Point(d.end[0],d.end[1]);
		objects = new Array();
		this.transitionIn = d.transitionIn;
	}
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
	private var objects: Array<DisplayObject>;
	private var center: Bool;

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
// FIXME		if(tween != null)
// FIXME			TweenManager.applyTransition(object, tween);
// FIXME		else if(transitionIn != null)
// FIXME			TweenManager.applyTransition(object, transitionIn);

		return object;
	}

	private function getFragment(p1:Point, p2:Point, numFragment:Int):Point
	{
		return new Point((p2.x-p1.x)/numFragment, (p2.y-p1.y)/numFragment);
	}

}