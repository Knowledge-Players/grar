package com.knowledgeplayers.grar.display.activity.quizz;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.quizz.Quizz;
import com.knowledgeplayers.grar.util.DisplayUtils;
import haxe.xml.Fast;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.SimpleButton;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.Lib;
import nme.display.DisplayObject;

/**
 * Display for quizz activity. Since all quizz in a game must look alike,
 * this is a singleton.
 * @author jbrichardet
 */

class QuizzDisplay extends ActivityDisplay {
    /**
     * Instance
     */
    public static var instance (getInstance, null): QuizzDisplay;

    /**
     * Question field
     */
    public var question: StyledTextField;

    /**
     * Validate button
     */
    public var validationButton: DefaultButton;

    /**
     * Group of answers
     */
    public var quizzGroup: QuizzGroupDisplay;

    /**
     * Lock state of the quizz. If true, the answers can't be changed
     */
    public var locked: Bool;

    // Icons
    /**
     * Icon to display when an answer is checked
     */
    public var iconCheck (default, default): BitmapData;

    /**
     * Icon to display when an answer is unchecked
     */
    public var iconUncheck (default, default): BitmapData;

    /**
     * Icon to display when an answer is right
     */
    public var iconCheckRight (default, default): BitmapData;

    /**
     * Icon to display when an answer is wrong
     */
    public var iconCheckWrong (default, default): BitmapData;

    /**
     * Icon to display near the goods answers
     */
    public var correction: BitmapData;

    // Layouts
    /**
     * X postion of the items in a group
     */
    public var itemXOffset: Float;

    /**
     * X position of the correction icon
     */
    public var correctionXOffset: Float;

    /**
     * X offset in the answer group
     */
    public var groupXOffset: Float;

    /**
     * Y offset in the answer group
     */
    public var groupYOffset: Float;

    /**
     * X position of the answer group
     */
    public var groupX: Float;

    /**
     * Y position of the answer group
     */
    public var groupY: Float;

    private var quizz: Quizz;
    private var validateContent: String;
    private var displayObjects: Hash<DisplayObject>;
    private var resizeD: ResizeManager;
    public var content: Fast;

    /**
     * @return the instance
     */

    public static function getInstance(): QuizzDisplay
    {
        if(instance == null)
            return instance = new QuizzDisplay();
        else
            return instance;
    }

    override public function setModel(model: Activity): Activity
    {
        quizz = cast(model, Quizz);
        quizz.addEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
        quizz.addEventListener(Event.COMPLETE, onEndActivity);
        this.model = quizz;
        quizz.loadActivity();

        return model;
    }

    // Private

    private function onEndActivity(e: Event): Void
    {
        model.endActivity();
        unLoad();
        quizz.removeEventListener(PartEvent.EXIT_PART, onEndActivity);
    }

    private function onModelComplete(e: LocaleEvent): Void
    {
        updateRound();
        dispatchEvent(new Event(Event.COMPLETE));
    }

    override public function setDisplay(display: Fast): Void
    {
        parseContent(display.x);
    }

    override public function startActivity(): Void
    {
        model.startActivity();

        addDisplayObjects();

        updateButtonText();
    }

    private function addDisplayObjects(): Void
    {

        displayObjects.set(content.node.Group.att.z, quizzGroup);
        resizeD.addDisplayObjects(quizzGroup, content.node.Group);

        for(p in 1...Lambda.count(displayObjects) + 1){
            //trace("p : "+p);
            if(displayObjects.get(Std.string(p)) != null){
                addChild(displayObjects.get(Std.string(p)));

            }
        }

        //addChild(quizzGroup);
        resizeD.onResize();
    }

    private function new()
    {
        super();
        question = new StyledTextField();
        displayObjects = new Hash<DisplayObject>();
        resizeD = ResizeManager.getInstance();

    }

    private function parseContent(quizz: Xml): Void
    {
        content = new Fast(quizz);
        setLayout(content);
        setIcons(content);

        validationButton = UiFactory.createButtonFromXml(content.node.Button);
        initDisplayObject(validationButton, content.node.Button);

        validationButton.addEventListener(MouseEvent.CLICK, onValidation);
        validateContent = content.node.Button.att.Content;

        question.style = StyleParser.instance.getStyle(content.node.Question.att.Tag);
        question.x = Std.parseFloat(content.node.Question.att.X);
        question.y = Std.parseFloat(content.node.Question.att.Y);

        displayObjects.set(content.node.Button.att.z, validationButton);
        displayObjects.set(content.node.Question.att.z, question);

        resizeD.addDisplayObjects(question, content.node.Question);
        resizeD.addDisplayObjects(validationButton, content.node.Button);

    }

    private function updateButtonText(): Void
    {
        if(Std.is(validationButton, TextButton)){
            var stateId: String = null;
            switch(quizz.state){
                case EMPTY: stateId = "";
                case VALIDATED: stateId = "_correct";
                case CORRECTED: stateId = "_next";
            }

            cast(validationButton, TextButton).setText(Localiser.instance.getItemContent(validateContent + stateId));
        }
    }

    private function onValidation(e: MouseEvent): Void
    {
        switch(quizz.state) {
            case EMPTY: quizzGroup.validate();
                setState(QuizzState.VALIDATED);
                locked = true;
                updateButtonText();
            case VALIDATED: quizzGroup.correct();
                setState(QuizzState.CORRECTED);
                updateButtonText();
            case CORRECTED: var isEnded = quizz.validate();
                if(!isEnded)
                    updateRound();
                updateButtonText();
        }
    }

    private function setIcons(display: Fast): Void
    {
        for(icon in display.nodes.Icon){
            var iconData: BitmapData = Assets.getBitmapData(icon.att.Content);
            switch(icon.att.Type.toLowerCase()) {
                case "good": correction = iconData;
                case "check": iconCheck = iconData;
                case "uncheck": iconUncheck = iconData;
                case "checkright": iconCheckRight = iconData;
                case "checkfalse": iconCheckWrong = iconData;
                default: Lib.trace(icon.att.Type + ": Unsupported icon type");
            }
        }
    }

    private function setLayout(layout: Fast): Void
    {
        itemXOffset = Std.parseFloat(layout.att.ItemXOffset);
        correctionXOffset = Std.parseFloat(layout.att.CorrectionXOffset);
        groupXOffset = Std.parseFloat(layout.node.Group.att.XOffset);
        groupYOffset = Std.parseFloat(layout.node.Group.att.YOffset);
        groupX = Std.parseFloat(layout.node.Group.att.X);
        groupY = Std.parseFloat(layout.node.Group.att.Y);
    }

    private function updateRound(): Void
    {
        if(quizzGroup == null)
            quizzGroup = new QuizzGroupDisplay(quizz.getCurrentAnswers());
        else
            quizzGroup.model = quizz.getCurrentAnswers();
        question.text = Localiser.getInstance().getItemContent(quizz.getCurrentQuestion());
        setState(QuizzState.EMPTY);
    }

    private function setState(state: QuizzState): Void
    {
        quizz.state = state;
        if(quizz.state == QuizzState.EMPTY)
            locked = false;
        else
            locked = true;
    }
}
