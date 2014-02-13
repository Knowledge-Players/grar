package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import haxe.Timer;
import haxe.xml.Fast;
import flash.display.DisplayObject;
import flash.events.Event;

class IntroScreen extends WidgetContainer {

	/**
	* Time (in ms) before the screen disappear
	**/
	public var duration (default, default):Int;

	public function new(?xml:Fast)
	{
		super(xml);
		duration = Std.parseInt(xml.att.duration);
	}

	public function setText(content:String, ?key:String):Void
	{
		if(content != null && content != ""){
			var i = 0;
			var firstText: Int = -1;
			while(i < children.length && key != children[i].ref){
				if(Std.is(children[i], ScrollPanel) && firstText == -1)
					firstText = i;
				i++;
			}
			if(key == null || StringTools.trim(key) == "")
				cast(children[firstText], ScrollPanel).setContent(content);
			else if(i == children.length)
				throw "[IntroScreen] Unable to find a Text field with ref '"+key+"'.";
			else
				cast(children[i], ScrollPanel).setContent(content);
		}
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
