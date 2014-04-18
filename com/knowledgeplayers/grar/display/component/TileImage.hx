package com.knowledgeplayers.grar.display.component;

import flash.filters.BitmapFilter;
import flash.display.Sprite;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import flash.events.Event;
import motion.actuators.GenericActuator.IGenericActuator;
import aze.display.TilesheetEx;
import haxe.xml.Fast;
import aze.display.TileLayer;
import aze.display.TileSprite;

/**
* Image created with a tilesheet
**/
class TileImage extends Image{

	public var tileSprite (default, null): TileSprite;

	private var tilesheetName: String;
	public var trueLayer: TileLayer;
	private var xml: Fast;
	private var isVisible: Bool;
	private var color:String;

public function new(xml: Fast, layer: TileLayer, visible: Bool = true,?div:Bool=false)
	{
		this.xml = xml;
		isVisible = visible;

		if(xml.has.spritesheet){
			tilesheetName = xml.att.spritesheet;
            addEventListener(Event.ADDED_TO_STAGE, setTilesheet);

		}
		else{
			trueLayer = layer;
            init();
		}
		super(xml);
		if(xml.has.color)
			color = xml.att.color;

		addEventListener(Event.REMOVED_FROM_STAGE, onRemove, false, 1000, false);
		addEventListener(Event.ADDED_TO_STAGE, function(e){
			this.visible = true;

			TweenManager.applyTransition(this, transformation);
			if(color != null)
				TweenManager.transform(trueLayer.view, null, color);

			if(onComplete != null)
				onComplete();
		}, false, 1000, false);
	}

	@:setter(filters)
	public function set_filters(filters:Array<BitmapFilter>):Void
	{
		super.filters = trueLayer.view.filters = filters;
	}

	@:getter(width)
	override public function get_width():Float
	{
		return tileSprite != null ? tileSprite.width : 0;
	}

	@:setter(width)
	public function set_width(width:Float):Void
	{
		if(tileSprite != null){
			tileSprite.scaleX *= width / tileSprite.width;
			renderNeeded();
		}
		else{
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				tileSprite.scaleX *= width / tileSprite.width;
				renderNeeded();
			});
		}
		super.width = width;
	}

	@:getter(height)
	override public function get_height():Float
	{
		return tileSprite != null ? tileSprite.height : 0;
	}

	@:setter(height)
	public function set_height(height:Float):Void
	{
		if(tileSprite != null){
			tileSprite.scaleY *= height / tileSprite.height;
			renderNeeded();
		}
		else{
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				tileSprite.scaleY *= height / tileSprite.height;
				renderNeeded();
			});
		}
		super.height = height;
	}

	#if flash
	@:setter(x)
	public function set_x(x:Float):Void
	#else
	override public function set_x(x:Float):Float
	#end
	{
		if(tileSprite != null){
			tileSprite.x = x + tileSprite.width/2;
			renderNeeded();
		}
		else{
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				tileSprite.x = x + tileSprite.width/2;
				renderNeeded();
			});
		}
		#if !flash
		return tileSprite.x;
		#else
		super.x = x;
		#end
	}

	#if flash
	@:getter(x)
	public function get_x():Float
	#else
	override public function get_x():Float
	#end
	{
		if(tileSprite != null)
			return tileSprite.x - tileSprite.width/2;
		else
			return -1;
	}

	#if flash
	@:getter(y)
	public function get_y():Float
	#else
	override public function get_y():Float
	#end
	{
		if(tileSprite != null)
			return tileSprite.y - tileSprite.height/2;
		else
			return -1;
	}

	#if flash
	@:setter(y)
	public function set_y(y: Float):Void
	#else
	override public function set_y(y:Float):Float
	#end
	{
		if(tileSprite != null){
			tileSprite.y = y + tileSprite.height/2;
			renderNeeded();
		}
		else{
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				tileSprite.y = y + tileSprite.height/2;
				renderNeeded();
			});
		}
		#if !flash
		return tileSprite.y;
		#else
		super.y = y;
		#end
	}

	override public function set_scale(scale:Float):Float
	{
		super.set_scale(scale);
		if(tileSprite != null){
			tileSprite.scale = scale;
			renderNeeded();
		}
		else{
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				tileSprite.scale = scale;
				renderNeeded();
			});
		}
		return scale;
	}

	@:setter(scaleX)
	public function set_scaleX(scaleX:Float):Void
	{
		super.scaleX = scaleX;
		if(tileSprite != null){
			super.scaleX = tileSprite.scaleX = scaleX;
			renderNeeded();
		}
		else{
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				tileSprite.scaleX = scaleX;
				renderNeeded();
			});
		}
	}

	@:setter(scaleY)
	public function set_scaleY(scaleY:Float):Void
	{
		super.scaleY = scaleY;
		if(tileSprite != null){
			super.scaleY = scaleY;
			tileSprite.scaleY = scaleY;
			renderNeeded();
		}
		else{
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				tileSprite.scaleY = scaleY;
				renderNeeded();
			});
		}
	}

	@:setter(visible)
	public function set_visible(visible:Bool):Void
	{
		super.visible = visible;

		if(tileSprite == null){
			isVisible = visible;
			return ;
		}

		tileSprite.visible = visible;
		var actuator: IGenericActuator = null;

		if(visible){
			actuator = TweenManager.applyTransition(tileSprite, transitionIn);
			if(actuator != null && onComplete != null)
				actuator.onComplete(onComplete);
		}
		else{
			actuator = TweenManager.applyTransition(tileSprite, transitionOut);
		}
		renderNeeded();
		if(actuator != null)
			actuator.onUpdate(renderNeeded);
	}

	@:setter(alpha)
	override public function set_alpha(alpha:Float):Void
	{
		super.alpha = tileSprite.alpha = alpha;
		renderNeeded();
	}

	public function getMask():Sprite
	{
		var layer = new TileLayer(trueLayer.tilesheet);
		var tile = new TileSprite(layer, tileSprite.tile);
		layer.addChild(tile);
		layer.render();
		layer.view.x = x;
		layer.view.y = y;
		tileSprite.visible = false;
		tileSprite.layer.render();
		return layer.view;
	}

	override public function set_transitionIn(transition:String):String
	{
		return transitionIn = transition;
	}

	override public function set_transitionOut(transition:String):String
	{
		return transitionOut = transition;
	}

	override public function set_transformation(transformation:String):String
	{
		return this.transformation = transformation;
	}

	override public function toString():String
	{
		return '$ref: $x;$y '+(tileSprite != null ? tileSprite.width : -1)+' x '+(tileSprite != null ? tileSprite.height : -1)+' ($scale) $transitionIn->$transitionOut';
	}

	override public function reset():Void
	{
		if(origin == null)
			origin = {x: tileSprite.x, y: tileSprite.y, scaleX: tileSprite.scaleX, scaleY: tileSprite.scaleY, alpha: tileSprite.alpha};
		else
			for(field in Reflect.fields(origin)){
				Reflect.setProperty(tileSprite, field, Reflect.field(origin, field));
			}

		// Reset filters
		trueLayer.view.filters = filters;
	}

	// Private

	private inline function init():Void
	{
		tileSprite = new TileSprite(trueLayer, xml.att.tile);

		if(xml.has.mirror){
			tileSprite.mirror = switch(xml.att.mirror.toLowerCase()){
				case "horizontal": 1;
				case "vertical": 2;
				case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
			}
		}

		tileSprite.visible = isVisible;

        trueLayer.addChild(tileSprite);
		renderNeeded();

        xml = null;
	}

	override private function createImg(xml:Fast, ?tilesheet:TilesheetEx):Void
	{
	}

	private function renderNeeded(?e: Event): Void
	{
		if(parent == null){
			addEventListener(Event.ADDED_TO_STAGE, renderNeeded);
		}
		else{
			if(hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, renderNeeded);

			var container = parent;
			while(container != null && !Std.is(container, KpDisplay) && !Std.is(container, WidgetContainer))
				container = container.parent;

			// TODO unify (MVP)
			if(Std.is(container, KpDisplay)){
				cast(container, KpDisplay).renderLayers.set(tileSprite.layer, true);
			}
			if(Std.is(container, WidgetContainer)){
				cast(container, WidgetContainer).renderNeeded = true;
			}
		}
	}

	private inline function onRemove(e:Event):Void
	{
		visible = false;
	}

	private function setTilesheet(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, setTilesheet);
		var ancestor = parent;
		while(!Std.is(ancestor, PartDisplay) && ancestor != null)
			ancestor = ancestor.parent;
		if(ancestor == null)
			throw "[TileImage] Unable to find spritesheet '"+tilesheetName+"' for image '"+ref+"'.";
		trueLayer = cast(ancestor, PartDisplay).getLayer(tilesheetName);

		init();
	}

}
