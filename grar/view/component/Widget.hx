package grar.view.component;

import aze.display.TilesheetEx;

import grar.view.DisplayCallbacks;
import grar.view.component.container.DropdownMenu;

import grar.util.TweenUtils;

import motion.actuators.GenericActuator;

import flash.events.Event;
import flash.geom.Matrix;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

import haxe.ds.StringMap;

using StringTools;

typedef WidgetData = {

	var ref : String;
	var scale : Null<Float>;
	var scaleX : Null<Float>;
	var scaleY : Null<Float>;
	var x : String;
	var currentX : Null<String>;
	var y : String;
	var transitionIn : String;
	var transitionOut : String;
	var alpha : Null<Float>;
	var rotation : Null<Float>;
	var transformation : Null<String>;
	var filtersData : Null<Array<String>>;
	var borderStyle : Null<{ thickness : Float, color : Color }>;
	var position : Null<Positioning>;
	@:optional var isBackground : Bool;
}

typedef BorderStyle = {

	var thickness : Float;
	var color : Color;
}

@:fakeEnum(String)
enum Positioning {

	FIXED;
}

/**
 * Base class for all graphical elements
 **/
class Widget extends Sprite {

	/**
	 * Never called directly (only in sub-classes)
	 */
	//private function new(?xml: Fast)
	private function new(callbacks : DisplayCallbacks, applicationTilesheet : TilesheetEx, 
							transitions : StringMap<TransitionTemplate>, ? wd : Null<WidgetData>) {

		super();

		this.callbacks = callbacks;
		this.onContextualDisplayRequest = function(c : grar.view.Application.ContextualType, ? ho : Bool = true){ callbacks.onContextualDisplayRequest(c, ho); }
		this.onContextualHideRequest = function(c : grar.view.Application.ContextualType){ callbacks.onContextualHideRequest(c); }
		this.onQuitGameRequest = function(){ callbacks.onQuitGameRequest(); }
		this.onRestoreLocaleRequest = function(){ callbacks.onRestoreLocaleRequest(); }
		this.onLocalizedContentRequest = function(k : String){ return callbacks.onLocalizedContentRequest(k); }
		this.onLocaleDataPathRequest = function(p:String){ callbacks.onLocaleDataPathRequest(p); }
		this.onStylesheetRequest = function(s:String){ return callbacks.onStylesheetRequest(s); }
		this.onFiltersRequest = function(fids:Array<String>){ return callbacks.onFiltersRequest(fids); }

		this.applicationTilesheet = applicationTilesheet;

		this.transitions = transitions;

		if (wd != null) {

			this.ref  = wd.ref;
			this.scale = wd.scale;

			if (wd.scaleX != null) {

				this.scaleX = wd.scaleX;
			}
			if (wd.scaleY != null) {

				this.scaleY = wd.scaleY;
			}
			if (wd.currentX != null) {

				this.currentX = wd.currentX;
			}
			this.transitionIn = wd.transitionIn;
			this.transitionOut = wd.transitionOut;

			if (wd.alpha != null) {

				this.alpha = wd.alpha;
			}
			if (wd.rotation != null) {

				this.rotation = wd.rotation;
			}
			if (wd.transformation != null) {

				this.transformation = wd.transformation;
			}
			if (wd.filtersData != null) {

				filters = onFiltersRequest(wd.filtersData);
			}
			if (wd.position != null) {

				this.position = wd.position;
			}

			setX(wd.x);

			if (!Math.isNaN(Std.parseFloat(wd.y))) {

				this.y = Std.parseFloat(wd.y);
			
			} else {

				switch (wd.y.toLowerCase()) {

					case "top":

						y = 0;
					
					case "middle":

						addEventListener(Event.ADDED_TO_STAGE, function(e){
							y = parent.height / 2 - height / 2;
						}, false, 100);
					
					case "bottom":

						addEventListener(Event.ADDED_TO_STAGE, function(e){
							y = parent.height - height;
						}, false, 100);
					
					default:

						throw '[Widget] Unsupported position "'+wd.y+'".';
				}
			}

			if (wd.borderStyle != null) {

				this.borderStyle = wd.borderStyle;
				addEventListener(Event.ADDED_TO_STAGE, drawBorders);
			}
		}
	}

	var transitions : StringMap<TransitionTemplate>;

	var callbacks : DisplayCallbacks;

	var applicationTilesheet : TilesheetEx;

	public var isBackground (default, null) : Bool = false;

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
	public var zz (default, null) : Int;

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


	///
	// CALLBACKS
	//

	public dynamic function onContextualDisplayRequest(c : grar.view.Application.ContextualType, ? hideOther : Bool = true) : Void { }

	public dynamic function onContextualHideRequest(c : grar.view.Application.ContextualType) : Void { }

	public dynamic function onQuitGameRequest() : Void { }

	public dynamic function onRestoreLocaleRequest() : Void { }

	public dynamic function onLocalizedContentRequest(k : String) : String { return null; }

	public dynamic function onLocaleDataPathRequest(uri : String) : Void { }

	public dynamic function onStylesheetRequest(s : Null<String>) : grar.view.style.StyleSheet { return null; }

	public dynamic function onFiltersRequest(fids : Array<String>) : Array<flash.filters.BitmapFilter> { return null; }


	///
	// GETTER / SETTER
	//

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
			}, 1000);
		}
		return this.position = position;
	}

	public function set_transformation(transformation : String) : String {

// 		TweenManager.applyTransition(this, transformation);
		TweenUtils.applyTransition(this, transitions, transformation);

		return this.transformation = transformation;
	}

	public function set_transitionIn(transition : String) : String {

		addEventListener(Event.ADDED_TO_STAGE, function(e:Event) {

				if (!lockPosition) {

					origin = {x: x, y: y, scaleX: scaleX, scaleY: scaleY, alpha: alpha};
					lockPosition = true;
				}
				reset();

				if (visible) {

	// 				var actuator: IGenericActuator = TweenManager.applyTransition(this, transition);
					var actuator : IGenericActuator = TweenUtils.applyTransition(this, transitions, transition);

					if (actuator != null && onComplete != null) {

						actuator.onComplete(onComplete);
					
					} else if(onComplete != null) {

						onComplete();
					}
				
				} else if (onComplete != null) {

					onComplete();
				}

			}, 1000);

		return transitionIn = transition;
	}

	public function set_transitionOut(transition : String) : String {

		addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event) {

// 				var actuator: IGenericActuator = TweenManager.applyTransition(this, transition);
				TweenUtils.applyTransition(this, transitions, transition);

			});

		return transitionOut = transition;
	}

	@:setter(alpha)
	public function set_alpha(alpha:Float):Void
	{
		visible = alpha != 0;
		super.alpha = alpha;
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
		for(field in Reflect.fields(origin))
			Reflect.setField(this, field, Reflect.field(origin, field));
	}

	public function setBorders(thickness:Float, color:Int = 0, alpha:Float = 1):Void
	{
		borderStyle = {thickness: thickness, color: {color: color, alpha: alpha}};
		drawBorders();
	}


	///
	// INTERNALS
	//

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
				if(!Std.is(parent.getChildAt(i), grar.view.component.container.DropdownMenu) && maxX < parent.getChildAt(i).x){
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

	private function drawBorders(? e : Event) : Void {

		graphics.clear();

		graphics.lineStyle(borderStyle.thickness, borderStyle.color.color, borderStyle.color.alpha);
		graphics.drawRect(-borderStyle.thickness, -borderStyle.thickness, width/scaleX+(2*borderStyle.thickness), height/scaleY+(2*borderStyle.thickness));
		
		if (e != null) {

			removeEventListener(Event.ADDED_TO_STAGE, drawBorders);
		}
	}
}