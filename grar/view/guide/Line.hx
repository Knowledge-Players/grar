package grar.view.guide;

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
class Line extends Guide {

	//public function new(start: Point, end: Point, centerObject: Bool = false, ?transitionIn: String)
	public function new(d : LineData) {

		super();
		
		startPoint = new Point(d.start[0],d.start[1]);
		endPoint = new Point(d.end[0],d.end[1]);
		objects = new Array();
		this.transitionIn = d.transitionIn;
	}

	private var startPoint: Point;
	private var endPoint: Point;
	private var nextPoint: Point;
	private var objects: Array<DisplayObject>;
	private var center: Bool;


	///
	// GETTER / SETTER
	//

	override public function set_x(x : Float) : Float {

		startPoint.x = x;
		return this.x = x;
	}

	override public function set_y(y : Float) : Float {

		startPoint.y = y;
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
		if (tween != null) {

//			TweenManager.applyTransition(object, tween);
			onTransitionRequested(object, tween);
		
		} else if(transitionIn != null) {

//			TweenManager.applyTransition(object, transitionIn);
			onTransitionRequested(object, transitionIn);
		}

		return object;
	}

	private function getFragment(p1:Point, p2:Point, numFragment:Int):Point
	{
		return new Point((p2.x-p1.x)/numFragment, (p2.y-p1.y)/numFragment);
	}

}