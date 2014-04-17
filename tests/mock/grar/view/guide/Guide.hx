package grar.view.guide;

import grar.view.guide.Line;
import grar.view.guide.Grid;
import grar.view.guide.Curve;

enum GuideData {

    Line(d : LineData);
    Curve(d : CurveData);
}

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
        return 0;
    }

    public function set_y(v : Float) : Float {
        return 0;
    }
    /**
	 * Add an object to the guide
	 * @param object :   Object to add
	 * @param withTween  :   Play a tween when adding. Override properties transitionIn
	 * @return the added object
	 **/
    public function add(object : Element) : Element { return null; }


}