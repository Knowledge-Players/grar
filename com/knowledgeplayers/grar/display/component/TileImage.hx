package com.knowledgeplayers.grar.display.component;

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

	public function new(xml: Fast, layer: TileLayer, visible: Bool = true)
	{
		super(xml);

		tileSprite = new TileSprite(layer, xml.att.tile);
		if(xml.has.x)
			tileSprite.x = Std.parseFloat(xml.att.x);
		if(xml.has.y)
			tileSprite.y = Std.parseFloat(xml.att.y);
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

		tileSprite.visible = visible;
		layer.addChild(tileSprite);
		layer.render();
	}

	public function set_visible(visible:Bool):Void
	{
		tileSprite.visible = visible;
		if(visible){
			origin = {x: tileSprite.x, y: tileSprite.y, scaleX: tileSprite.scaleX, scaleY: tileSprite.scaleY};
			var actuator: IGenericActuator = TweenManager.applyTransition(tileSprite, transitionIn);
			if(actuator != null && onComplete != null)
				actuator.onComplete(onComplete);
		}
		else{
			var actuator: IGenericActuator = TweenManager.applyTransition(tileSprite, transitionOut);
			if(actuator != null)
				actuator.onComplete(reset);
			else
				reset();
		}
	}

	override public function set_transitionIn(transition:String):String
	{
		return transitionIn = transition;
	}

	override public function set_transitionOut(transition:String):String
	{
		return transitionOut = transition;
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

}
