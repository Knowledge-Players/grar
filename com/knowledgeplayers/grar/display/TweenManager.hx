package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.grar.util.ParseUtils;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import motion.actuators.GenericActuator.IGenericActuator;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import motion.Actuate;
import motion.actuators.GenericActuator;

import motion.easing.IEasing;

// Let them all
import motion.easing.Linear;
import motion.easing.Cubic;
import motion.easing.Back;
import motion.easing.Bounce;
import motion.easing.Elastic;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;
////

import haxe.xml.Fast;
import flash.display.DisplayObject;

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

	public static function applyTransition(display:Dynamic, refs:String,delay:Float=0):Null<IGenericActuator>
	{
		var transition:IGenericActuator = null;

		if(refs != null && display != null){
			var arrayRef:Array<String> = ParseUtils.parseListOfValues(refs);
			for(ref in arrayRef){
				transition = startTransition(display, ref,delay);
			}
		}

		return transition;
	}

	private static function startTransition(display:Dynamic, ref:String,delay:Float=0):Null<IGenericActuator>
	{
		var transition = transitions.get(ref);

		if(transition == null)
			return null;
        var totalDelay:Float = delay + transition.delay;

		stop(display, true, true);

		// TODO use transition as parameter instead of ref
		var actuator: IGenericActuator;
		if(Reflect.hasField(transition, "alpha"))
			actuator = fade(display, ref);
		else if(Reflect.hasField(transition, "width"))
			actuator = zoom(display, ref);
		else if(Reflect.hasField(transition, "color"))
			actuator = transform(display, ref);
		else if(Reflect.hasField(transition, "shutterTransitions"))
			actuator = discover(display, ref, 0);
        else if(Reflect.hasField(transition, "rotation"))
			actuator = rotate(display, ref);
		else
			actuator = slide(display, ref);

        actuator.delay(totalDelay);
		if(transition.repeat != null)
			actuator.repeat(transition.repeat);
		if(transition.reflect != null && transition.reflect)
			actuator.reflect();

		return actuator;
	}

	/**
	 * Creates a new tween
	 * @param	target		The object to tween
	 * @param	duration		The length of the tween in seconds
	 * @param	properties		The end values to tween the target to
	 * @param	overwrite			Sets whether previous tweens for the same target and properties will be overwritten (Default is true)
	 * @param	customActuator		A custom actuator to use instead of the default (Optional)
	 * @return		The current actuator instance, which can be used to apply properties like ease, delay, onComplete or onUpdate
	 */
	public static function tween (target:Dynamic, duration:Float, properties:Dynamic, overwrite:Bool = true, customActuator:Class <GenericActuator> = null):IGenericActuator
	{
		return Actuate.tween(target, duration, properties, overwrite, customActuator);
	}

	/**
     * Get a discover in effect for the object
     * @param	display : Target of the tween
     * @param   ref : The name of the fade transition to applied
     * @return the actuator
     **/

	public static function discover(display:Dynamic, ref:String, it:Int):IGenericActuator
	{
		var mask: Sprite;
		if(Std.is(display.parent, ScrollPanel))
			mask = display.getChildAt(1).mask;
		else
			mask = display.mask;

		if(mask == null)
			throw '[TweenManager] Can\'t play $ref on $display because it doesn\'t have a mask.';

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

    public static function createTransition(display:Dynamic,duration:Float,params:Dynamic):IGenericActuator
    {
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

    public static function rotate(display:Dynamic, ref:String):IGenericActuator
    {
        var rotate= transitions.get(ref);
        var inOutX = parseValue("x", rotate.x, display);
        var inOutY = parseValue("y", rotate.y, display);
        var inOutRotate = parseValue("rotation", rotate.rotation, display);
        display.x = inOutX[0];
        display.y = inOutY[0];
        display.rotation = inOutRotate[0];

        return Actuate.tween(display, rotate.duration, {x: inOutX[1], y: inOutY[1], rotation: inOutRotate[1]}).ease(getEasing(rotate)).smartRotation();
    }

	public static function transform(display:Dynamic, ref:String):IGenericActuator
	{
		var transform = transitions.get(ref);
        return Actuate.transform(display, transform.duration).color(ParseUtils.parseColor(transform.color).color,ParseUtils.parseColor(transform.color).alpha).ease(getEasing(transform));
	}

	public static function resetTransform(display:Dynamic):Void
	{
		display.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
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
			if(child.has.repeat)
				transition.repeat = Std.parseInt(child.att.repeat);
			if(child.has.reflect)
				transition.reflect = child.att.reflect == "true";

			switch(child.name.toLowerCase()){
				case "zoom":
					transition.x = child.has.x ? child.att.x : "x";
					transition.y = child.has.y ? child.att.y : "y";
					transition.width = child.has.width ? child.att.width : "width";
					transition.height = child.has.height ? child.att.height : "height";
				case "fade":
					transition.alpha = child.att.alpha;
				case "slide":
					transition.x = child.has.x ? child.att.x : "x";
					transition.y = child.has.y ? child.att.y : "y";
                case "rotate":
					transition.x = child.has.x ? child.att.x : "x";
					transition.y = child.has.y ? child.att.y : "y";
					transition.rotation = child.has.rotation ? child.att.rotation : "rotation";
				case "transform":
					transition.color = child.att.color;

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

		var ereg:EReg = new EReg(parameter + "([+*/-])(.+)", "i");
		for(val in inOut){
			if(ereg.match(val)){
				var result = switch(ereg.matched(1)){
					case "+" : Reflect.getProperty(display, parameter) + Reflect.hasField(display, ereg.matched(2)) ? Reflect.getProperty(display, ereg.matched(2)) : Std.parseFloat(ereg.matched(2));
					case "-" : Reflect.getProperty(display, parameter) - (Reflect.hasField(display, ereg.matched(2)) ? Reflect.getProperty(display, ereg.matched(2)) : Std.parseFloat(ereg.matched(2)));
					case "*" : Reflect.getProperty(display, parameter) * Std.parseFloat(ereg.matched(2));
					case "/" : Reflect.getProperty(display, parameter) / Std.parseFloat(ereg.matched(2));
					default: null;
				}
				output.push(result);
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