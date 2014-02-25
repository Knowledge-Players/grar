package grar.view.part;

import grar.view.component.container.WidgetContainer;
import grar.view.component.container.ScrollPanel;

import flash.events.Event;

import haxe.Timer;

class IntroScreen extends WidgetContainer {

	//public function new(?xml:Fast)
	public function new(isd : WidgetContainerData) {

		//super(xml);
		super(isd);
		
		switch(isd.type) {

			case IntroScreen(d):

				this.duration = d;

			default: 

				throw "Wrong WidgetContainerData type passed to IntroScreen constructor";
		};
	}

	/**
	 * Time (in ms) before the screen disappear
	 **/
	public var duration (default, default) : Int;

	public function setText(content:String, ?key:String):Void
	{
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

	// Privates

	private function hide():Void
	{
// FIWME		if (transitionOut != null)
// FIXME			TweenManager.applyTransition(this, transitionOut).onComplete(function() {

// FIXME					dispose();
// FIXME				});
// FIWME		else{
			dispose();
// FIWME		}
	}

	private function dispose():Void
	{
		if(parent != null)
			parent.removeChild(this);
	}

	// Handlers

	override public function set_transitionIn(transition:String):String
	{
		addEventListener(Event.ADDED_TO_STAGE, function(e:Event) {
			
// FIXME				TweenManager.applyTransition(this, transition);
				Timer.delay(hide, duration);
			});

		return transitionIn = transition;
	}

	override public function set_transitionOut(transition:String):String
	{
		return transitionOut = transition;
	}

}
