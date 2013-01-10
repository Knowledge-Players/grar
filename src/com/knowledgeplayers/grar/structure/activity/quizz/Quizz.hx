package com.knowledgeplayers.grar.structure.activity.quizz;

import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.quizz.QuizzGroup;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.events.Event;


/**@
 * @author jbrichardet
 */
class Quizz extends Activity 
{
	public var answers: Array<QuizzGroup>;
	public var questions: Array<String>;
	public var state: QuizzState;
	
	private var roundIndex: Int = 0;

	public function new(?content: String) 
	{
		super(content);
		answers = new Array<QuizzGroup>();
		questions = new Array<String>();

		var xml = XmlLoader.load(content,onLoadComplete);
		#if !flash
			parseContent(xml);
		#end
	}
	
	override public function startActivity(): Void 
	{
		state = QuizzState.EMPTY;
	}
	
	public function getCurrentQuestion() : String 
	{
		return questions[roundIndex];
	}
	
	public function getCurrentAnswers() : QuizzGroup 
	{
		return answers[roundIndex];
	}

	public function validate() : Bool
	{
		// Count points
		
		// Next round
		roundIndex++;
		if (roundIndex == questions.length){
			dispatchEvent(new Event(Event.COMPLETE));
			return true;
		}
		else
			return false;
	}

	private function parseContent(content: Xml) : Void 
	{
		var quizz = new Fast(content).node.Quizz;
		for (round in quizz.nodes.Round) {
			questions.push(round.node.Question.att.Content);
			var group = new QuizzGroup();
			for (answer in round.nodes.Answer) {
				group.addXmlItem(answer);
			}
			answers.push(group);
		}
	}
	
	// Handlers
	
	private function onLoadComplete(event: Event) : Void
	{
		parseContent(XmlLoader.getXml(event));
	}
}

enum QuizzState 
{
	EMPTY;
	VALIDATED;
	CORRECTED;
}
