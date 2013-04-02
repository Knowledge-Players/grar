package com.knowledgeplayers.grar.display.activity;

import nme.events.MouseEvent;
import com.knowledgeplayers.grar.util.DisplayUtils;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

/**
* Abstract display for an activity
*/
class ActivityDisplay extends KpDisplay {
    /**
    * Model to display
    */
    public var model(default, setModel):Activity;

    /**
    * Setter for the model
    * @param model : the model to set
    * @return the model
    */

    public function setModel(model:Activity):Activity
    {
        this.model = model;
        this.model.addEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
        this.model.loadActivity();

        return model;
    }

    /**
    * Start the activity
    */

    public function startActivity():Void
    {
        model.startActivity();
        displayActivity();
    }

    /**
    * End the activity
    **/

    public function endActivity():Void
    {
        model.endActivity();
        unLoad();
    }

    /**
    * Show the debrief of this activity
    **/

    public function showDebrief():Void
    {
        Lib.trace("Debrief!");
    }

    // Private

    private function displayActivity():Void
    {

        if(model.background != null)
            DisplayUtils.setBackground(displaysFast.get(model.background).att.src, this);
    }

    private function unLoad(keepLayer:Int = 0):Void
    {
        while(numChildren > keepLayer)
            removeChildAt(numChildren - 1);
    }

    private function new()
    {
        super();
    }

    // Handlers

    private function onUnload(ev:Event):Void
    {
        // Override in subclass
    }

    private function onModelComplete(e:LocaleEvent):Void
    {
        model.removeEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
        dispatchEvent(new Event(Event.COMPLETE));
    }

    private function onValidate(e:MouseEvent):Void
    {
        // Override in subclass
    }
}