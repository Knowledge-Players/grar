package com.knowledgeplayers.grar.display.activity;

import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.event.ButtonActionEvent;

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
	public var model(default, set_model):Activity;

	/**
    * Setter for the model
    * @param model : the model to set
    * @return the model
    */

	public function set_model(model:Activity):Activity
	{
		this.model = model;
		this.model.loadActivity();
		return model;


	}

	/**
    * Start the activity
    */

	public function startActivity():Void
	{
		addEventListener(Event.ADDED_TO_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transitionIn);
		});
		addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transitionOut);
		});

		model.startActivity();
        displayActivity();
	}

	/**
    * End the activity
    **/

	public function endActivity(?_target:DefaultButton):Void
	{
		model.endActivity();
		unLoad();
	}

	/**
    * Show the debrief of this activity
    **/

	public function showDebrief():Void
	{
		trace("Debrief!");
	}

	// Private

	private function displayActivity():Void
	{
		// Background
		if(model.background != null){
			addChildAt(displays.get(model.background), 0);
		}

		// Instructions
		var localizedText = Localiser.instance.getItemContent(model.instructionContent);
		cast(displays.get(model.ref), ScrollPanel).setContent(localizedText);
		addChild(displays.get(model.ref));

		// Button
		for(buttonKey in model.button.keys()){
			for(contentKey in model.button.get(buttonKey).keys()){
				cast(displays.get(buttonKey), DefaultButton).setText(Localiser.instance.getItemContent(model.button.get(buttonKey).get(contentKey)), contentKey);
			}
			addChild(displays.get(buttonKey));
		}
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
			button.buttonAction= onValidate;
		}
	}

	// Handlers

	private function onUnload(ev:Event):Void
	{
		// Override in subclass
	}

	private function onValidate(?_target:DefaultButton):Void
	{
		// Override in subclass
	}
}