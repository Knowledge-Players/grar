package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.Timer;
import haxe.xml.Fast;
import flash.display.DisplayObject;
import flash.events.Event;

class IntroScreen extends WidgetContainer {

	/**
	* Text to display in the intro
	**/
	public var text (default, set_text):String;

	/**
	* Time (in ms) before the screen disappear
	**/
	public var duration (default, default):Int;

	private var textZone:ScrollPanel;

	public function new(?xml:Fast)
	{
		super(xml);
		y = Std.parseFloat(xml.att.y);
		duration = Std.parseInt(xml.att.duration);
		if(xml.hasNode.Text){
			var textNode:Fast = xml.node.Text;
			textZone = new ScrollPanel(textNode);
			addChild(textZone);
		}
		for(item in xml.nodes.Item){
			var bitmap:Image = new Image(item);
			addChild(bitmap);
		}
	}

	public function set_text(text:String):String
	{
		textZone.setContent(text);
		return this.text = text;
	}

	// Privates

	private function hide():Void
	{
		if(transitionOut != null)
			TweenManager.applyTransition(this, transitionOut).onComplete(function()
			{
				dispose();
			});
		else{
			dispose();
		}
	}

	private function dispose():Void
	{
		if(parent != null)
			parent.removeChild(this);
	}

	// Handlers

	override public function set_transitionIn(transition:String):String
	{
		addEventListener(Event.ADDED_TO_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transition);
			Timer.delay(hide, duration);
		});

		return transitionIn = transition;
	}

	override public function set_transitionOut(transition:String):String
	{
		return transitionOut = transition;
	}

}
