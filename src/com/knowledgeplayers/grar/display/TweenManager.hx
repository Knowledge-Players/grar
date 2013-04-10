package com.knowledgeplayers.grar.display;

import Reflect;
import haxe.FastList;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.GenericActuator.IGenericActuator;
import com.eclecticdesignstudio.motion.easing.Cubic;
import com.eclecticdesignstudio.motion.easing.IEasing;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

/**
 * Manage the most frequently used tweens
 */
class TweenManager {

    private static var transitions:Hash<Dynamic> = new Hash<Dynamic>();
    //private static var ongoingTween: FastList<DisplayObject> = new FastList<DisplayObject>();

    /**
    * Apply the given transition to the given displayObject
    * @param    display : Target of the tween
    * @param   ref : The name of the fade transition to applied
    * @return the actuator
    **/

    public static function applyTransition(display:DisplayObject, ref:String):IGenericActuator
    {
        var transition = transitions.get(ref);
        if(transition == null)
            return null;

        if(Reflect.hasField(transition, "alpha"))
            return fade(display, ref);
        else if(Reflect.hasField(transition, "width"))
            return zoom(display, ref);
        else if(Reflect.hasField(transition, "xRange"))
            return wiggle(display, ref);
        else if(Reflect.hasField(transition, "color"))
            return blink(display, ref);
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
        var mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(display.x, display.y, display.width, display.height);
        mask.graphics.endFill();
        display.mask = mask;
        if(display.parent != null)
            display.parent.addChild(mask);
        return Actuate.tween(display, zoom.duration, {x: 2 * display.x - zoom.x, y: 2 * display.y - zoom.y, scaleX: display.width / zoom.width, scaleY: display.height / zoom.height}).ease(getEasing(zoom));
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

    public static function blink(display:DisplayObject, ref:String):IGenericActuator
    {
        var blink = transitions.get(ref);
        return Actuate.transform(display, blink.duration).color(blink.color).repeat(blink.repeat).reflect();
    }

    /**
    * Load an XML file with transitions templates
    * @param    file : Path to the file
    **/

    public static function loadTemplate(file:String):Void
    {

        XmlLoader.load(file, onTemplateLoaded, parseXml);

    }

    // Private

    private static function onTemplateLoaded(ev:Event):Void
    {
        parseXml(XmlLoader.getXml(ev));
    }

    private static function parseXml(xml:Xml):Void
    {
        var root = new Fast(xml).node.Transitions;
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
                    transition.width = Std.parseFloat(child.att.width);
                    transition.height = Std.parseFloat(child.att.height);
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
            }
            transitions.set(child.att.ref, transition);
        }
    }

    private static function getEasing(transition:Dynamic):IEasing
    {
        var easingType:String;
        var easingStyle:String;
        if(Reflect.hasField(transition, "easingType")){
            easingType = transition.easingType.charAt(0).toUpperCase() + transition.easingType.substr(1).toLowerCase();
            easingStyle = "Ease" + transition.easingStyle.charAt(0).toUpperCase() + transition.easingStyle.substr(1).toLowerCase();
        }
        else{
            easingType = "Linear";
            easingStyle = "EaseNone";
        }
        //var easingTest = Cubic.easeOut;
        var easing = Type.createEmptyInstance(Type.resolveClass("com.eclecticdesignstudio.motion.easing." + easingType + easingStyle));
        //var eas = Reflect.field(easing, easingStyle);
        return easing;
    }

    private static function parseValue(parameter:String, value:String, display:DisplayObject):Array<Float>
    {
        var inOut:Array<String> = value.split(":");
        var output:Array<Float> = new Array<Float>();

        var ereg:EReg = new EReg(parameter + "([+*/-])([0-9]+)", null);
        for(val in inOut){
            if(ereg.match(val)){
                switch(ereg.matched(1)){
                    case "+" : output.push(display.alpha + Std.parseFloat(ereg.matched(2)));
                    case "-" : output.push(display.alpha - Std.parseFloat(ereg.matched(2)));
                    case "*" : output.push(display.alpha * Std.parseFloat(ereg.matched(2)));
                    case "/" : output.push(display.alpha / Std.parseFloat(ereg.matched(2)));
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

        nme.Lib.trace(output);

        return output;
    }
}