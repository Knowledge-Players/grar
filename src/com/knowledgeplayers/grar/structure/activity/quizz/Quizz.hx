package com.knowledgeplayers.grar.structure.activity.quizz;

import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.quizz.QuizzGroup;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.events.Event;

/**
 * Structure of the quizz activity
 * @author jbrichardet
 */
class Quizz extends Activity {
    /**
     * Group of answers for each rounds
     */
    public var answers: Array<QuizzGroup>;

    /**
     * Questions for each rounds
     */
    public var questions: Array<String>;

    /**
     * State of correction of the quizz
     */
    public var state: QuizzState;

    private var roundIndex: Int = 0;

    /**
     * Constructor
     * @param	content : Path to the content file
     */

    public function new(?content: String)
    {
        super(content);
        answers = new Array<QuizzGroup>();
        questions = new Array<String>();

        XmlLoader.load(content, onLoadComplete, parseContent);
    }

    override public function startActivity(): Void
    {
        state = QuizzState.EMPTY;
    }

    /**
     * @return the question being asked
     */

    public function getCurrentQuestion(): String
    {
        return questions[roundIndex];
    }

    /**
     * @return the answers being proposed
     */

    public function getCurrentAnswers(): QuizzGroup
    {
        return answers[roundIndex];
    }

    /**
     * Validate the quizz
     * @return true if the quizz is over
     */

    public function validate(): Bool
    {
        // Count points
        if(getCurrentAnswers().isFullyCorrect())
            score++;

        // Next round
        roundIndex++;
        if(roundIndex == questions.length){
            dispatchEvent(new Event(Event.COMPLETE));
            return true;
        }
        else
            return false;
    }

    // Private

    override private function parseContent(content: Xml): Void
    {
        var quizz = new Fast(content).node.Quizz;
        for(round in quizz.nodes.Round){
            questions.push(round.node.Question.att.Content);
            var group = new QuizzGroup();
            for(answer in round.nodes.Answer){
                group.addXmlItem(answer);
            }
            answers.push(group);
        }
    }
}

/**
 * Possible state of the quizz
 */
enum QuizzState {
    EMPTY;
    VALIDATED;
    CORRECTED;
}
