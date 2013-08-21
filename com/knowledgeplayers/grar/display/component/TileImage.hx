package com.knowledgeplayers.grar.display.component;

import com.knowledgeplayers.grar.factory.UiFactory;
import nme.display.DisplayObject;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import nme.events.Event;
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

	private var tilesheet: TilesheetEx;

	public function new(xml: Fast, layer: TileLayer, visible: Bool = true)
	{

		tileSprite = new TileSprite(layer, xml.att.tile);
		if(xml.has.scale)
			tileSprite.scale = Std.parseFloat(xml.att.scale);
		if(xml.has.scaleX)
			tileSprite.scaleX = Std.parseFloat(xml.att.scaleX);
		if(xml.has.scaleY)
			tileSprite.scaleY = Std.parseFloat(xml.att.scaleY);
		if(xml.has.mirror){
			tileSprite.mirror = switch(xml.att.mirror.toLowerCase()){
				case "horizontal": 1;
				case "vertical": 2;
				case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
			}
		}
		if(xml.has.x)
			tileSprite.x = Std.parseFloat(xml.att.x) + tileSprite.width/2;
		if(xml.has.y)
			tileSprite.y = Std.parseFloat(xml.att.y)+ tileSprite.height/2;

		tileSprite.visible = visible;
		tilesheet = layer.tilesheet;
		layer.addChild(tileSprite);

		super(xml);
		layer.render();

		addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
	}

	#if !flash override #end public function set_x(x:Float):Float
	{
		return tileSprite.x = x;
	}

	#if !flash override #end public function get_x():Float
	{
		return tileSprite.x;
	}

	#if !flash override #end public function set_y(y:Float):Float
	{
		return tileSprite.y = y;
	}

	override public function set_visible(visible:Bool):Bool
	{
		tileSprite.visible = visible;
		var actuator: IGenericActuator = null;

		if(visible){
			origin = {x: tileSprite.x, y: tileSprite.y, scaleX: tileSprite.scaleX, scaleY: tileSprite.scaleY};
			actuator = TweenManager.applyTransition(tileSprite, transitionIn);
			if(actuator != null && onComplete != null)
				actuator.onComplete(onComplete);
		}
		else{
			actuator = TweenManager.applyTransition(tileSprite, transitionOut);
			if(actuator != null)
				actuator.onComplete(reset);
			else
				reset();
		}
		renderNeeded();
		if(actuator != null)
			actuator.onUpdate(renderNeeded);
		return visible;
	}

	public function getMask():DisplayObject
	{
		var layer = new TileLayer(tilesheet);
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
		var actuator = TweenManager.applyTransition(tileSprite.layer.view, transformation);
		renderNeeded();
		if(actuator != null)
			actuator.onUpdate(renderNeeded);
		return this.transformation = transformation;
	}

	// Private

	override private function createImg(xml:Fast, ?tilesheet:TilesheetEx):Void
	{
	}

	override private function reset():Void
	{
		for(field in Reflect.fields(origin)){
			Reflect.setProperty(tileSprite, field, Reflect.field(origin, field));
		}
	}

	private function renderNeeded(?e: Event): Void
	{
		if(parent == null)
			addEventListener(Event.ADDED_TO_STAGE, renderNeeded);
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

	private function onRemove(e:Event):Void
	{
		set_visible(false);
	}

}
