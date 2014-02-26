package com.knowledgeplayers.grar.util.guide;

import flash.display.DisplayObject;

interface Guide{
	/**
    * X of the guide
    **/
	public var x (default, set_x):Float;
	/**
    * Y of the guide
    **/
	public var y (default, set_y):Float;

	/**
	* Reference to the transition played when an item is added to the grid.
	**/
	public var transitionIn (default, default):String;
	/**
	* Add an object to the guide
	* @param object :   Object to add
	* @param withTween  :   Play a tween when adding. Override properties transitionIn
	* @return the added object
	**/
	public function add(object:DisplayObject, ?tween:String, tile: Bool = false):DisplayObject;

	public function getAllObjects():List<DisplayObject>;
}