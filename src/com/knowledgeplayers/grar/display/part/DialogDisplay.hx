package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.structure.part.dialog.DialogPart;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.ChoicePattern;
import com.knowledgeplayers.grar.structure.part.Pattern;
import haxe.xml.Fast;
import nme.Assets;
import nme.display.Bitmap;

/**
 * Display of a dialog
 */

class DialogDisplay extends PartDisplay {

    private var tokens:Hash<Bitmap>;
    private var displayedToken:Bitmap;
    private var currentPattern:Pattern;
    private var nextActivity: Activity;

    /**
     * Constructor
     * @param	part : DialogPart to display
     */

    public function new(part:DialogPart)
    {
        tokens = new Hash<Bitmap>();
        resizeD = ResizeManager.getInstance();
        super(part);

    }

    // Private

    override private function next(event:ButtonActionEvent):Void
    {
        if(nextActivity != null){
            GameManager.instance.displayActivity(nextActivity);
            nextActivity = null;
        }
        else
            startPattern(currentPattern);
    }

    override private function startPattern(pattern:Pattern):Void
    {
        super.startPattern(pattern);

        if(currentPattern != pattern)
            currentPattern = pattern;

        if(displayedToken != null){
            removeChild(displayedToken);
            displayedToken = null;
        }

        var nextItem = pattern.getNextItem();
        if(nextItem != null){
            setText(nextItem);

            if(nextItem.hasActivity()){
                nextActivity = cast(nextItem, RemarkableEvent).activity;
            }
        }
        else if(currentPattern.nextPattern != "")
            goToPattern(currentPattern.nextPattern);
        else
            dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
    }

    // Privates

    override private function createElement(elemNode:Fast):Void
    {
        super.createElement(elemNode);

        if(elemNode.name.toLowerCase() == "token"){
            var token:Bitmap = new Bitmap(Assets.getBitmapData(elemNode.att.id));
            token.visible = false;
            addElement(token, elemNode);
            tokens.set(elemNode.att.name, token);

            dispatchEvent(new TokenEvent(TokenEvent.ADD, true));
        }
    }

    override private function setButtonAction(button:CustomEventButton, action:String):Void
    {
        super.setButtonAction(button, action);
        if(action.toLowerCase() == ButtonActionEvent.GOTO){
            button.addEventListener(action, onChoice);
        }
    }

    private function onChoice(ev:ButtonActionEvent):Void
    {
        var choice = cast(ev.target, DefaultButton);
        var target = cast(currentPattern, ChoicePattern).choices.get(choice.ref).goTo;
        goToPattern(target);
    }

    private function goToPattern(target:String):Void
    {
        var i = 0;
        while(!(part.elements[i].isPattern() && cast(part.elements[i], Pattern).name == target)){
            i++;
        }
        startPattern(cast(part.elements[i], Pattern));
    }
}