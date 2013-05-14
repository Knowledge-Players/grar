package com.knowledgeplayers.grar.display.activity;

import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.util.DisplayUtils;
import nme.events.Event;
import nme.Lib;

/**
* Abstract display for an activity
*/
class ActivityDisplay extends KpDisplay {
	/**
    * Model to display
    */
	public var model(default, setModel):Activity;

	/**
	* Transition when the activity appears
	**/
	public var transitionIn (default, default):String;

	/**
	* Transition when the activity disappears
	**/
	public var transitionOut (default, default):String;

	/**
    * Setter for the model
    * @param model : the model to set
    * @return the model
    */

	public function setModel(model:Activity):Activity
	{
		this.model = model;
		this.model.addEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
		this.model.loadActivity();

		return model;
	}

	/**
    * Start the activity
    */

	public function startActivity():Void
	{
		model.startActivity();
		displayActivity();
	}

	/**
    * End the activity
    **/

	public function endActivity():Void
	{
		model.endActivity();
		unLoad();
	}

	/**
    * Show the debrief of this activity
    **/

	public function showDebrief():Void
	{
		Lib.trace("Debrief!");
	}

	override public function parseContent(content:Xml):Void
	{
		super.parseContent(content);

		if(displayFast.has.transitionIn)
			transitionIn = displayFast.att.transitionIn;
		if(displayFast.has.transitionOut)
			transitionOut = displayFast.att.transitionOut;
	}

	// Private

	private function displayActivity():Void
	{
		// Background
		if(model.background != null){
			var bkg = displaysFast.get(model.background);
			var width:Float = bkg.has.width ? Std.parseFloat(bkg.att.width) : null;
			var height:Float = bkg.has.height ? Std.parseFloat(bkg.att.height) : null;
			var alpha:Float = bkg.has.alpha ? Std.parseFloat(bkg.att.alpha) : null;
			var x:Float = bkg.has.x ? Std.parseFloat(bkg.att.x) : null;
			var y:Float = bkg.has.y ? Std.parseFloat(bkg.att.y) : null;
			DisplayUtils.setBackground(bkg.att.src, this, width, height, alpha, x, y);
		}

		// Instructions
		var localizedText = Localiser.instance.getItemContent(model.instructionContent);
		cast(displays.get(model.ref).obj, ScrollPanel).setContent(localizedText);
		addChild(displays.get(model.ref).obj);

		// Button
		for(key in model.button.content.keys())
			cast(displays.get(model.button.ref).obj, DefaultButton).setText(Localiser.instance.getItemContent(model.button.content.get(key)), key);
		addChild(displays.get(model.button.ref).obj);
	}

	private function unLoad(keepLayer:Int = 0):Void
	{
		while(numChildren > keepLayer)
			removeChildAt(numChildren - 1);
	}

	private function new()
	{
		super();
	}

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		if(action.toLowerCase() == ButtonActionEvent.NEXT){
			button.addEventListener(ButtonActionEvent.NEXT, onValidate);
		}
	}

	// Handlers

	private function onUnload(ev:Event):Void
	{
		// Override in subclass
	}

	private function onModelComplete(e:LocaleEvent):Void
	{
		model.removeEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);

		addEventListener(Event.ADDED_TO_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transitionIn);
		});
		addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transitionOut);
		});

		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function onValidate(e:ButtonActionEvent):Void
	{
		// Override in subclass
	}
}