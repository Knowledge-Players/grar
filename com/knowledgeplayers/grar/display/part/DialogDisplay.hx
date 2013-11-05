package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.ChoicePattern;
import com.knowledgeplayers.grar.structure.part.Pattern;
import flash.events.MouseEvent;

/**
 * Display of a dialog
 */

class DialogDisplay extends PartDisplay {

	/**
	* Pattern playing
	**/
	public var currentPattern:Pattern;

	/**
     * Constructor
     * @param	part : DialogPart to display
     */
	public function new(part:Part)
	{
		super(part);
	}

	override public function next(?target: DefaultButton):Void
	{
		startPattern(currentPattern);
	}

	// Private

	override private function startPattern(pattern:Pattern):Void
	{
		super.startPattern(pattern);
		if(Std.is(pattern, ChoicePattern) && inventory != null)
			inventory.visible = false;
		else if(inventory != null)
			inventory.visible = true;

		if(currentPattern != pattern)
			currentPattern = pattern;

		// Check if minimum choices requirements is met
		var exitPattern = false;
		if(Std.is(currentPattern, ChoicePattern)){
			var choice = cast(currentPattern, ChoicePattern);
			trace(choice.minimumChoice, choice.numChoices);
			if(choice.minimumChoice == choice.numChoices)
				exitPattern = true;
		}

		var nextItem = pattern.getNextItem();
		if(nextItem != null && !exitPattern){
			setupItem(nextItem);
			if(nextItem.isText())
				GameManager.instance.playSound(cast(nextItem, TextItem).sound);
			if(nextItem.token != null && nextItem.token != ""){
				for(token in nextItem.token.split(","))
					GameManager.instance.activateToken(token);
			}
		}
		else if(currentPattern.nextPattern != "")
			goToPattern(currentPattern.nextPattern);
		else{
			nextElement(part.getElementIndex(currentPattern));
		}
	}

	// Privates

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		super.setButtonAction(button, action);
		if(action.toLowerCase() == ButtonActionEvent.GOTO){
			button.buttonAction = onChoice;
			button.addEventListener(MouseEvent.MOUSE_OVER, onOverChoice);
			button.addEventListener(MouseEvent.MOUSE_OUT, onOutChoice);
		}
	}

	private function onChoice(?choice: DefaultButton):Void
	{
		cast(currentPattern, ChoicePattern).numChoices++;
		var target = cast(currentPattern, ChoicePattern).choices.get(choice.ref).goTo;
		cast(currentPattern, ChoicePattern).choices.get(choice.ref).viewed = true;

		choice.removeEventListener(MouseEvent.MOUSE_OUT, onOutChoice);
		choice.toggle(false);
		// Clean tooltip
		onOutChoice(null);
		goToPattern(target);
	}

	private function onOverChoice(e:MouseEvent):Void
	{
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
			var tooltip = cast(displays.get(pattern.tooltipRef), ScrollPanel);
			if(contains(tooltip))
				removeChild(tooltip);
			var content = Localiser.instance.getItemContent(choice.toolTip);
			tooltip.setContent(content);
			var i:Int = 0;
			while(!Std.is(getChildAt(i), DefaultButton)){
				i++;
			}

			TweenManager.applyTransition(tooltip, pattern.tooltipTransition);
			addChildAt(tooltip, i);
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
			removeChild(displays.get(pattern.tooltipRef));
	}
}