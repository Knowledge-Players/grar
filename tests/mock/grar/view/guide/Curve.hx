package grar.view.guide;

import grar.util.Point;

typedef CurveData = {

    var radius : Null<Float>;
    var minAngle : Null<Float>;
    var maxAngle : Null<Float>;
    var centerObject : Null<Bool>;
    var transitionIn : Null<String>;
    @:optional var center : Null<Array<Int>>;
}

class Curve extends Guide
{
    public function new(d : CurveData) {
		super();
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

    public function getAngle(obj: Element): Float
    {
        return 0;
    }

    /**
	* @return true if the object is in the curve
	**/
    public function contains(obj: Element): Bool
    {
        return false;
    }

    /**
	* Empty the curve
	**/
    public function flush():Void
    {

    }

    public function toString():String
    {
        return null;
    }

}