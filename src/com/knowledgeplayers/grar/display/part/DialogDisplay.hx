package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import nme.events.MouseEvent;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.ChoicePattern;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.dialog.DialogPart;
import com.knowledgeplayers.grar.structure.part.dialog.item.ChoiceItem;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import haxe.xml.Fast;
import nme.Assets;
import nme.display.Bitmap;
import nme.events.Event;
import nme.Lib;

/**
 * Display of a dialog
 */

class DialogDisplay extends PartDisplay {

    private var tokens: Hash<Bitmap>;
    private var displayedToken: Bitmap;
    private var currentPattern: Pattern;

    /**
     * Constructor
     * @param	part : DialogPart to display
     */

    public function new(part: DialogPart)
    {
        tokens = new Hash<Bitmap>();
        resizeD = ResizeManager.getInstance();
        super(part);

        var lg = part.arrayElements.length;

        for(i in 0...lg){
            Lib.trace("---- " + cast(part.arrayElements[i], Fast).name);
        }
    }

    // Private

    override private function next(event: ButtonActionEvent): Void
    {
        startPattern(currentPattern);
    }

    override private function startPattern(pattern: Pattern): Void
    {

        super.startPattern(pattern);

        if(currentPattern == null)
            currentPattern = pattern;

        if(displayedToken != null){
            removeChild(displayedToken);
            displayedToken = null;
        }

        if(currentPattern.hasChoices()){
            displayChoices();
        }

        var nextItem = pattern.getNextItem();
        if(nextItem != null){
            setText(nextItem);

            if(nextItem.hasActivity()){
                launchActivity(cast(nextItem, RemarkableEvent).activity);
            }
        }
        else
            this.nextElement();
    }

    /*override private function setButtonAction(button: CustomEventButton, action: String): Void
    {
        var listener: ButtonActionEvent -> Void = null;
        switch(action.toLowerCase()) {
            case ButtonActionEvent.NEXT: listener = next;
            default: Lib.trace(action + ": this action is not supported for this part");
        }

        button.addEventListener(action.toLowerCase(), listener);
    }*/

    // Privates

    override private function parseContent(content: Xml): Void
    {
        super.parseContent(content);

        var displayFast: Fast = new Fast(content).node.Display;
        for(tokenNode in displayFast.nodes.Token){
            var token: Bitmap = new Bitmap(Assets.getBitmapData(tokenNode.att.id));
            token.visible = false;
            initDisplayObject(token, tokenNode);

            resizeD.addDisplayObjects(token, tokenNode);
            addChild(token);
            tokens.set(tokenNode.att.name, token);

            dispatchEvent(new TokenEvent(TokenEvent.ADD, true));
        }
    }

    private function displayChoices(): Void
    {
        for(choice in cast(currentPattern, ChoicePattern).choices){
            displays.get(choice.ref).obj.addEventListener(MouseEvent.CLICK, goToPattern);
            addChildAt(displays.get(choice.ref).obj, displays.get(choice.ref).z);
        }
    }

    private function goToPattern(ev: MouseEvent): Void
    {
        var choice = cast(ev.target, DefaultButton);
        var target = cast(currentPattern, ChoicePattern).choices.get(choice.ref).goTo;
        for(elem in part.elements){
            if(elem.isPattern() && cast(elem, Pattern).name == target)
                startPattern(cast(elem, Pattern));
        }
    }
}