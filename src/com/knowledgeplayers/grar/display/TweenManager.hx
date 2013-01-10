package com.knowledgeplayers.grar.display;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.GenericActuator.IGenericActuator;
import com.eclecticdesignstudio.motion.easing.Cubic;
import nme.display.DisplayObject;
import nme.geom.Point;
import nme.Lib;

/**
 * ...
 * @author jbrichardet
 */

class TweenManager 
{
	public static function fadeIn(display: DisplayObject) : IGenericActuator
	{
		display.alpha = 0;
		return Actuate.tween (display, 1, { alpha: 1 }).ease(Cubic.easeOut);
	}
	
	public static function fadeOut(display: DisplayObject) : IGenericActuator
	{
		display.alpha = 1;
		return Actuate.tween (display, 1, { alpha: 0 }).ease(Cubic.easeOut);
	}
	
	public static function translate(display: DisplayObject, origin: Point, destination: Point) : IGenericActuator
	{
		display.x = origin.x;
		display.y = origin.y;
		return Actuate.tween (display, 1, { x: destination.x, y: destination.y }).ease(Cubic.easeOut);
	}
	
	public static function translateHorizontaly(display: DisplayObject, origin: Direction, destination: Point) : IGenericActuator
	{
		var originPoint: Point = new Point();
		if(origin == Direction.LEFT){
			originPoint.x = -display.width;
		}
		else {
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

enum Direction 
{
	RIGHT;
	LEFT;
}