package com.knowledgeplayers.grar.structure.activity.quizz;

import nme.text.TextField;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * Model for quizz propositions
 * @author jbrichardet
 */
class QuizzItem
{	
	/**
	 * True if the item is checked
	 */
	public var isChecked (default, default): Bool;
	
	/**
	 * True if the item is the answer to the question
	 */
	public var isAnswer (default, null): Bool;
	
	/**
	 * Text of the item
	 */
	public var content (default, default): String;

	/**
	 * Constructor
	 * @param	content : Text of the item
	 * @param	isAnswer : True if the item is the answer. False by default
	 * @param	isChecked : True if the item is checked. False by default
	 */
	public function new(content: String, isAnswer: Bool = false, isChecked: Bool = false) 
	{
		this.content = content;
		this.isAnswer = isAnswer;
		this.isChecked = isChecked;
	}
	
	/**
	 * @return true if the item has been checked and is a correct answer
	 */
	public function isRightAnswered() : Bool 
	{
		return isAnswer == isChecked;
	}

	/**
	 * @return a string-based representation of the item
	 */
	public function toString() : String 
	{
		return "Item ("+content+")";
	}
}