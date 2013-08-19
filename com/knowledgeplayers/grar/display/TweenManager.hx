package com.knowledgeplayers.grar.display;

import nme.Lib;
import motion.actuators.GenericActuator.IGenericActuator;
import nme.display.Sprite;
import nme.geom.ColorTransform;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import motion.easing.Cubic;
import motion.Actuate;
import motion.actuators.GenericActuator;

import motion.easing.IEasing;

import motion.easing.Linear;
import motion.easing.Cubic;
import motion.easing.Back;
import motion.easing.Bounce;
import motion.easing.Elastic;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;

import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.events.Event;

/**
 * Manage the most frequently used tweens
 */
class TweenManager {

	private static var transitions:Map<String, Dynamic> = new Map<String, Dynamic>();
	private static var discovering:{display:Sprite, ref:String};

	/**
    * Apply the given transition to the given displayObject
    * @param    display : Target of the tween
    * @param   ref : The name of the fade transition to applied
    * @return the actuator
    **/

	public static function applyTransition(display:Dynamic, refs:String):Null<IGenericActuator>
	{
		var transition:IGenericActuator = null;

		if(refs != null){

			var arrayRef:Array<String> = refs.split(",");
			for(i in 0...arrayRef.length){
				transition = startTransition(display, arrayRef[i]);
			}

		}

		return transition;
	}

	private static function startTransition(display:Dynamic, ref:String):Null<IGenericActuator>
	{
		var transition = transitions.get(ref);

		if(transition == null)
			return null;

		if(Reflect.hasField(transition, "alpha"))
			return fade(display, ref).delay(transition.delay);
		else if(Reflect.hasField(transition, "width"))
			return zoom(display, ref).delay(transition.delay);
		else if(Reflect.hasField(transition, "color") && Reflect.hasField(transition, "repeat"))
			return blink(display, ref).delay(transition.delay);
		else if(Reflect.hasField(transition, "color"))
			return transform(display, ref).delay(transition.delay);
		else if(Reflect.hasField(transition, "repeat"))
			return wiggle(display, ref).delay(transition.delay);
		else if(Reflect.hasField(transition, "shutterTransitions"))
			return discover(display, ref, 0).delay(transition.delay);
		else
			return slide(display, ref).delay(transition.delay);
	}

	/**
     * Get a discover in effect for the object
     * @param	display : Target of the tween
     * @param   ref : The name of the fade transition to applied
     * @return the actuator
     **/

	public static function discover(display:Dynamic, ref:String, it:Int):IGenericActuator
	{
		var mask: Sprite = cast(cast(display, Sprite).mask, Sprite);
		if(it < mask.numChildren){

			discovering = {display: mask, ref: ref};

			for(i in 0...mask.numChildren){
				if(i >= it){
					mask.getChildAt(i).scaleX = 0;
					mask.getChildAt(i).scaleY = 0;
				}
			}

			var shutter = transitions.get(ref);

			var type = shutter.shutterTransitions[Std.int(it % shutter.shutterTransitions.length)];

			var msk = mask.getChildAt(it);

			switch (type.toLowerCase()) {
				case "left" :

					msk.scaleY = 1;
					return Actuate.tween(msk, shutter.duration, { scaleX : 1 }).ease(Linear.easeNone).onComplete(discover, [display, ref, it + 1]);
				case "right" :
					msk.scaleY = 1;
					msk.scaleX = 1;
					msk.x = msk.width;
					msk.scaleX = 0;
					return Actuate.tween(msk, shutter.duration, { x : 0, scaleX : 1 }).ease(Linear.easeNone).onComplete(discover, [display, ref, it + 1]);
				case "up" :
					msk.scaleX = 1;
					return Actuate.tween(msk, shutter.duration, { scaleY : 1 }).ease(Linear.easeNone).onComplete(discover, [display, ref, it + 1]);
				case "down" :
					msk.scaleX = 1;
					msk.scaleY = 1;
					var h = msk.height;
					msk.y += msk.height;
					msk.scaleY = 0;
					return Actuate.tween(msk, shutter.duration, { y : msk.y - h, scaleY : 1 }).ease(Linear.easeNone).onComplete(discover, [display, ref, it + 1]);
				default :
					return new GenericActuator(display, 0, {});

			}

		}
		else{
			// Element is scrollable. Can't use discover
			discovering = null;
			for(i in 0...mask.numChildren){
				mask.getChildAt(i).scaleX = 1;
				mask.getChildAt(i).scaleY = 1;
			}
			return new GenericActuator(display, 0, {});
		}
	}

    public static function createTransition(display:Dynamic,duration:Float,params:Dynamic):IGenericActuator{


        return Actuate.tween(display, duration, params);

    }
	public static function fastForwardDiscover():Void
	{
		if(discovering != null){
			for(i in 0...discovering.display.numChildren)
				stop(discovering.display.getChildAt(i), null, true);
		}
		// Double if to prevent discovering from being null after a key press during the execution
		if(discovering != null)
			discover(discovering.display, discovering.ref, discovering.display.numChildren);
	}

	/**
     * Get a fade in effect for the object
     * @param	display : Target of the tween
     * @param   ref : The name of the fade transition to applied
     * @return the actuator
     **/

	public static function fade(display:Dynamic, ref:String):IGenericActuator
	{
		var fade = transitions.get(ref);
		var inOut = parseValue("alpha", fade.alpha, display);

		display.alpha = inOut[0];
		return Actuate.tween(display, fade.duration, { alpha: inOut[1] }).autoVisible(false).ease(getEasing(fade));
	}

	/**
    * Get a wiggle effect for the object
    * @param    display : Target of the tween
    * @param    ref : The name of the fade transition to applied
    * @return the actuator
    **/

	public static function wiggle(display:Dynamic, ref:String):IGenericActuator
	{
		var wiggle = transitions.get(ref);
		var inOutX = parseValue("x", wiggle.x, display);
		var inOutY = parseValue("y", wiggle.y, display);
		display.x = inOutX[0];
		display.y = inOutY[0];
		var repeat = wiggle.repeat % 2 == 0 ? wiggle.repeat + 1 : wiggle.repeat;
		return Actuate.tween(display, wiggle.duration, {x: inOutX[1], y: inOutY[1]}).repeat(repeat).reflect();
	}

	/**
    * Get a zoom effect for the object
    * @param    display : Target of the tween
    * @param    ref : The name of the fade transition to applied
    * @return the actuator
    **/

	public static function zoom(display:Dynamic, ref:String):IGenericActuator
	{
		var zoom = transitions.get(ref);

		var inOutX = parseValue("x", zoom.x, display);
		var inOutY = parseValue("y", zoom.y, display);
		var inOutWidth = parseValue("width", zoom.width, display);
		var inOutHeight = parseValue("height", zoom.height, display);

		display.x = inOutX[0];
		display.y = inOutY[0];
		display.width = inOutWidth[0];
		display.height = inOutHeight[0];
		if(Reflect.hasField(display, "scale"))
			return Actuate.tween(display, zoom.duration, {x: inOutX[1], y: inOutY[1], scale: inOutHeight[1] / inOutHeight[0]}).ease(getEasing(zoom));
		else
			return Actuate.tween(display, zoom.duration, {x: inOutX[1], y: inOutY[1], width: inOutWidth[1], height: inOutHeight[1]}).ease(getEasing(zoom));
	}

	/**
     * Translate the object
     * @param	display : Target of the tween
     * @param    ref : The name of the fade transition to applied
     * @return the actuator
     */

	public static function slide(display:Dynamic, ref:String):IGenericActuator
	{
		var slide = transitions.get(ref);

		var inOutX = parseValue("x", slide.x, display);
		var inOutY = parseValue("y", slide.y, display);
		display.x = inOutX[0];
		display.y = inOutY[0];
		return Actuate.tween(display, slide.duration, {x: inOutX[1], y: inOutY[1]}).ease(getEasing(slide));
	}



	public static function transform(display:Dynamic, ref:String):IGenericActuator
	{
		var transform = transitions.get(ref);

		return Actuate.transform(display, transform.duration).color(transform.color).ease(getEasing(transform));
	}

	public static function resetTransform(display:Dynamic):Void
	{
		display.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
	}

	public static function blink(display:Dynamic, ref:String):IGenericActuator
	{

        trace("blink : "+display);
		var blink = transitions.get(ref);
		var repeat = blink.repeat % 2 == 0 ? blink.repeat + 1 : blink.repeat;
		return Actuate.transform(display, blink.duration).color(blink.color).repeat(repeat).reflect();
	}

	public static function stop(target:Dynamic, properties:Dynamic = null, complete:Bool = false, sendEvent:Bool = true):Void
	{
		Actuate.stop(target, properties, complete, sendEvent);
	}

	/**
    * Load an XML file with transitions templates
    * @param    file : Path to the file
    **/

	public static function loadTemplate(file:String):Void
	{
		var root = new Fast(AssetsStorage.getXml(file)).node.Transitions;
		for(child in root.elements){
			var transition:Dynamic = {};
			transition.duration = Std.parseFloat(child.att.duration);

            if(child.has.delay){
                transition.delay = Std.parseInt(child.att.delay);
            }
            else{
                transition.delay = 0;
            }
			if(child.has.easingType){
				transition.easingType = child.att.easingType.toLowerCase();
				transition.easingStyle = child.att.easingStyle.toLowerCase();
			}
			switch(child.name.toLowerCase()){
				case "zoom":
					transition.x = child.att.x;
					transition.y = child.att.y;
					transition.width = child.att.width;
					transition.height = child.att.height;
				case "wiggle":
					transition.repeat = Std.parseInt(child.att.repeat);
					transition.x = child.att.x;
					transition.y = child.att.y;
				case "fade":
					transition.alpha = child.att.alpha;
				case "slide":
					transition.x = child.att.x;
					transition.y = child.att.y;
				case "blink":
					transition.color = Std.parseInt(child.att.color);
					transition.repeat = Std.parseInt(child.att.repeat);
				case "transform":
					transition.color = Std.parseInt(child.att.color);
				case "mask":
					transition.shutterTransitions = child.att.shutterTransitions.split(",");
					transition.shutterChaining = child.att.shutterChaining;
			}
			transitions.set(child.att.ref, transition);
		}
	}

	// Private

	private static function getEasing(transition:Dynamic):IEasing
	{
		if(Reflect.hasField(transition, "easingType")){
			var easingType = transition.easingType.charAt(0).toUpperCase() + transition.easingType.substr(1).toLowerCase();
			var easingStyle = "Ease" + transition.easingStyle.charAt(0).toUpperCase() + transition.easingStyle.substr(1).toLowerCase();

			return Type.createEmptyInstance(Type.resolveClass("motion.easing." + easingType + easingStyle));
		}
		else{
			return Linear.easeNone;

		}
	}

	private static function parseValue(parameter:String, value:String, display:Dynamic):Array<Float>
	{
		var inOut:Array<String> = value.split(":");
		var output:Array<Float> = new Array<Float>();

		var ereg:EReg = new EReg(parameter + "([+*/-])([0-9]+\\.?[0-9]*)", "i");
		for(val in inOut){
			if(ereg.match(val)){
				switch(ereg.matched(1)){
					case "+" : output.push(Reflect.getProperty(display, parameter) + Std.parseFloat(ereg.matched(2)));
					case "-" : output.push(Reflect.getProperty(display, parameter) - Std.parseFloat(ereg.matched(2)));
					case "*" : output.push(Reflect.getProperty(display, parameter) * Std.parseFloat(ereg.matched(2)));
					case "/" : output.push(Reflect.getProperty(display, parameter) / Std.parseFloat(ereg.matched(2)));
				}
			}
			else if(val == parameter)
				output.push(Reflect.field(display, parameter));
			else
				output.push(Std.parseFloat(val));
		}

		// Not a FROM .. TO form, returning the only value
		if(output.length == 1){
			output.push(output[0]);
		}

		return output;
	}
}