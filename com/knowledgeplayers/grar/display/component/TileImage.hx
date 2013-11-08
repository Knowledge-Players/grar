package com.knowledgeplayers.grar.display.component;

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
		x = y = 0;
		addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		addEventListener(Event.ADDED_TO_STAGE, function(e){
			if(tileSprite != null)
				origin = {x: tileSprite.x, y: tileSprite.y, scaleX: tileSprite.scaleX, scaleY: tileSprite.scaleY, alpha: tileSprite.alpha};
			set_visible(true);
			if(onComplete != null)
				onComplete();
		}, 1000);
	}

	#if !flash override #end public function set_x(x:Float):Float
	{
		tileSprite.x = x;
		trueLayer.render();
		return x;
	}

	#if !flash override #end public function get_x():Float
	{
		return tileSprite.x;
	}

	#if !flash override #end public function set_y(y:Float):Float
	{
		tileSprite.y = y;
		trueLayer.render();
		return y;
	}

	override public function set_visible(visible:Bool):Bool
	{
		if(tileSprite == null)
			return isVisible = visible;

		tileSprite.visible = visible;
		var actuator: IGenericActuator = null;
		var transform: IGenericActuator = null;

		if(visible){
			reset();
			actuator = TweenManager.applyTransition(tileSprite, transitionIn);
			if(actuator != null && onComplete != null)
				actuator.onComplete(onComplete);

			transform = TweenManager.applyTransition(tileSprite.layer.view, transformation);
			trace("Applying transformation '"+transformation+"'. Transformation found ? "+(transform != null ? "yes" : "no"));
			//if(transform != null)
			//	transform.onUpdate(renderNeeded);
		}
		else{
			actuator = TweenManager.applyTransition(tileSprite, transitionOut);
		}
		renderNeeded();
		if(actuator != null)
			actuator.onUpdate(renderNeeded);
		else if(transform != null)
			transform.onUpdate(renderNeeded);
		return visible;
	}

	public function getMask():Sprite
	{
		var layer = new TileLayer(trueLayer.tilesheet);
		var tile = new TileSprite(layer, tileSprite.tile);
		layer.addChild(tile);
		layer.render();
		layer.view.x = tileSprite.x;
		layer.view.y = tileSprite.y;
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
		for(field in Reflect.fields(origin)){
			Reflect.setProperty(tileSprite, field, Reflect.field(origin, field));
		}
	}

	// Private

	private function init():Void
	{
		tileSprite = new TileSprite(trueLayer, xml.att.tile);

		if(xml.has.scale)
			tileSprite.scale = Std.parseFloat(xml.att.scale);
		if(xml.has.scaleX)
			tileSprite.scaleX = Std.parseFloat(xml.att.scaleX);
		if(xml.has.scaleY)
			tileSprite.scaleY = Std.parseFloat(xml.att.scaleY);
		if(xml.has.width)
			tileSprite.scaleX = Std.parseFloat(xml.att.width)/tileSprite.width;
		if(xml.has.height)
			tileSprite.scaleY = Std.parseFloat(xml.att.height)/tileSprite.height;
		if(xml.has.mirror){
			tileSprite.mirror = switch(xml.att.mirror.toLowerCase()){
				case "horizontal": 1;
				case "vertical": 2;
				case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
			}
		}

		if(xml.has.x)
			tileSprite.x = Std.parseFloat(xml.att.x) + tileSprite.width/2;
		else
			tileSprite.x = tileSprite.width/2;
		if(xml.has.y)
			tileSprite.y = Std.parseFloat(xml.att.y)+ tileSprite.height/2;
		else
			tileSprite.y = tileSprite.height/2;

		tileSprite.visible = isVisible;

        trueLayer.addChild(tileSprite);
        trueLayer.render();

        xml = null;
	}

	override private function createImg(xml:Fast, ?tilesheet:TilesheetEx):Void
	{
	}

	private function renderNeeded(?e: Event): Void
	{
		if(parent == null){
			addEventListener(Event.ADDED_TO_STAGE, renderNeeded);
			//TweenManager.stop(tileSprite);
			//TweenManager.stop(tileSprite.layer.view);
		}
		else{
			if(hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, renderNeeded);

			// TODO unify
			if(Std.is(parent, KpDisplay)){
				cast(parent, KpDisplay).renderLayers.set(tileSprite.layer, true);
			}
			if(Std.is(parent, WidgetContainer)){
				cast(parent, WidgetContainer).renderNeeded = true;
			}
		}
	}

	private inline function onRemove(e:Event):Void
	{
		set_visible(false);
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
