package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.structure.part.strip.box.Box;
import com.knowledgeplayers.grar.structure.part.strip.StripPart;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import nme.events.Event;
import nme.Lib;
import nme.display.DisplayObject;
import haxe.xml.Fast;

/**
 * ...
 * @author kguilloteaux
 */
class StripDisplay extends PartDisplay {

    private var stripPart: StripPart;
    private var content: Xml;
    private var boxesD: Array<BoxDisplay>;

    public function new(part: StripPart)
    {
        boxesD = new Array<BoxDisplay>();
        super(part);


    }

    override private function parseContent(content: Xml): Void
    {
      //Lib.trace("content : "+content);
      //Lib.trace("part : "+part);
        this.content = content;
          for(box in part.patterns){
              var boxD = new BoxDisplay(cast(part, StripPart).getCurrentBox(), content);

              boxD.addEventListener(ButtonActionEvent.NEXT, showNextBox);
              addChild(boxD);
              boxesD.push(boxD);
      }
      //super.parseContent(content);
      //super.nextItem();

    }

    private function showNextBox(e: ButtonActionEvent): Void
    {

        //Lib.trace("showNextBox");
        cast(part,StripPart).nextBox();

        var boxD = new BoxDisplay(cast(part,StripPart).getCurrentBox(), content);
        boxD.addEventListener(ButtonActionEvent.NEXT,showNextBox);
        addChild(boxD);

    }

}