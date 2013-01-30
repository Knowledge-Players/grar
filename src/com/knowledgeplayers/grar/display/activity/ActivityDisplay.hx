package com.knowledgeplayers.grar.display.activity;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.LocaleEvent;
import nme.events.Event;
import com.knowledgeplayers.grar.structure.activity.Activity;
import haxe.FastList;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;

/**
* Abstract display for an activity
*/

class ActivityDisplay extends Sprite {
    /**
* Model to display
*/
    public var model(default, setModel): Activity;

    /**
* Setter for the model
* @param model : the model to set
* @return the model
*/

    public function setModel(model: Activity): Activity
    {
        this.model = model;
        this.model.addEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
        this.model.addEventListener(Event.COMPLETE, onEndActivity);
        this.model.loadActivity();

        return model;
    }

    /**
* Set the display with XML infos
* @param display : fast XML node with display infos
*/

    public function setDisplay(display: Fast): Void
    {
        parseContent(display);
    }

    /**
* Start the activity
*/

    public function startActivity(): Void
    {
        model.startActivity();
    }

    // Private

    private function parseContent(display: Fast): Void
    {}

    private function onModelComplete(e: LocaleEvent): Void
    {
        dispatchEvent(new Event(Event.COMPLETE));
    }

    private function unLoad(): Void
    {
        while(numChildren > 0)
            removeChildAt(numChildren - 1);
    }

    private function new()
    {
        super();
    }

    private function initDisplayObject(display: DisplayObject, node: Fast): Void
    {
        display.x = Std.parseFloat(node.att.X);
        display.y = Std.parseFloat(node.att.Y);
        if(node.has.Width)
            display.width = Std.parseFloat(node.att.Width);
        else
            display.scaleX = Std.parseFloat(node.att.ScaleX);
        if(node.has.Height)
            display.height = Std.parseFloat(node.att.Height);
        else
            display.scaleY = Std.parseFloat(node.att.ScaleY);
    }

    private function onEndActivity(e: Event): Void
    {
        model.endActivity();
        unLoad();
        model.removeEventListener(PartEvent.EXIT_PART, onEndActivity);
    }
}