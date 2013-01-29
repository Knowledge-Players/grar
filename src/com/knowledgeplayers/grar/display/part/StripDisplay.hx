package com.knowledgeplayers.grar.display.part;

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
    //public static var instance (getInstance, null): AnimagicDisplay;
    /*

    */
 //   private var displayObjects: Hash<DisplayObject>;
  //  private var resizeD: ResizeManager;
    private var stripPart: StripPart;
    private var content: Fast;
    private var boxesD: Array<BoxDisplay>;

    public function new(part: StripPart)
    {
        boxesD = new Array<BoxDisplay>();
       // resizeD = ResizeManager.getInstance();
        super(part);

      //  addDisplayObjects();


    }
    /*private function new()
    {
        super();
        boxesD = new Array<BoxDisplay>();
        resizeD = ResizeManager.getInstance();
    }

    public static function getInstance(): AnimagicDisplay
    {
        if(instance == null)
            return instance = new AnimagicDisplay();
        else
            return instance;
    }
    */





    override private function parseContent(content: Xml): Void
    {
        super.parseContent(content);
        Lib.trace("content : "+content);
        Lib.trace("part : "+part);
        for(box in part.patterns){
            var boxD = new BoxDisplay(cast(part,StripPart).getCurrentBox(), content);
            boxD.addEventListener(ButtonActionEvent.NEXT,showNextBox);
            addChild(boxD);
            boxesD.push(boxD);
        }


    }

    /*private function addDisplayObjects(): Void
    {
        for(box in part.patterns){
            if(part.isStrip()){
                var boxD = new BoxDisplay(cast(part,StripPart).getCurrentBox(), content);
                boxD.addEventListener(ButtonActionEvent.NEXT,showNextBox);
                addChild(boxD);

                boxesD.push(boxD);
            }

            
        }

     

    }  */

    private function showNextBox(e:ButtonActionEvent):Void{

          /*  cast(part,StripPart).nextBox();
    	    var boxD = new BoxDisplay(cast(part,StripPart).getCurrentBox(), content);
    	    boxD.addEventListener(ButtonActionEvent.NEXT,showNextBox);
    	    addChild(boxD);
    	    */

    }

}