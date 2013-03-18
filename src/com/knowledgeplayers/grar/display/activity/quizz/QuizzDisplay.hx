package com.knowledgeplayers.grar.display.activity.quizz;

import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.quizz.Quizz;
import com.knowledgeplayers.grar.util.LoadData;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.events.MouseEvent;
import Std;

/**
* Display for quizz activity. Since all quizz in a game must look alike,
* this is a singleton.
* @author jbrichardet
*/

class QuizzDisplay extends ActivityDisplay {
    /**
    * Instance
    **/
    public static var instance (getInstance, null):QuizzDisplay;

    /**
    * Graphical item for the quizz (checkboxes, checks, ...)
    **/
    public var items (default, null):Hash<BitmapData>;

    /**
    * Template for groups of answers
    */
    public var quizzGroups (default, null):Hash<QuizzGroupDisplay>;

    /**
    * Backgrounds for the quizz
    **/
    public var backgrounds (default, null):Hash<DisplayObject>;

    /**
    * Lock state of the quizz. If true, the answers can't be changed
    **/
    public var locked:Bool;

    private var quizz:Quizz;
    private var resizeD:ResizeManager;

    /**
* @return the instance
*/

    public static function getInstance():QuizzDisplay
    {
        if(instance == null)
            return instance = new QuizzDisplay();
        else
            return instance;
    }

    override public function setModel(model:Activity):Activity
    {
        return quizz = cast(super.setModel(model), Quizz);
    }

    override public function startActivity():Void
    {
        super.startActivity();

        displayRound();

        updateButtonText();
    }

    override private function displayActivity():Void
    {
        super.displayActivity();
        if(quizz.buttonRef.content != null)
            cast(displays.get(quizz.buttonRef.ref).obj, TextButton).setText(Localiser.instance.getItemContent(quizz.buttonRef.content));
        displays.get(quizz.buttonRef.ref).obj.addEventListener(MouseEvent.CLICK, onValidate);
        addChild(displays.get(quizz.buttonRef.ref).obj);
    }

    // Private

    override private function onModelComplete(e:LocaleEvent):Void
    {
        updateRound();
        super.onModelComplete(e);
    }

    private function displayRound():Void
    {
        addChild(displays.get(quizz.getCurrentQuestion().ref).obj);
        addChild(quizzGroups.get(quizz.getCurrentGroup()));

        resizeD.onResize();
    }

    private function new()
    {
        super();
        items = new Hash<BitmapData>();
        backgrounds = new Hash<DisplayObject>();
        quizzGroups = new Hash<QuizzGroupDisplay>();

        resizeD = ResizeManager.getInstance();
    }

    override private function createElement(elemNode:Fast):Void
    {
        super.createElement(elemNode);
        if(elemNode.name.toLowerCase() == "group"){
            createGroup(elemNode);
        }
    }

    private function createGroup(groupNode:Fast):Void
    {
        var group = new QuizzGroupDisplay(groupNode);
        quizzGroups.set(groupNode.att.ref, group);
        resizeD.addDisplayObjects(group, groupNode);
    }

    private function updateButtonText():Void
    {
        if(Std.is(displays.get(quizz.buttonRef.ref).obj, TextButton)){
            var stateId:String = null;
            switch(quizz.state){
                case EMPTY: stateId = "";
                case VALIDATED: stateId = "_correct";
                case CORRECTED: stateId = "_next";
            }

            cast(displays.get(quizz.buttonRef.ref).obj, TextButton).setText(Localiser.instance.getItemContent(quizz.buttonRef.content + stateId));
        }
    }

    override private function onValidate(e:MouseEvent):Void
    {
        if(quizz.controlMode == "auto"){
            switch(quizz.state) {
                case EMPTY: quizzGroups.get(quizz.getCurrentGroup()).validate();
                    setState(QuizzState.VALIDATED);
                    locked = true;
                    updateButtonText();
                case VALIDATED: quizzGroups.get(quizz.getCurrentGroup()).correct();
                    setState(QuizzState.CORRECTED);
                    updateButtonText();
                case CORRECTED: var isEnded = quizz.validate();
                    if(!isEnded){
                        updateRound();
                        updateButtonText();
                    }
            }
        }
        else{
            quizz.validate();
        }
    }

    private function updateRound():Void
    {
        quizzGroups.get(quizz.getCurrentGroup()).model = quizz.getCurrentAnswers();
        var content = Localiser.getInstance().getItemContent(quizz.getCurrentQuestion().content);
        cast(displays.get(quizz.getCurrentQuestion().ref).obj, ScrollPanel).content = KpTextDownParser.parse(content);
        setState(QuizzState.EMPTY);
        displayRound();
    }

    private function setState(state:QuizzState):Void
    {
        quizz.state = state;
        if(quizz.state == QuizzState.EMPTY)
            locked = false;
        else
            locked = true;
    }
}