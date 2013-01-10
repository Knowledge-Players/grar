package com.knowledgeplayers.grar.structure.activity.quizz;
import haxe.xml.Fast;

/**
 * @author jbrichardet
 */
class QuizzGroup
{
	public var items (default, null): List<QuizzItem>;

	public function new() 
	{
		items = new List<QuizzItem>();
	}

	public function addItem(item: QuizzItem) : Void
	{
		items.add(item);
	}

	public function addXmlItem(item: Fast) : Void
	{
		var isAnswer = false;
		if (item.has.IsAnswer)
			isAnswer = item.att.IsAnswer == "true";
		items.add(new QuizzItem(item.att.Content, isAnswer));
	}
}