package com.knowledgeplayers.grar.display.activity.quiz;

import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.event.ButtonActionEvent;

import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.quiz.Quiz;
import haxe.xml.Fast;
import nme.display.BitmapData;
import nme.display.DisplayObject;

/**
* Display for quiz activity. Since all quiz in a game must look alike,
* this is a singleton.
* @author jbrichardet
*/

class QuizDisplay extends ActivityDisplay {
	/**
    * Instance
    **/
	public static var instance (get_instance, null):QuizDisplay;

	/**
    * Graphical item for the quiz (checkboxes, checks, ...)
    **/
	public var items (default, null):Map<String, BitmapData>;

	/**
    * Template for groups of answers
    */
	public var quizGroups (default, null):Map<String, QuizGroupDisplay>;

	/**
    * Backgrounds for the quiz
    **/
	public var backgrounds (default, null):Map<String, DisplayObject>;

	/**
    * Lock state of the quiz. If true, the answers can't be changed
    **/
	public var locked:Bool;

	private var quiz:Quiz;
	private var resizeD:ResizeManager;

	/**
* @return the instance
*/

	public static function get_instance():QuizDisplay
	{
		if(instance == null)
			return instance = new QuizDisplay();
		else
			return instance;
	}

	override public function set_model(model:Activity):Activity
	{
        var model = super.set_model(model);
		quiz = cast(model, Quiz);
		return model;
	}

	override public function startActivity():Void
	{
		super.startActivity();

		updateRound();
		displayRound();

		updateButtonText();
	}

	// Private

	private function displayRound():Void
	{
		addChild(displays.get(quiz.getCurrentQuestion().ref));
		addChild(quizGroups.get(quiz.getCurrentGroup()));

		resizeD.onResize();
	}

	private function new()
	{
		super();
		items = new Map<String, BitmapData>();
		backgrounds = new Map<String, DisplayObject>();
		quizGroups = new Map<String, QuizGroupDisplay>();

		resizeD = ResizeManager.get_instance();
	}

	override private function createElement(elemNode:Fast):Void
	{
		super.createElement(elemNode);
		if(elemNode.name.toLowerCase() == "group"){
			createGroup(elemNode);
		}
	}

	private function createGroup(groupNode:Fast):Void
	{
		var group = new QuizGroupDisplay(groupNode);
		quizGroups.set(groupNode.att.ref, group);
		resizeD.addDisplayObjects(group, groupNode);
	}

	private function updateButtonText():Void
	{
		var stateId:String = null;
		switch(quiz.state){
			case EMPTY: stateId = "";
			case VALIDATED: stateId = "_correct";
			case CORRECTED: stateId = "_next";
		}

		for(buttonKey in quiz.button.keys()){
			for(contentKey in quiz.button.get(buttonKey).keys()){
				cast(displays.get(buttonKey), DefaultButton).setText(Localiser.instance.getItemContent(quiz.button.get(buttonKey).get(contentKey) + stateId), contentKey);
			}
		}
	}

	override private function onValidate(?_target:DefaultButton):Void
	{
		if(quiz.controlMode == "auto"){
			switch(quiz.state) {
				case EMPTY: quizGroups.get(quiz.getCurrentGroup()).validate();
					setState(QuizzState.VALIDATED);
					locked = true;
					updateButtonText();
				case VALIDATED: quizGroups.get(quiz.getCurrentGroup()).correct();
					setState(QuizzState.CORRECTED);
					updateButtonText();
				case CORRECTED: var isEnded = quiz.validate();
					if(!isEnded){
						updateRound();
						updateButtonText();
					}
			}
		}
		else{
			quiz.validate();
		}
	}

	private function updateRound():Void
	{
		quizGroups.get(quiz.getCurrentGroup()).model = quiz.getCurrentAnswers();
		var content = Localiser.get_instance().getItemContent(quiz.getCurrentQuestion().content);
		cast(displays.get(quiz.getCurrentQuestion().ref), ScrollPanel).setContent(content);
		setState(QuizzState.EMPTY);
	}

	private function setState(state:QuizzState):Void
	{
		quiz.state = state;
		if(quiz.state == QuizzState.EMPTY)
			locked = false;
		else
			locked = true;
	}
}