package com.knowledgeplayers.grar.display.part;

import haxe.Timer;
import nme.events.Event;
import nme.display.DisplayObject;
import com.knowledgeplayers.grar.util.LoadData;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.util.DisplayUtils;
import nme.display.Sprite;

class IntroScreen extends Sprite {

	/**
	* Text to display in the intro
	**/
	public var text (default, setText):String;

	/**
	* Time (in ms) before the screen disappear
	**/
	public var duration (default, default):Int;

	/**
	* Transition when the screen appears
	**/
	public var transitionIn (default, default):String;

	/**
	* Transition when the screen disappears
	**/
	public var transitionOut (default, default):String;

	private var content:ScrollPanel;

	public function new(?xml:Fast)
	{
		super();
		DisplayUtils.setBackground(xml.att.background, this, Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height), Std.parseFloat(xml.att.alpha));
		x = Std.parseFloat(xml.att.x);
		y = Std.parseFloat(xml.att.y);
		duration = Std.parseInt(xml.att.duration);
		transitionIn = xml.has.transitionIn ? xml.att.transitionIn : null;
		transitionOut = xml.has.transitionOut ? xml.att.transitionOut : null;
		if(xml.hasNode.Text){
			var textNode:Fast = xml.node.Text;
			var background:String = textNode.has.background ? textNode.att.background : null;
			var scrollable = textNode.has.scrollable ? textNode.att.scrollable == "true" : true;
			var styleSheet = textNode.has.style ? textNode.att.style : null;

			content = new ScrollPanel(Std.parseFloat(textNode.att.width), Std.parseFloat(textNode.att.height), scrollable, styleSheet);
			if(background != null)
				content.setBackground(background);
			content.x = Std.parseFloat(textNode.att.x);
			content.y = Std.parseFloat(textNode.att.y);
			addChild(content);
		}
		for(item in xml.nodes.Item){
			var bitmap:DisplayObject = LoadData.instance.getElementDisplayInCache(item.att.ref);
			bitmap.width = Std.parseFloat(item.att.width);
			bitmap.height = Std.parseFloat(item.att.height);
			bitmap.x = Std.parseFloat(item.att.x);
			bitmap.y = Std.parseFloat(item.att.y);
			addChild(bitmap);
		}

		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	public function setText(text:String):String
	{
		content.setContent(text);
		return this.text = text;
	}

	// Privates

	private function hide():Void
	{
		if(transitionOut != null)
			TweenManager.applyTransition(this, transitionOut).onComplete(function()
			{
				//visible = false;
				parent.removeChild(this);
			});
		else{
			visible = false;
			parent.removeChild(this);
		}
	}

	// Handlers

	private function onAdded(e:Event):Void
	{
		if(transitionIn != null)
			TweenManager.applyTransition(this, transitionIn);
		Timer.delay(hide, duration);
	}
}
