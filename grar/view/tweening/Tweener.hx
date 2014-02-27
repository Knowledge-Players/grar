package grar.view.tweening;

import motion.Actuate;
import motion.actuators.GenericActuator;
import motion.actuators.GenericActuator.IGenericActuator;
import motion.easing.Linear;
import motion.easing.Cubic;
import motion.easing.Back;
import motion.easing.Bounce;
import motion.easing.Elastic;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;
import motion.easing.IEasing;

import aze.display.TileSprite;

import grar.view.component.container.ScrollPanel; // ugly

import grar.view.TransitionTemplate;

import grar.util.ParseUtils; // FIXME

import haxe.ds.StringMap;

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.geom.ColorTransform;

/**
 * Manage the most frequently used tweens
 */
class Tweener {

	public function new(t : StringMap<TransitionTemplate>) {

		this.transitions = t;
	}

	private var transitions : StringMap<TransitionTemplate>;

	private var discovering : { display : Sprite, ref : String };


	///
	// API
	//

	/**
    * Apply the given transition to the given displayObject
    * @param    display : Target of the tween
    * @param   ref : The name of the fade transition to applied
    * @return the actuator
    **/
	public function applyTransition(display : Dynamic, refs : String, ? delay : Float = 0) : Null<IGenericActuator> {

		var transition : IGenericActuator = null;

		if (refs != null && display != null) {

			var arrayRef : Array<String> = ParseUtils.parseListOfValues(refs);
			
			for (ref in arrayRef) {

				transition = startTransition(display, ref, delay);
			}
		}

		return transition;
	}

	public function fastForwardDiscover():Void
	{
		if(discovering != null){
			for(i in 0...discovering.display.numChildren)
				stop(discovering.display.getChildAt(i), null, true);
		}
		// Double if to prevent discovering from being null after a key press during the execution
		if(discovering != null)
			discover(discovering.display, discovering.ref, discovering.display.numChildren);
	}

	public function stop(target : Dynamic, properties : Dynamic = null, complete : Bool = false, sendEvent : Bool = true) : Void {

		Actuate.stop(target, properties, complete, sendEvent);
	}


	///
	// INTERNALS
	//

	private function startTransition(display : Dynamic, ref : String, delay : Float = 0) : Null<IGenericActuator> {

		var transition : Null<TransitionTemplate> = transitions.get(ref);

		if (transition == null) {

			return null;
		}
        var totalDelay : Float = delay + transition.delay;

		//stop(display, null, true, true);

		var actuator : IGenericActuator;

		switch (transition.type) {

			case Zoom(x, y, width, height):

				actuator = zoom(display, transition);

			case Fade(alpha):

				actuator = fade(display, transition);

			case Slide(x, y):

				actuator = slide(display, transition);

			case Rotate(x, y, r):

				actuator = rotate(display, transition);

			case Transform(color):

				actuator = transform(display, transition);

			case Mask(transitions, chaining):

				actuator = discover(display, ref, 0);

		}
        actuator.delay(totalDelay);

		if (transition.repeat != null) {

			actuator.repeat(transition.repeat);
		}
		if (transition.reflect != null && transition.reflect) {

			actuator.reflect();
		}

		return actuator;
	}

	/**
     * Get a fade in effect for the object
     * @param	display : Target of the tween
     * @param   ref : The name of the fade transition to applied
     * @return the actuator
     **/
	private function fade(display : Dynamic, t : TransitionTemplate) : IGenericActuator {

		switch (t.type) {

			case Fade(a):

				var inOut = parseValue("alpha", a, display);

				display.alpha = inOut[0];

				return Actuate.tween(display, t.duration, { alpha: inOut[1] }).autoVisible(false).ease(getEasing(t));

			default: throw "wrong TransitionTemplate type passed to Tweener.fade()";
		}

		return null;
	}

	/**
    * Get a zoom effect for the object
    * @param    display : Target of the tween
    * @param    ref : The name of the fade transition to applied
    * @return the actuator
    **/
	private function zoom(display : Dynamic, t : TransitionTemplate) : IGenericActuator {

		switch (t.type) {

			case Zoom(x, y, width, height):

				var inOutX = parseValue("x", x, display);
				var inOutY = parseValue("y", y, display);
				var inOutWidth = parseValue("width", width, display);
				var inOutHeight = parseValue("height", height, display);

				display.x = inOutX[0];
				display.y = inOutY[0];
				display.width = inOutWidth[0];
				display.height = inOutHeight[0];

				return Actuate.tween(display, t.duration, {x: inOutX[1], y: inOutY[1], width: inOutWidth[1], height: inOutHeight[1]}).ease(getEasing(t));

			default: throw "wrong TransitionTemplate type passed to Tweener.zoom()";
		}

		return null;
	}

	/**
     * Translate the object
     * @param	display : Target of the tween
     * @param    ref : The name of the fade transition to applied
     * @return the actuator
     */
	private function slide(display : Dynamic, t : TransitionTemplate) : IGenericActuator {

		switch (t.type) {

			case Slide(x, y):

				var inOutX = parseValue("x", x, display);
				var inOutY = parseValue("y", y, display);
				display.x = inOutX[0];
				display.y = inOutY[0];

				return Actuate.tween(display, t.duration, {x: inOutX[1], y: inOutY[1]}).ease(getEasing(t));

			default: throw "wrong TransitionTemplate type passed to Tweener.slide()";
		}

		return null;
	}

    private function rotate(display : Dynamic, t : TransitionTemplate) : IGenericActuator {

		switch (t.type) {

			case Rotate(x, y, r):

		        var inOutX = parseValue("x", x, display);
		        var inOutY = parseValue("y", y, display);
		        var inOutRotate = parseValue("rotation", r, display);
		        display.x = inOutX[0];
		        display.y = inOutY[0];
		        display.rotation = inOutRotate[0];

		        return Actuate.tween(display, t.duration, {x: inOutX[1], y: inOutY[1], rotation: inOutRotate[1]}).ease(getEasing(t)).smartRotation();

			default: throw "wrong TransitionTemplate type passed to Tweener.rotate()";
		}

		return null;
    }

	private function transform(display : Dynamic, t : TransitionTemplate) : IGenericActuator {

		switch (t.type) {

			case Transform(c):

				return Actuate.transform(display, t.duration).color(c.color,c.alpha).ease(getEasing(t));

			default: throw "wrong TransitionTemplate type passed to Tweener.transform()";
		}

		return null;
	}

	/**
     * Get a discover in effect for the object
     * @param	display : Target of the tween
     * @param   ref : The name of the fade transition to applied
     * @return the actuator
     **/
	private function discover(display : Dynamic, ref : String, it : Int) : IGenericActuator {

		var mask : Sprite;

		if (Std.is(display.parent, ScrollPanel)) {

			mask = display.getChildAt(1).mask;
		
		} else {

			mask = display.mask;
		}
		if (mask == null) {

			throw 'Can\'t play discover on $display because it doesn\'t have a mask.';
		}
		if (it < mask.numChildren) {

			discovering = { display: mask, ref: ref };

			for (i in 0...mask.numChildren) {

				if (i >= it) {

					mask.getChildAt(i).scaleX = 0;
					mask.getChildAt(i).scaleY = 0;
				}
			}

			var shutter = transitions.get(ref);

			switch (shutter.type) {

				case Mask(ts, _):

					var type = ts[Std.int(it % ts.length)];

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

				default: throw "wrong TransitionTemplate type passed to Tweener.discover()";
			}

		} else {

			// Element is scrollable. Can't use discover
			discovering = null;
			
			for (i in 0...mask.numChildren) {

				mask.getChildAt(i).scaleX = 1;
				mask.getChildAt(i).scaleY = 1;
			}

			return new GenericActuator(display, 0, {});
		}
	}

	private function getEasing(t : TransitionTemplate) : IEasing {

		if (t.easingType != null) {

			var easingType = t.easingType.charAt(0).toUpperCase() + t.easingType.substr(1).toLowerCase();
			var easingStyle = "Ease" + t.easingStyle.charAt(0).toUpperCase() + t.easingStyle.substr(1).toLowerCase();

			return Type.createEmptyInstance(Type.resolveClass("motion.easing." + easingType + easingStyle));
		
		} else {

			return Linear.easeNone;
		}
	}

	private function resetTransform(display:Dynamic):Void
	{
		display.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
	}

	private function parseValue(parameter:String, value:String, display:Dynamic):Array<Float>
	{
		var inOut:Array<String> = value.split(":");
		var output:Array<Float> = new Array<Float>();

		var ereg:EReg = new EReg(parameter + "([+*/-])(.+)", "i");
		for(val in inOut){
			if(ereg.match(val)){
				var result = switch(ereg.matched(1)){
					case "+" : Reflect.getProperty(display, parameter) + (Reflect.hasField(display, ereg.matched(2)) ? Reflect.getProperty(display, ereg.matched(2)) : Std.parseFloat(ereg.matched(2)));
					case "-" : Reflect.getProperty(display, parameter) - (Reflect.hasField(display, ereg.matched(2)) ? Reflect.getProperty(display, ereg.matched(2)) : Std.parseFloat(ereg.matched(2)));
					case "*" : Reflect.getProperty(display, parameter) * (Reflect.hasField(display, ereg.matched(2)) ? Reflect.getProperty(display, ereg.matched(2)) : Std.parseFloat(ereg.matched(2)));
					case "/" : Reflect.getProperty(display, parameter) / (Reflect.hasField(display, ereg.matched(2)) ? Reflect.getProperty(display, ereg.matched(2)) : Std.parseFloat(ereg.matched(2)));
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

    private function createTransition(display:Dynamic,duration:Float,params:Dynamic):IGenericActuator
    {
        return Actuate.tween(display, duration, params);
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
	private function tween (target:Dynamic, duration:Float, properties:Dynamic, overwrite:Bool = true, customActuator:Class <GenericActuator> = null):IGenericActuator
	{
		return Actuate.tween(target, duration, properties, overwrite, customActuator);
	}
}