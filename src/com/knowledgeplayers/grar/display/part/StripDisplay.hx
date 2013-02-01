package com.knowledgeplayers.grar.display.part;

import nme.display.Sprite;
import com.knowledgeplayers.grar.structure.part.strip.pattern.BoxPattern;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.display.part.pattern.BoxDisplay;
import com.knowledgeplayers.grar.structure.part.TextItem;
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

    private var boxes: Hash<Sprite>;
    private var currentBox: String;

    public function new(part: StripPart)
    {
        super(part);
        boxes = new Hash<Sprite>();
        currentBox = part.getCurrentBox().ref;
    }

    // Private

    override private function next(event: ButtonActionEvent): Void
    {
        showNextBox();
    }

    override private function parseContent(content: Xml): Void
    {
        var displayFast: Fast = new Fast(content).node.Display;
        for(boxNode in displayFast.nodes.Box){
            var box = new Sprite();
            initDisplayObject(box, boxNode);
            boxes.set(boxNode.att.Ref, box);
        }

        super.parseContent(content);
    }

    override private function startPattern(pattern: Pattern): Void
    {
        var box: BoxPattern;
        if(Std.is(pattern, BoxPattern))
            box = cast(pattern, BoxPattern);
        else
            return;

        box.getNextItem();
    }

    private function showNextBox(): Void
    {

    }

    override private function addElement(elem: DisplayObject, node: Fast): Void
    {
        boxes.get(currentBox).addChild(elem);
    }

}