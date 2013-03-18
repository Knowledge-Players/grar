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
    public var answers (default, null):Array<QuizzGroup>;

    /**
     * Questions for each rounds
     */
    public var questions (default, null):Array<{ref:String, content:String}>;

    /**
     * State of correction of the quizz
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
        super(content);
        answers = new Array<QuizzGroup>();
        questions = new Array<{ref:String, content:String}>();
        groupRefs = new Array<String>();

        XmlLoader.load(content, onLoadComplete, parseContent);
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

    public function getCurrentAnswers():QuizzGroup
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
     * Validate the quizz
     * @return true if the quizz is over
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
