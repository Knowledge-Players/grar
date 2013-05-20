package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.dialog.DialogPart;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.ChoicePattern;
import com.knowledgeplayers.grar.structure.part.Pattern;
import nme.events.MouseEvent;

/**
 * Display of a dialog
 */

class DialogDisplay extends PartDisplay {

	private var currentPattern:Pattern;
	private var nextActivity:Activity;

	/**
     * Constructor
     * @param	part : DialogPart to display
     */

	public function new(part:DialogPart)
	{
		super(part);
	}

	// Private

	override private function next(event:ButtonActionEvent):Void
	{
		if(nextActivity != null){
			GameManager.instance.displayActivity(nextActivity);
			nextActivity = null;
		}
		else
			startPattern(currentPattern);
	}

	override private function startPattern(pattern:Pattern):Void
	{
		super.startPattern(pattern);
		if(Std.is(pattern, ChoicePattern) && inventory != null)
			inventory.visible = false;
		else if(inventory != null)
			inventory.visible = true;

		if(currentPattern != pattern)
			currentPattern = pattern;

		var nextItem = pattern.getNextItem();
		if(nextItem != null){
			setupTextItem(nextItem);
			GameManager.instance.playSound(nextItem.sound);
			if(nextItem.hasActivity()){
				nextActivity = cast(nextItem, RemarkableEvent).getActivity();
			}
			if(nextItem.token != null){
				GameManager.instance.activateToken(nextItem.token);
			}
		}
		else if(currentPattern.nextPattern != "")
			goToPattern(currentPattern.nextPattern);
		else{
			exitPart();
		}
	}

	/**
	* Go to a specific pattern
	* @param    target : Name of the pattern to go
	**/

	public function goToPattern(target:String):Void
	{
		var i = 0;
		while(!(part.elements[i].isPattern() && cast(part.elements[i], Pattern).name == target)){
			i++;
		}

		cast(part.elements[i], Pattern).itemIndex = 0;
		startPattern(cast(part.elements[i], Pattern));
	}

	// Privates

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		super.setButtonAction(button, action);
		if(action.toLowerCase() == ButtonActionEvent.GOTO){
			button.addEventListener(action, onChoice);
			button.addEventListener(MouseEvent.MOUSE_OVER, onOverChoice);
			button.addEventListener(MouseEvent.MOUSE_OUT, onOutChoice);
		}
	}

	private function onChoice(ev:ButtonActionEvent):Void
	{
		var choice = cast(ev.target, DefaultButton);
		var target = cast(currentPattern, ChoicePattern).choices.get(choice.ref).goTo;
		cast(currentPattern, ChoicePattern).choices.get(choice.ref).viewed = true;

		choice.removeEventListener(MouseEvent.MOUSE_OUT, onOutChoice);
		choice.setToggle(false);
		// Clean tooltip
		onOutChoice(null);
		goToPattern(target);
	}

	private function onOverChoice(e:MouseEvent):Void
	{
		//cpp n'aime pas e.target
		var choiceButton = cast(e.currentTarget, DefaultButton);
		var pattern = cast(currentPattern, ChoicePattern);
		var choice:Choice = null;
		for(key in pattern.choices.keys()){
			if(choiceButton.ref == key)
				choice = pattern.choices.get(key);
		}
		if(choice != null && pattern.tooltipRef != null && choice.toolTip != null){
			if(!displays.exists(pattern.tooltipRef))
				throw "[DialogDisplay] There is no ToolTip with ref " + pattern.tooltipRef;
			var tooltip = cast(displays.get(pattern.tooltipRef).obj, ScrollPanel);
			if(displayArea.contains(tooltip))
				displayArea.removeChild(tooltip);
			var content = Localiser.instance.getItemContent(choice.toolTip);
			tooltip.setContent(content);
			var i:Int = 0;
			while(!Std.is(displayArea.getChildAt(i), DefaultButton)){
				i++;
			}

			TweenManager.applyTransition(tooltip, pattern.tooltipTransition);
			displayArea.addChildAt(tooltip, i);
		}
		else{
			removeEventListener(MouseEvent.MOUSE_OVER, onOverChoice);
			removeEventListener(MouseEvent.MOUSE_OUT, onOutChoice);
		}
	}

	private function onOutChoice(e:MouseEvent):Void
	{
		var pattern = cast(currentPattern, ChoicePattern);
		if(pattern.tooltipRef != null)
			displayArea.removeChild(displays.get(pattern.tooltipRef).obj);
	}
}