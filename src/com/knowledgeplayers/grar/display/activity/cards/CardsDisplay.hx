package com.knowledgeplayers.grar.display.activity.cards;


import com.knowledgeplayers.grar.util.LoadData;
import aze.display.TileClip;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.display.activity.folder.Grid;
import Std;
import nme.events.MouseEvent;
import nme.display.SimpleButton;
import nme.display.Sprite;
import nme.Lib;
import nme.geom.Point;
import com.knowledgeplayers.grar.event.PartEvent;
import haxe.FastList;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import nme.Assets;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.event.LocaleEvent;
import nme.events.Event;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.cards.Cards;
import com.eclecticdesignstudio.motion.Actuate;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;

/**
* Display of the folder activity
**/
class CardsDisplay extends ActivityDisplay {

/**
* Instance
**/
    public static var instance (getInstance, null): CardsDisplay;


/**
* PopUp where additional text will be displayed
**/
    public var popUp (default, default): Sprite;

/**
* Grid to dispatch cards
**/
    public var grids (default, null): Hash<Grid>;


    private var flipLayer: TileLayer;
    private var flipClip:TileClip;
    private var flipDirection:Int;
    private var cardInProgress:CardsElementDisplay;
    private var nextCard:CardsElementDisplay;
    private var nextText:String;

    private var content:Fast;

    private var elementTemplate: {background: String};

/**
* @return the instance
**/

    public static function getInstance(): CardsDisplay
    {
        if(instance == null)
            instance = new CardsDisplay();
        return instance;
    }

/**
*
**/
    public function clickCard(pCard:CardsElementDisplay, pText:String)
    {
        nextCard = pCard;
        nextText = pText;
        if (popUp.visible){
            closePopUp();
        } else {
            launchCard();
        }
    }

// Private

    override private function onModelComplete(e: LocaleEvent): Void
    {
        for(elem in cast(model, Cards).elements){
            var elementDisplay = new CardsElementDisplay(elem.content, grids.get("dispatch").cellSize.width, grids.get("dispatch").cellSize.height, elementTemplate.background);
            grids.get("dispatch").add(elementDisplay, false);
            addChild(elementDisplay);
        }
        super.onModelComplete(e);
    }

    override private function parseContent(content: Fast): Void
    {
        this.content = content;
        Lib.trace("content.node.AnimationElement.att.id : "+content.node.AnimationElement.att.id);
        for(child in content.elements){
            if(child.name.toLowerCase() == "background"){

                var background = cast(LoadData.getInstance().getElementDisplayInCache(child.att.src),Bitmap);
                ResizeManager.instance.addDisplayObjects(background, child);
                addChild(background);

            } else if(child.name.toLowerCase() == "animationelement"){
                var tilesheet = spriteSheets.get(content.node.AnimationElement.att.ref);
                flipLayer = new TileLayer(tilesheet);

                flipClip = new TileClip(content.node.AnimationElement.att.id);
                flipClip.loop = false;
                flipLayer.addChild(flipClip);
                addChild (flipLayer.view);

            } else if(child.name.toLowerCase() == "popup"){
//popUp.addChild(new Bitmap(Assets.getBitmapData(content.node.PopUp.att.background)));
                var pop:Bitmap = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(content.node.PopUp.att.background),Bitmap).bitmapData);
                popUp.addChild(pop);

//var icon = new Bitmap(Assets.getBitmapData(content.node.PopUp.att.buttonIcon));
                var icon:Bitmap = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(content.node.PopUp.att.buttonIcon),Bitmap).bitmapData);
                popUp.addChild(icon);
                popUp.addEventListener(MouseEvent.CLICK, onClosePopUp);
                initDisplayObject(popUp, content.node.PopUp);
                popUp.visible = false;
                popUp.alpha = 0;
                ResizeManager.instance.addDisplayObjects(popUp, content.node.PopUp);
                addChild(popUp);
            }
        }

        for(grid in content.nodes.Grid){
            var g = new Grid(Std.parseInt(grid.att.numRow), Std.parseInt(grid.att.numCol), Std.parseFloat(grid.att.cellWidth), Std.parseFloat(grid.att.cellHeight));
            g.x = Std.parseFloat(grid.att.y);
            g.y = Std.parseFloat(grid.att.x);
            grids.set(grid.att.ref, g);
        }

        var elemNode = content.node.Element;
        elementTemplate = {background: elemNode.att.src};


    }

    private function onClosePopUp(ev: MouseEvent): Void
    {
        nextCard = null;
        nextText = null;
        closePopUp();
    }

    private function closePopUp() {
        popUp.removeChildAt(popUp.numChildren - 1);
        popUp.visible = false;
        flipLayer.view.visible = true;
        flipLayer.view.x = popUp.x + popUp.width/2;
        flipLayer.view.y = popUp.y+ popUp.height/2;
        setChildIndex(flipLayer.view, numChildren - 1);
        flipDirection = -1;
        addEventListener(Event.ENTER_FRAME,onEnterFrameClip);
        Actuate.tween(flipLayer.view, 0.8, {x: cardInProgress.x+cardInProgress.width/2, y:cardInProgress.y+cardInProgress.height/2}).onComplete(launchCard);
    }

    private function launchCard() {
        flipLayer.view.visible = false;
        for (i in 0...numChildren) {
            if (Std.is(getChildAt(i), CardsElementDisplay)) {
                getChildAt(i).visible = true;
            }
        }
        if (nextCard != null) {
            nextCard.visible = false;
            cardInProgress = nextCard;
            flipLayer.view.x = cardInProgress.x + cardInProgress.width/2;
            flipLayer.view.y = cardInProgress.y+ cardInProgress.height/2;
            setChildIndex(flipLayer.view, numChildren - 1);
            flipLayer.view.visible = true;
            flipDirection = 1;
            addEventListener(Event.ENTER_FRAME,onEnterFrameClip);
            Actuate.tween(flipLayer.view, 0.8, {x: popUp.x+popUp.width/2, y:popUp.y+popUp.height/2}).onComplete(showPopUp, [nextText]);
        }
    }

    private function showPopUp (pText:String) {
        popUp.addChild(KpTextDownParser.parse(pText));
        setChildIndex(popUp, numChildren - 1);
        popUp.visible = true;
        Actuate.tween(popUp, 0.5, {alpha: 1});
        flipLayer.view.visible = false;
    }

    private function onEnterFrameClip(e:Event)
    {
        flipClip.currentFrame += 1*flipDirection;
        flipLayer.render();
        if (flipClip.currentFrame == flipClip.totalFrames || flipClip.currentFrame ==0) {
            removeEventListener(Event.ENTER_FRAME,onEnterFrameClip);
        }
    }
    override private function unLoad(keepLayer: Int = 0): Void
    {
        super.unLoad(2);
        for(grid in grids){
            grid.empty();
        }
    }

    private function new()
    {
        super();
        grids = new Hash<Grid>();
        popUp = new Sprite();
    }
}