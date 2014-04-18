package com.knowledgeplayers.grar.display.component;

import flash.events.Event;
import com.knowledgeplayers.grar.display.component.container.DropdownMenu;
import com.knowledgeplayers.grar.util.ParseUtils;
import motion.actuators.GenericActuator;
import haxe.xml.Fast;
import flash.events.Event;
import flash.display.Bitmap;
import flash.geom.Matrix;
import flash.display.BitmapData;
import flash.display.Sprite;

using StringTools;

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

	/**
	* Layer order of this widget
	**/
	public var zz: Int;

	/**
	* Positionement of the widget
	**/
	public var position (default, set_position):Positioning;

	/**
	* Style of the border surrounding widget
	**/
	private var borderStyle: BorderStyle;
	private var origin: {x: Float, y: Float, scaleX: Float, scaleY: Float, alpha: Float};
	private var lockPosition: Bool = false;
	private var currentX: String;

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

	public function set_position(position:Positioning):Positioning
	{
		if(position == Positioning.FIXED){
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				flash.Lib.current.addChild(this);
			}, false, 1000, false);
		}
		return this.position = position;
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
			var actuator: IGenericActuator = TweenManager.applyTransition(this, transition);
			if(actuator != null && onComplete != null)
				actuator.onComplete(onComplete);
			else if(onComplete != null)
				onComplete();
		}, false, 1000, false);

		return transitionIn = transition;
	}

	public function set_transitionOut(transition:String):String
	{
		addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
		{
			var actuator: IGenericActuator = TweenManager.applyTransition(this, transition);
		});
		return transitionOut = transition;
	}

	@:setter(alpha)
	public function set_alpha(alpha:Float):Void
	{
		visible = alpha != 0;
		super.alpha = alpha;
	}

	@:getter(width)
	public function get_width():Float
	{
		return super.width + (borderStyle != null ? borderStyle.thickness : 0);
	}

	@:getter(height)
	public function get_height():Float
	{
		return super.height + (borderStyle != null ? borderStyle.thickness : 0);
	}

	override public function toString():String
	{
		return '$ref: $x;$y $width x $height ($scale) $transitionIn->$transitionOut';
	}

	public function updateX():Void
	{
		setX(currentX);
	}

	public function reset(): Void
	{
		if(origin == null)
			origin = {x: x, y: y, scaleX: scaleX, scaleY: scaleY, alpha: alpha};
		else
			for(field in Reflect.fields(origin))
				Reflect.setField(this, field, Reflect.field(origin, field));
	}

	public function setBorders(thickness:Float, color:Int = 0, alpha:Float = 1):Void
	{
		borderStyle = {thickness: thickness, color: {color: color, alpha: alpha}};
		drawBorders();
	}

	// Privates

	private function setX(xString:String):Void
	{
		if(!Math.isNaN(Std.parseFloat(xString)))
			x = Std.parseFloat(xString);
		else{
			switch(xString.toLowerCase()){
				case "left":
					if(parent != null)
						setXLeft();
				else
					addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 100);
				case "center": addEventListener(Event.ADDED_TO_STAGE, function(e){
					x = parent.width /2 - width/2;
				}, false, 100);
				case "right": addEventListener(Event.ADDED_TO_STAGE, function(e){
					x = parent.width - width;
				}, false, 100);
				default: throw '[Widget] Unsupported position "'+xString+'".';
			}
		}
	}

	private inline function setXLeft():Void
	{
		var maxX: Float = 0;
		if(parent.numChildren > 1){
			var maxWidth: Float = 0;
			// Only look for widget under itself
			for(i in 0...parent.getChildIndex(this)){
				if(!Std.is(parent.getChildAt(i), DropdownMenu) && maxX < parent.getChildAt(i).x){
					maxX = parent.getChildAt(i).x;
					maxWidth = parent.getChildAt(i).width;
				}
			}
			maxX += maxWidth;
		}
		x = maxX;
	}

	private function onAddedToStage(e:Event):Void
	{
		setXLeft();
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function new(?xml: Fast)
	{
		super();

		if(xml != null){
			// Ref
			if(!xml.has.ref)
				throw Type.getClassName(Type.getClass(this))+" must have a ref attribute: "+xml.x;
			else
				ref = xml.att.ref;

			// Scales
			if(xml.has.scale)
				scale = Std.parseFloat(xml.att.scale);
			else
				scale = 1;

			if(xml.has.scaleX)
				scaleX = Std.parseFloat(xml.att.scaleX);
			if(xml.has.scaleY)
				scaleY = Std.parseFloat(xml.att.scaleY);

			// Coordinates
			var xTmp = "0";
			if(xml.has.x){
				currentX = xml.att.x;
				xTmp = xml.att.x;
			}
			setX(xTmp);
			if(xml.has.y){
				if(!Math.isNaN(Std.parseFloat(xml.att.y)))
					y = Std.parseFloat(xml.att.y);
				else{
					switch(xml.att.y.toLowerCase()){
						case "top": y = 0;
						case "middle": addEventListener(Event.ADDED_TO_STAGE, function(e){
							y = parent.height /2 - height/2;
						}, false, 100);
						case "bottom": addEventListener(Event.ADDED_TO_STAGE, function(e){
							y = parent.height - height;
						}, false, 100);
						default: throw '[Widget] Unsupported position "'+xml.att.y+'".';
					}
				}
			}
			else
				y = 0;

			// Transitions
			transitionIn = xml.has.transitionIn ? xml.att.transitionIn : "";
			transitionOut = xml.has.transitionOut ? xml.att.transitionOut : "";

			if(xml.has.alpha)
				alpha = Std.parseFloat(xml.att.alpha);
			if(xml.has.rotation)
				rotation = Std.parseFloat(xml.att.rotation);
			if(xml.has.transformation)
				transformation = xml.att.transformation;
			if(xml.has.filters){
				filters = FilterManager.getFilter(xml.att.filters);
			}
			if(xml.has.border){
				var params = xml.att.border.split(",");
				var thickness = Std.parseFloat(params[0].trim());
				var borderColor = ParseUtils.parseColor(params[1].trim());
				borderStyle = {thickness: thickness, color: borderColor};
				addEventListener(Event.ADDED_TO_STAGE, drawBorders);
			}
			if(xml.has.position){
				position = Type.createEnum(Positioning, xml.att.position.toUpperCase());
			}
		}
	}

	private function drawBorders(?e:Event):Void
	{
		x += borderStyle.thickness;
		y += borderStyle.thickness;
		graphics.clear();
		graphics.lineStyle(borderStyle.thickness, borderStyle.color.color, borderStyle.color.alpha);
		graphics.drawRect(-borderStyle.thickness, -borderStyle.thickness, super.width/scaleX+(2*borderStyle.thickness), super.height/scaleY+(2*borderStyle.thickness));
		if(e != null)
			removeEventListener(Event.ADDED_TO_STAGE, drawBorders);
	}
}

typedef BorderStyle = {
	var thickness: Float;
	var color: Color;
}

@:fakeEnum(String)
enum Positioning {
	FIXED;
}