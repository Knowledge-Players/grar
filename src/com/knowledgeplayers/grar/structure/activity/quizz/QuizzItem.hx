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
	public var isChecked (default, default): Bool;
	public var isAnswer (default, null): Bool;
	public var content (default, default): String;

	public function new(content: String, isAnswer: Bool = false, isChecked: Bool = false) 
	{
		this.content = content;
		this.isAnswer = isAnswer;
		this.isChecked = isChecked;
	}

	public function toString() : String 
	{
		return "Item ("+content+")";
	}
}