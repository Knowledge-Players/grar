package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import haxe.FastList;
import nme.Lib;
import com.knowledgeplayers.grar.structure.Token;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.structure.part.TextItem;
import nme.events.MouseEvent;
import com.knowledgeplayers.grar.display.element.TokenDisplay;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import nme.display.Sprite;
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

    private var tokens:Hash<Sprite>;
    private var displayedToken:Bitmap;
    private var currentPattern:Pattern;
    private var currentToken:Token;
    private var nextActivity: Activity;

    /**
     * Constructor
     * @param	part : DialogPart to display
     */

    public function new(part:DialogPart)
    {
        tokens = new Hash<Sprite>();
        resizeD = ResizeManager.getInstance();
        super(part);

    }

    // Private

    override private function next(event:ButtonActionEvent):Void
    {
        hideToken();
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
            if(nextItem.hasToken()){

                var token:Token = nextItem.token;
                dispatchEvent(new TokenEvent(TokenEvent.ADD,token, true));
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
            //var token:Bitmap = new Bitmap(Assets.getBitmapData(elemNode.att.id));

            var token:TokenDisplay = new TokenDisplay( spritesheets.get(elemNode.att.spritesheet),elemNode.att.id,Std.parseFloat(elemNode.att.x),Std.parseFloat(elemNode.att.y),Std.parseFloat(elemNode.att.scale),elemNode.att.transitionIn,elemNode.att.transitionOut,elemNode);
            tokens.set(elemNode.att.id, token);

        }
    }

    override private function onTokenAdded(e:TokenEvent):Void
    {
        currentToken = e.token;
        var tok = cast(tokens.get(currentToken.ref),TokenDisplay);
        addChild(tok);

        tok.setImage(currentToken.img);
        var content = Localiser.instance.getItemContent(currentToken.ref);
        var content2 = Localiser.instance.getItemContent(currentToken.img);
        tok.textsToken.get(currentToken.ref).content = KpTextDownParser.parse(content);

        tok.textsToken.get(currentToken.img).content = KpTextDownParser.parse(content2);
        TweenManager.slide(tok,tok.showToken);


    }

    override private function setButtonAction(button:CustomEventButton, action:String):Void
    {
        super.setButtonAction(button, action);
        if(action.toLowerCase() == ButtonActionEvent.GOTO){
            button.addEventListener(action, onChoice);
            button.addEventListener(MouseEvent.MOUSE_OVER, onOverChoice);
            button.addEventListener(MouseEvent.MOUSE_OUT, onOutChoice);
        }
    }

    private function onChoice(ev:ButtonActionEvent):Void
    {
        var choice = cast(ev.target, DefaultButton);
        var target = cast(currentPattern, ChoicePattern).choices.get(choice.ref).goTo;
        choice.removeEventListener(MouseEvent.MOUSE_OUT, onOutChoice);
        goToPattern(target);
    }

    private function onOverChoice(e:MouseEvent):Void
    {
        var choiceButton = cast(e.target, DefaultButton);
        var pattern = cast(currentPattern, ChoicePattern);
        var choice: Choice = null;
        for(key in pattern.choices.keys()){
            if(choiceButton.ref == key)
                choice = pattern.choices.get(key);
        }
        if(choice != null){
            var tooltip = cast(displays.get(pattern.tooltipRef).obj, ScrollPanel);
            var content = Localiser.instance.getItemContent(choice.toolTip);
            tooltip.content = KpTextDownParser.parse(content);
            var i:Int = 0;
            while(!Std.is(displayArea.getChildAt(i), DefaultButton)){
                i++;
            }
            displayArea.addChildAt(tooltip, i);
        }
    }

    private function onOutChoice(e: MouseEvent):Void
    {
        var pattern = cast(currentPattern, ChoicePattern);
        removeChild(displays.get(pattern.tooltipRef).obj);
    }

    private function goToPattern(target:String):Void
    {

        var i = 0;
        while(!(part.elements[i].isPattern() && cast(part.elements[i], Pattern).name == target)){
            i++;
        }

        startPattern(cast(part.elements[i], Pattern));
    }

    private function hideToken():Void{
        if(currentToken != null)
        {
            Lib.trace(currentToken.ref);
            var tok = cast(tokens.get(currentToken.ref),TokenDisplay);

            tok.imgsToken.get(currentToken.img).visible = false;
            tok.textsToken.get(currentToken.img).visible = false;

            TweenManager.slide(tok,tok.hideToken);

        }
    }
}