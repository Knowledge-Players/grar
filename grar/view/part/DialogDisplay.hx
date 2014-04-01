package grar.view.part;

import js.html.Element;

import grar.view.part.PartDisplay;

import grar.model.part.Part;
import grar.model.part.dialog.ChoicePattern;
import grar.model.part.Pattern;

import haxe.ds.StringMap;

/**
 * Display of a dialog
 */

class DialogDisplay extends PartDisplay {

	/**
     * Constructor
     * @param	part : DialogPart to display
     */
	public function new(callbacks : grar.view.DisplayCallbacks) {

		super(callbacks);
	}

	/**
	 * Pattern playing
	 **/
	public var currentPattern : Pattern;

	/*override public function next() : Void {

		//onSoundToStop();

		//startPattern(currentPattern);
	}*/


	///
	// INTERNALS
	//

	/*override private function startPattern(pattern : Pattern) : Void {

		super.startPattern(pattern);

		if (currentPattern != pattern) {

			currentPattern = pattern;
		}

		// Check if minimum choices requirements is met
		var exitPattern = false;

		if (Std.is(currentPattern, ChoicePattern)) {

			var choicePattern = cast(currentPattern, ChoicePattern);

			// Init button with choice's view state
			for (choice in choicePattern.choices.keys()) {

				var choiceTemplate = Browser.document.getElementById(choice);
				if(choiceTemplate == null)
					throw "[DialogDisplay] There is no template for choice named '"+choice+"'.";

				if(!choicePattern.choices.get(choice).viewed)
					choiceTemplate.classList.add("viewed");
			}

			if (choicePattern.minimumChoice == choicePattern.numChoices) {
				exitPattern = true;
			}
		}
		if (pattern != null) {

			var next : Item = pattern.getNextItem();

			if (next != null && !exitPattern) {

				crawlTextGroup(next, pattern);

			} else if (currentPattern.nextPattern != "") {

				goToPattern(currentPattern.nextPattern);

			} else {

				var nextIndex = part.getElementIndex(Pattern(currentPattern));

				currentPattern = null;

				nextElement(nextIndex);
			}

		} else {

			nextElement();
		}
	}*/

	/*override private function setButtonAction(button : Element, action : String) : Bool {

		if (action.toLowerCase() == "goto") {

			button.onclick = function(_) onChoice(button);
			//button.onmouseover = function() onOverChoice(button);
			//button.onmouseout =  function() onOutChoice(button);

			return true;
		}

		return super.setButtonAction(button, action);
	}

	override private function onVideoComplete(_):Void
	{
		super.onVideoComplete();
		next();
	}*/

	private function onChoice(?choice: Element):Void
	{
		//onSoundToStop();

		cast(currentPattern, ChoicePattern).numChoices++;
		var target = cast(currentPattern, ChoicePattern).choices.get(choice.id).goTo;
		cast(currentPattern, ChoicePattern).choices.get(choice.id).viewed = true;

		choice.onmouseout = null;
		choice.classList.add("visited");

		//goToPattern(target);
	}

	/*private function onOverChoice(e:MouseEvent):Void
	{
		var choiceButton = cast(e.currentTarget, grar.view.component.container.DefaultButton);
		var pattern = cast(currentPattern, ChoicePattern);
		var choice:Choice = null;
		for(key in pattern.choices.keys()){
			if(choiceButton.ref == key)
				choice = pattern.choices.get(key);
		}
		if(choice != null && pattern.tooltipRef != null && choice.toolTip != null){
			if(!displaysRefs.exists(pattern.tooltipRef))
				throw "[DialogDisplay] There is no ToolTip with ref " + pattern.tooltipRef;
			var tooltip : grar.view.component.container.ScrollPanel = cast displaysRefs.get(pattern.tooltipRef);

			if (contains(tooltip)) {
				removeChild(tooltip);
			}
			var content = onLocalizedContentRequest(choice.toolTip);

			tooltip.setContent(content);

			var i:Int = 0;
			while(!Std.is(getChildAt(i), grar.view.component.container.DefaultButton)){
				i++;
			}

			TweenUtils.applyTransition(tooltip, transitions, pattern.tooltipTransition);

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
			removeChild(displaysRefs.get(pattern.tooltipRef));
	}*/
}