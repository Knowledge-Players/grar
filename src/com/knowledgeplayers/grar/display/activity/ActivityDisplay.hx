package com.knowledgeplayers.grar.display.activity;

import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.util.SpriteSheetLoader;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;



/**
* Abstract display for an activity
*/

class ActivityDisplay extends Sprite {
    /**
    * Model to display
    */
    public var model(default, setModel): Activity;

    private var spriteSheets: Hash<TilesheetEx>;
    private var countSpriteSheets: Int;
    private var totalSpriteSheets: Int;
    private var displayXml: Fast;
    private var xmlSprite: Xml;
    private var fastXml: Fast;

    /**
    * Setter for the model
    * @param model : the model to set
    * @return the model
    */

    public function setModel(model: Activity): Activity
    {
        this.model = model;
        this.model.addEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);

        //addEventListener(Event.REMOVED_FROM_STAGE, onUnload);
        this.model.loadActivity();

        return model;
    }

    /**
    * Set the display with XML infos
    * @param display : fast XML node with display infos
    */

    public function setDisplay(display: Fast): Void
    {
        displayXml = display;
        spriteSheets = new Hash<TilesheetEx>();
        countSpriteSheets = 0;
        totalSpriteSheets = Lambda.count(display.nodes.SpriteSheet);

        testPreload();
        for(spr in display.nodes.SpriteSheet){
            var n = new SpriteSheetLoader();
            //var nom = Std.string(spr.att.src).split("/")[1];
            // var url = nom.split(".")[0]+".xml";
            n.addEventListener("loaded", onSpriteSheetLoaded);

            n.init(spr.att.id, spr.att.src);
        }

    }

    private function onSpriteSheetLoaded(e: Event)
    {

        countSpriteSheets ++;
        e.target.removeEventListener(Event.COMPLETE, onSpriteSheetLoaded);
        spriteSheets.set(e.target.name, e.target.spriteSheet);
        testPreload();

        countSpriteSheets ++;

    }

    private function testPreload()
    {
        if(countSpriteSheets == totalSpriteSheets){
            parseContent(displayXml);
        }
    }

    /**
    * Start the activity
    */

    public function startActivity(): Void
    {
        model.startActivity();
    }

    public function showDebrief(): Void
    {
        Lib.trace("Debrief!");
    }

    // Private

    private function parseContent(display: Fast): Void
    {}

    private function unLoad(keepLayer: Int = 0): Void
    {
        while(numChildren > keepLayer)
            removeChildAt(numChildren - 1);
    }

    private function new()
    {
        super();
    }

    private function initDisplayObject(display: DisplayObject, node: Fast): Void
    {
        display.x = Std.parseFloat(node.att.x);
        display.y = Std.parseFloat(node.att.y);
        if(node.has.width)
            display.width = Std.parseFloat(node.att.width);
        else
            display.scaleX = Std.parseFloat(node.att.scaleX);
        if(node.has.height)
            display.height = Std.parseFloat(node.att.height);
        else
            display.scaleY = Std.parseFloat(node.att.scaleY);
    }

    // Handlers

    private function onUnload(ev: Event): Void
    {
        //onEndActivity(null);
    }

    private function endActivity(e: Event): Void
    {
        model.endActivity();
        unLoad();
        model.removeEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
    }

    private function onModelComplete(e: LocaleEvent): Void
    {
        dispatchEvent(new Event(Event.COMPLETE));
    }
}