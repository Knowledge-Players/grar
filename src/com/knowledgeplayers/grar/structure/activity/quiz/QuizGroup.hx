package com.knowledgeplayers.grar.structure.activity.quiz;
import haxe.xml.Fast;

/**
 * Structure for the answer group of the quiz
 * @author jbrichardet
 */
class QuizGroup {
	/**
     * List of items in this group
     */
	public var items (default, null):List<QuizItem>;

	public function new()
	{
		items = new List<QuizItem>();
	}

	/**
     * Add an item to the group
     * @param	item : Item to add
     */

	public function addItem(item:QuizItem):Void
	{
		items.add(item);
	}

	public function getRoundScore():Int
	{
		var rightAnswers:Int = 0;
		for(item in items){
			if(item.isRightAnswered())
				rightAnswers++;
		}
		return Math.round(rightAnswers * 100 / items.length);
	}

	/**
     * Add an XML-described item to the group
     * @param	item : fast XML node with the item infos
     */

	public function addXmlItem(item:Fast):Void
	{
		var isAnswer = false;
		if(item.has.isAnswer)
			isAnswer = item.att.isAnswer == "true";
		items.add(new QuizItem(item.att.content, item.att.ref, isAnswer));
	}
}