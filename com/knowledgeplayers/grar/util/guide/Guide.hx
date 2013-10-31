package com.knowledgeplayers.grar.util.guide;

import flash.display.DisplayObject;

interface Guide{
	/**
	* Add an object to the guide
	* @param object :   Object to add
	* @param withTween  :   Play a tween when adding. Default is true
	* @return the added object
	**/
	public function add(object:DisplayObject, withTween: Bool = true):DisplayObject;
}