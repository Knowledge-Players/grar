package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.utils.assets.AssetsStorage;
import nme.geom.ColorTransform;
import com.eclecticdesignstudio.motion.easing.Cubic;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.GenericActuator.IGenericActuator;

import com.eclecticdesignstudio.motion.easing.IEasing;

import com.eclecticdesignstudio.motion.easing.Linear;
import com.eclecticdesignstudio.motion.easing.Cubic;
import com.eclecticdesignstudio.motion.easing.Back;
import com.eclecticdesignstudio.motion.easing.Bounce;
import com.eclecticdesignstudio.motion.easing.Elastic;
import com.eclecticdesignstudio.motion.easing.Quad;
import com.eclecticdesignstudio.motion.easing.Quart;
import com.eclecticdesignstudio.motion.easing.Quint;
import com.eclecticdesignstudio.motion.easing.Sine;

import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.events.Event;

/**
 * Manage the most frequently used tweens
 */
class TweenManager {

	private static var transitions:Hash<Dynamic> = new Hash<Dynamic>();

	/**
    * Apply the given transition to the given displayObject
    * @param    display : Target of the tween
    * @param   ref : The name of the fade transition to applied
    * @return the actuator
    **/

	public static function applyTransition(display:DisplayObject, refs:String):Null<IGenericActuator>
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

	private static function startTransition(display:DisplayObject, ref:String):Null<IGenericActuator>
	{
		var transition = transitions.get(ref);
		if(transition == null)
			return null;

		if(Reflect.hasField(transition, "alpha"))
			return fade(display, ref);
		else if(Reflect.hasField(transition, "width"))
			return zoom(display, ref);
		else if(Reflect.hasField(transition, "color") && Reflect.hasField(transition, "repeat"))
			return blink(display, ref);
		else if(Reflect.hasField(transition, "color"))
			return transform(display, ref);
		else if(Reflect.hasField(transition, "repeat"))
			return wiggle(display, ref);
		else
			return slide(display, ref);
	}

	/**
     * Get a fade in effect for the object
     * @param	display : Target of the tween
     * @param   ref : The name of the fade transition to applied
     * @return the actuator
     **/

	public static function fade(display:DisplayObject, ref:String):IGenericActuator
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

	public static function wiggle(display:DisplayObject, ref:String):IGenericActuator
	{
		var wiggle = transitions.get(ref);
		var inOutX = parseValue("x", wiggle.x, display);
		var inOutY = parseValue("y", wiggle.y, display);
		display.x = inOutX[0];
		display.y = inOutY[0];
		return Actuate.tween(display, wiggle.duration, {x: inOutX[1], y: inOutY[1]}).repeat(wiggle.repeat).reflect();
	}

	/**
    * Get a zoom effect for the object
    * @param    display : Target of the tween
    * @param    ref : The name of the fade transition to applied
    * @return the actuator
    **/

	public static function zoom(display:DisplayObject, ref:String):IGenericActuator
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

	public static function slide(display:DisplayObject, ref:String):IGenericActuator
	{
		var slide = transitions.get(ref);

		var inOutX = parseValue("x", slide.x, display);
		var inOutY = parseValue("y", slide.y, display);
		display.x = inOutX[0];
		display.y = inOutY[0];
		return Actuate.tween(display, slide.duration, {x: inOutX[1], y: inOutY[1]}).ease(getEasing(slide));
	}

	public static function transform(display:DisplayObject, ref:String):IGenericActuator
	{
		var transform = transitions.get(ref);

		return Actuate.transform(display, transform.duration).color(transform.color).ease(getEasing(transform));
	}

	public static function resetTransform(display:DisplayObject):Void
	{
		var myTransform = new ColorTransform();

		myTransform.redMultiplier = 1;
		myTransform.greenMultiplier = 1;
		myTransform.blueMultiplier = 1;
		myTransform.redOffset = 0;
		myTransform.greenOffset = 0;
		myTransform.blueOffset = 0;

		display.transform.colorTransform = myTransform;

	}

	public static function blink(display:DisplayObject, ref:String):IGenericActuator
	{
		var blink = transitions.get(ref);
		return Actuate.transform(display, blink.duration).color(blink.color).repeat(blink.repeat).reflect();
	}

	public static function stop(display:DisplayObject, properties:Dynamic, complete:Bool, sendEvent:Bool):Void
	{
		Actuate.stop(display, properties, complete, sendEvent);
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

			return Type.createEmptyInstance(Type.resolveClass("com.eclecticdesignstudio.motion.easing." + easingType + easingStyle));
		}
		else{
			return Linear.easeNone;

		}
	}

	private static function parseValue(parameter:String, value:String, display:DisplayObject):Array<Float>
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