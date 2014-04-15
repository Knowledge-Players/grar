package grar.view.guide;

import util.Point;
import js.html.Element;

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

	public function new( d : LineData) {

		super();

		startPoint = new Point(d.start[0], d.start[1]);
		endPoint = new Point(d.end[0], d.end[1]);
		objects = new Array();
	}

	private var startPoint: Point;
	private var endPoint: Point;
	private var nextPoint: Point;
	private var objects: Array<Element>;
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
	override public function add(object:Element):Element
	{
		objects.push(object);
		var step = getFragment(startPoint, endPoint, objects.length+1);
		nextPoint = startPoint;
		for(obj in objects){
			nextPoint = nextPoint.add(step);
			var rect = obj.getBoundingClientRect();
			setCoordinates(obj, (nextPoint.x + (center ? rect.width/2 : 0)), (nextPoint.y + (center ? rect.height/2 : 0)));
		}

		return object;
	}

	private function getFragment(p1:Point, p2:Point, numFragment:Int):Point
	{
		return new Point((p2.x-p1.x)/numFragment, (p2.y-p1.y)/numFragment);
	}

}