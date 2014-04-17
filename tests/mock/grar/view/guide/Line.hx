package grar.view.guide;

import grar.util.Point;

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

		return this.x = x;
	}

	override public function set_y(y : Float) : Float {

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
		return object;
	}

}