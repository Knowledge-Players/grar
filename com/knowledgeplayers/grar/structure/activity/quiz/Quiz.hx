package com.knowledgeplayers.grar.structure.activity.quiz;

import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.quiz.QuizGroup;
import haxe.xml.Fast;

/**
 * Structure of the quiz activity
 * @author jbrichardet
 */
class Quiz extends Activity {
	/**
     * Group of answers for each rounds
     */
	public var answers (default, null):Array<QuizGroup>;

	/**
     * Questions for each rounds
     */
	public var questions (default, null):Array<{ref:String, content:String}>;

	/**
     * State of correction of the quiz
     */
	public var state (default, default):QuizzState;

	private var groupRefs:Array<String>;
	private var roundIndex:Int = 0;

	/**
     * Constructor
     * @param	content : Path to the content file
     */

	public function new(?content:String)
	{
		answers = new Array<QuizGroup>();
		questions = new Array<{ref:String, content:String}>();
		groupRefs = new Array<String>();

		super(content);
	}

	override public function startActivity():Void
	{
		state = QuizzState.EMPTY;
	}

	/**
     * @return the question being asked
     */

	public function getCurrentQuestion():{ref:String, content:String}
	{
		return questions[roundIndex];
	}

	/**
     * @return the answers being proposed
     */

	public function getCurrentAnswers():QuizGroup
	{
		return answers[roundIndex];
	}

	/**
    * @return the current group template
**/

	public function getCurrentGroup():String
	{
		return groupRefs[roundIndex];
	}

	/**
     * Validate the quiz
     * @return true if the quiz is over
     */

	public function validate():Bool
	{
		// Count points
		score = getCurrentAnswers().getRoundScore();

		// Next round
		roundIndex++;
		if(roundIndex == questions.length){
			endActivity();
			return true;
		}
		else
			return false;
	}

	// Private

	override private function parseContent(content:Xml):Void
	{
		super.parseContent(content);
		var quizz = new Fast(content.firstElement());
		for(round in quizz.nodes.Round){
			groupRefs.push(round.att.groupRef);
			questions.push({ref: round.node.Question.att.ref, content: round.node.Question.att.content});
			var group = new QuizGroup();
			for(answer in round.nodes.Answer){
				group.addXmlItem(answer);
			}
			answers.push(group);
		}
		ref = getCurrentQuestion().ref;
		instructionContent = getCurrentQuestion().content;
	}
}

/**
 * Possible state of the quiz
 */
enum QuizzState {
	EMPTY;
	VALIDATED;
	CORRECTED;
}
