package com.knowledgeplayers.grar.display.component;

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

	public function new(xml: Fast, layer: TileLayer, visible: Bool = true)
	{
		super(xml);

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
		layer.addChild(tileSprite);
		layer.render();
	}

	public function set_visible(visible:Bool):Void
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
		if(actuator != null)
			actuator.onUpdate(function(){
				// TODO unify
				if(Std.is(parent, KpDisplay))
					cast(parent, KpDisplay).renderLayers.set(tileSprite.layer, true);
				if(Std.is(parent, WidgetContainer))
					cast(parent, WidgetContainer).renderNeeded = true;
			});
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
