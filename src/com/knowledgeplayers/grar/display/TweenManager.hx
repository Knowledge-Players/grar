package com.knowledgeplayers.grar.display;

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

    private static var transitions: Hash<Dynamic> = new Hash<Dynamic>();

    /**
    * Apply the given transition to the given displayObject
    * @param    display : Target of the tween
    * @param   ref : The name of the fade transition to applied
    * @return the actuator
    **/

    public static function applyTransition(display: DisplayObject, ref: String): IGenericActuator
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
     */

    public static function fade(display: DisplayObject, ref: String): IGenericActuator
    {
        var fade = transitions.get(ref);
        if(fade.alpha > 0)
            display.alpha = 0;
        else
            display.alpha = 1;
        return Actuate.tween(display, fade.duration, { alpha: fade.alpha }).ease(getEasing(fade));
    }

    /**
    * Get a wiggle effect for the object
    * @param    display : Target of the tween
    * @param    ref : The name of the fade transition to applied
    * @return the actuator
**/

    public static function wiggle(display: DisplayObject, ref: String): IGenericActuator
    {
        var wiggle = transitions.get(ref);
        return Actuate.tween(display, wiggle.duration, {x: display.x + wiggle.xRange, y: display.y + wiggle.yRange}).repeat(wiggle.repeat).reflect();
    }

    /**
    * Get a zoom effect for the object
    * @param    display : Target of the tween
    * @param    ref : The name of the fade transition to applied
    * @return the actuator
**/

    public static function zoom(display: DisplayObject, ref: String): IGenericActuator
    {
        var zoom = transitions.get(ref);
        var mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(display.x, display.y, display.width, display.height);
        mask.graphics.endFill();
        display.mask = mask;
        if(display.parent != null)
            display.parent.addChild(mask);
        Lib.trace(display.width + "/" + zoom.width);
        Lib.trace(display.height + "/" + zoom.height);
        Lib.trace("targetX: " + (2 * display.x - zoom.x) + " TargetY: " + (2 * display.y - zoom.y) + " TargetScaleX: " + (display.width / zoom.width) + " TargetScaleY: " + (display.height / zoom.height));
        return Actuate.tween(display, zoom.duration, {x: 2 * display.x - zoom.x, y: 2 * display.y - zoom.y, scaleX: display.width / zoom.width, scaleY: display.height / zoom.height}).ease(getEasing(zoom));
    }

    /**
     * Translate the object
     * @param	display : Target of the tween
     * @param    ref : The name of the fade transition to applied
     * @return the actuator
     */

    public static function slide(display: DisplayObject, ref: String): IGenericActuator
    {
        var slide = transitions.get(ref);
        /*
        var origin = {x: display.x, y: display.y};
        display.x = slide.x;
        display.y = slide.y;
        return Actuate.tween(display, slide.duration, { x: origin.x, y: origin.y }).ease(getEasing(slide));
        */
        return Actuate.tween(display, slide.duration, { x: slide.x, y: slide.y }).ease(getEasing(slide));
    }

    public static function blink(display: DisplayObject, ref: String): IGenericActuator
    {
        var blink = transitions.get(ref);
        return Actuate.transform(display, blink.duration).color(blink.color).repeat(blink.repeat).reflect();
    }

    /**
    * Load an XML file with transitions templates
    * @param    file : Path to the file
**/

    public static function loadTemplate(file: String): Void
    {
        XmlLoader.load(file, onTemplateLoaded, parseXml);
    }

    // Private

    private static function onTemplateLoaded(ev: Event): Void
    {
        parseXml(XmlLoader.getXml(ev));
    }

    private static function parseXml(xml: Xml): Void
    {
        var root = new Fast(xml).node.Transitions;
        for(child in root.elements){
            var transition: Dynamic = {};
            transition.duration = Std.parseFloat(child.att.duration);
            if(child.has.easingType){
                transition.easingType = child.att.easingType.toLowerCase();
                transition.easingStyle = child.att.easingStyle.toLowerCase();
            }
            switch(child.name.toLowerCase()){
                case "zoom":
                    transition.x = Std.parseFloat(child.att.x);
                    transition.y = Std.parseFloat(child.att.y);
                    transition.width = Std.parseFloat(child.att.width);
                    transition.height = Std.parseFloat(child.att.height);
                case "wiggle":
                    transition.repeat = Std.parseInt(child.att.repeat);
                    transition.xRange = Std.parseFloat(child.att.xRange);
                    transition.yRange = Std.parseFloat(child.att.yRange);
                case "fade":
                    transition.alpha = Std.parseFloat(child.att.alpha);
                case "slide":
                    transition.x = Std.parseFloat(child.att.x);
                    transition.y = Std.parseFloat(child.att.y);
                case "blink":
                    transition.color = Std.parseInt(child.att.color);
                    transition.repeat = Std.parseInt(child.att.repeat);
            }
            transitions.set(child.att.ref, transition);
        }
    }

    private static function getEasing(transition: Dynamic): IEasing
    {
        var easingType: String;
        var easingStyle: String;
        if(Reflect.hasField(transition, "easingType")){
            easingType = transition.easingType.charAt(0).toUpperCase() + transition.easingType.substr(1).toLowerCase();
            easingStyle = "Ease" + transition.easingStyle.charAt(0).toUpperCase() + transition.easingStyle.substr(1).toLowerCase();
        }
        else{
            easingType = "Linear";
            easingStyle = "EaseNone";
        }
        var easingTest = Cubic.easeOut;
        var easing = Type.createEmptyInstance(Type.resolveClass("com.eclecticdesignstudio.motion.easing." + easingType + easingStyle));
        //var eas = Reflect.field(easing, easingStyle);
        return easing;
    }
}