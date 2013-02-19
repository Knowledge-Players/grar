package com.knowledgeplayers.grar.display;
import nme.geom.Rectangle;
import browser.display.StageDisplayState;
import nme.display.Sprite;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.GenericActuator.IGenericActuator;
import com.eclecticdesignstudio.motion.easing.Cubic;
import nme.display.DisplayObject;
import nme.geom.Point;
import nme.Lib;

/**
 * Manage the most frequently used tweens
 */

class TweenManager {
    /**
     * Get a fade in effect for the object
     * @param	display : Target of the tween
     * @return the actuator
     */
    public static function fadeIn(display: DisplayObject): IGenericActuator
    {
        display.alpha = 0;
        display.visible = true;
        return Actuate.tween(display, 1, { alpha: 1 }).ease(Cubic.easeOut);
    }

    /**
     * Get a fade out effect for the object
     * @param	display : Target of the tween
     * @return the actuator
     */

    public static function fadeOut(display: DisplayObject): IGenericActuator
    {
        display.alpha = 1;
        return Actuate.tween(display, 1, { alpha: 0 }).ease(Cubic.easeOut);
    }

    /**
    * Get a wiggle effect for the object
    * @param    display : Target of the tween
    * @return the actuator
**/

    public static function wiggle(display: DisplayObject, amplitude: {x: Float, y: Float}): IGenericActuator
    {
        // Repeat must always be a uneven number for the object to get back to its origin
        return Actuate.tween(display, 0.05, {x: display.x + amplitude.x, y: display.y + amplitude.y}).repeat(9).reflect();
    }

    /**
    * Get a zoom effect for the object
    * @param    display : Target of the tween
    * @return the actuator
**/

    public static function zoom(display: DisplayObject, zoomRect: Rectangle): IGenericActuator
    {
        var mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(display.x, display.y, display.width, display.height);
        mask.graphics.endFill();
        display.mask = mask;
        if(display.parent != null)
            display.parent.addChild(mask);
        return Actuate.tween(display, 2, {x: 2 * display.x - zoomRect.x, y: 2 * display.y - zoomRect.y, scaleX: display.width / zoomRect.width, scaleY: display.height / zoomRect.height});
    }

    /**
     * Translate the object
     * @param	display : Target of the tween
     * @param	origin : Starting point of the object
     * @param	destination : Ending point of the object
     * @return the actuator
     */

    public static function translate(display: DisplayObject, origin: Point, destination: Point): IGenericActuator
    {
        display.x = origin.x;
        display.y = origin.y;
        return Actuate.tween(display, 1, { x: destination.x, y: destination.y }).ease(Cubic.easeOut);
    }

    /**
     * Translate the object horizontally only
     * @param	display : Target of the tween
     * @param	origin : Starting direction of the object
     * @param	destination : Ending point of the object
     * @return the actuator
     */

    public static function translateHorizontally(display: DisplayObject, origin: Direction, destination: Point): IGenericActuator
    {
        var originPoint: Point = new Point();
        if(origin == Direction.LEFT){
            originPoint.x = -display.width;
        }
        else{
            originPoint.x = Lib.current.stage.stageWidth + display.width;
            destination.x = Lib.current.stage.stageWidth - destination.x;
        }
        originPoint.y = Lib.current.stage.stageHeight / 2 - display.height / 2;

        return translate(display, originPoint, destination);
    }

    private function new()
    {

    }
}

/**
 * Possible direction for tween
 */
enum Direction {
    RIGHT;
    LEFT;
}