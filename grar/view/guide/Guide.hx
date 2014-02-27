package grar.view.guide;

import motion.actuators.GenericActuator.IGenericActuator;

import grar.view.guide.Line;
import grar.view.guide.Grid;
import grar.view.guide.Curve;

import flash.display.DisplayObject;

enum GuideData {

	Line(d : LineData);
	Grid(d : GridData);
	Curve(d : CurveData);
}

class Guide {

	public function new() { }

	/**
     * X of the guide
     **/
	public var x (default, set) : Float;

	/**
     * Y of the guide
     **/
	public var y (default, set) : Float;

	/**
	 * Reference to the transition played when an item is added to the grid.
	 **/
	public var transitionIn (default, default) : String;


	///
	// CALLBACKS
	//

	public dynamic function onTransitionRequested(target : Dynamic, transition : String, ? delay : Float = 0) : IGenericActuator { return null; }

	public dynamic function onStopTransitionRequested(target : Dynamic, ? properties : Null<Dynamic>, ? complete : Bool = false, ? sendEvent : Bool = true) : Void {  }


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
	public function add(object : DisplayObject, ? tween : String, tile : Bool = false) : DisplayObject { return null; }
}