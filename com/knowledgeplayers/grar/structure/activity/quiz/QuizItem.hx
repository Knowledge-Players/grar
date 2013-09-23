package com.knowledgeplayers.grar.structure.activity.quiz;

import flash.text.TextField;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;

/**
 * Model for quiz propositions
 */
class QuizItem {
	/**
     * True if the item is checked
     */
	public var isChecked (default, default):Bool;

	/**
     * True if the item is the answer to the question
     */
	public var isAnswer (default, null):Bool;

	/**
     * Text of the item
     */
	public var content (default, default):String;

	/**
    * Ref of the item
**/
	public var ref (default, default):String;

	/**
     * Constructor
     * @param	content : Text of the item
     * @param	isAnswer : True if the item is the answer. False by default
     * @param	isChecked : True if the item is checked. False by default
     */

	public function new(content:String, ref:String, isAnswer:Bool = false, isChecked:Bool = false)
	{
		this.content = content;
		this.ref = ref;
		this.isAnswer = isAnswer;
		this.isChecked = isChecked;
	}

	/**
     * @return true if the item has been checked and is a correct answer
     */

	public function isRightAnswered():Bool
	{
		return isAnswer == isChecked;
	}

	/**
     * @return a string-based representation of the item
     */

	public function toString():String
	{
		return "Item (" + content + ")";
	}
}