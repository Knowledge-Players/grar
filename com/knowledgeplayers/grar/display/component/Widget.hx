package com.knowledgeplayers.grar.display.component;

import motion.actuators.GenericActuator;
import haxe.xml.Fast;
import nme.events.Event;
import nme.display.Bitmap;
import nme.geom.Matrix;
import nme.display.BitmapData;
import nme.display.Sprite;

/**
* Base class for all graphical elements
**/
class Widget extends Sprite{

	/**
	* Scale of the widget
	**/
	public var scale (default, set_scale):Float;

	/**
    * Reference of the widget
    **/
	public var ref (default, default):String;

	/**
	* Transition when the widget appears
	**/
	public var transitionIn (default, set_transitionIn):String;

	/**
	* Transition when the widget disappears
	**/
	public var transitionOut (default, set_transitionOut):String;

	/**
	* Function to execute after transitionIn
	**/
	public var onComplete (default, default):Void -> Void;

	/**
    * Mirror
    **/
	public var mirror (default, set_mirror):Int;

	/**
	* Transformation to apply on widget
	**/
	public var transformation (default, set_transformation):String;

	private var targetWidth: Float;
	private var targetHeight: Float;
	private var origin: {x: Float, y: Float, scaleX: Float, scaleY: Float};

	public function set_scale(scale:Float):Float
	{
		return scaleX = scaleY = this.scale = scale;
	}

	public function set_mirror(mirror:Int):Int
	{
		var i;
		for(i in 0...numChildren){
			if(Std.is(getChildAt(i), Bitmap)){
				var original = cast(getChildAt(i), Bitmap).bitmapData;
				var flipped:BitmapData = new BitmapData(original.width, original.height, true, 0);
				var matrix:Matrix;
				if(mirror == 1){
					matrix = new Matrix( - 1, 0, 0, 1, original.width, 0);
				} else {
					matrix = new Matrix( 1, 0, 0, - 1, 0, original.height);
				}
				flipped.draw(original, matrix, null, null, null, true);
				cast(getChildAt(i), Bitmap).bitmapData = flipped;
			}
		}
		return mirror;
	}

	public function set_transformation(transformation: String):String
	{
		TweenManager.applyTransition(this, transformation);
		return this.transformation = transformation;
	}

	public function set_transitionIn(transition:String):String
	{
		addEventListener(Event.ADDED_TO_STAGE, function(e:Event)
		{
			origin = {x: x, y: y, scaleX: scaleX, scaleY: scaleY};
			var actuator: IGenericActuator = TweenManager.applyTransition(this, transition);
			if(actuator != null && onComplete != null)
				actuator.onComplete(onComplete);
		});

		return transitionIn = transition;
	}

	public function set_transitionOut(transition:String):String
	{
		addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
		{
			var actuator: IGenericActuator = TweenManager.applyTransition(this, transition);
			if(actuator != null)
				actuator.onComplete(reset);
			else
				reset();
		});
		return transitionOut = transition;
	}

	public function initSize():Void
	{
		if(width != 0)
			width = targetWidth;
		if(height != 0)
			height = targetHeight;
	}

	override public function toString():String
	{
		return '$ref: $x;$y $width x $height ($scale) $transitionIn->$transitionOut';
	}

	// Privates

	private function new(?xml: Fast)
	{
		super();
		if(xml != null){
			if(!xml.has.ref)
				throw Type.getClassName(Type.getClass(this))+" must have a ref attribute: "+xml;
			else
				ref = xml.att.ref;
			if(xml.has.x)
				x = Std.parseFloat(xml.att.x);
			if(xml.has.y)
				y = Std.parseFloat(xml.att.y);
			if(xml.has.scale)
				scale = Std.parseFloat(xml.att.scale);
			else
				scale = 1;

			if(xml.has.width)
				targetWidth = Std.parseFloat(xml.att.width);
			else if(xml.has.scaleX)
				scaleX = Std.parseFloat(xml.att.scaleX);
			if(xml.has.height)
				targetHeight = Std.parseFloat(xml.att.height);
			else if(xml.has.scaleY)
				scaleY = Std.parseFloat(xml.att.scaleY);

			transitionIn = xml.has.transitionIn ? xml.att.transitionIn : "";
			transitionOut = xml.has.transitionOut ? xml.att.transitionOut : "";

			if(xml.has.rotation)
				rotation = Std.parseFloat(xml.att.rotation);
			if(xml.has.transformation)
				transformation = xml.att.transformation;
		}
	}

	private function reset(): Void
	{
		for(field in Reflect.fields(origin))
			Reflect.setField(this, field, Reflect.field(origin, field));
	}

}
