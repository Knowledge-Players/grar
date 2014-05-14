package grar.view.guide;

import js.html.Element;

class Guide {

	public function new() {
	}

	/**
     * X of the guide
     **/
	public var x (default, set) : Float;

	/**
     * Y of the guide
     **/
	public var y (default, set) : Float;


	///
	// GETTER / SETTER
	//

	public function set_x(v : Float) : Float {

		x = v;

		return x;
	}

	public function set_y(v : Float) : Float {

		y = v;

		return y;
	}


	///
	// API
	//

	/**
	 * Add an object to the guide
	 * @param object :   Object to add
	 * @param withTween  :   Play a tween when adding. Override properties transitionIn
	 * @return the added object
	 **/
	public function add(object : Element) : Element { return null; }

	///
	// Internals
	//

	private function setCoordinates(obj: Element, x: Float, y: Float):Void
	{
		obj.style.position = "absolute";
		obj.style.left = Std.string(x)+"px";
		obj.style.top = Std.string(y)+"px";
	}
}