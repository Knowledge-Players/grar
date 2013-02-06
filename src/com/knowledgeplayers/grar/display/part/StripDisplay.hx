package com.knowledgeplayers.grar.display.part;

import nme.display.Sprite;
import com.knowledgeplayers.grar.structure.part.strip.pattern.BoxPattern;
import com.knowledgeplayers.grar.structure.part.Pattern;
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
 * Display for the strip parts, like a comic
 */
class StripDisplay extends PartDisplay {

    private var boxesRef: Array<String>;
    private var currentBox: BoxPattern;
    private var currentItem: TextItem;
    private var boxIndex: Int = 0;

    public function new(part: StripPart)
    {
        super(part);
        boxesRef = new Array<String>();
    }

    // Private

    override private function next(event: ButtonActionEvent): Void
    {
        startPattern(currentBox);
    }

    override private function parseContent(content: Xml): Void
    {
        var displayFast: Fast = new Fast(content).node.Display;
        for(boxNode in displayFast.nodes.Box){
            boxesRef.push(boxNode.att.Ref);
            displaysFast.set(boxNode.att.Ref, boxNode);
        }

        super.parseContent(content);
    }

    override private function startPattern(pattern: Pattern): Void
    {
        currentBox = cast(pattern, BoxPattern);

        var nextItem = pattern.getNextItem();
        if(nextItem != null){
            currentItem = nextItem;
            displayArea = new Sprite();
            setText(nextItem);
        }
        else
            this.nextElement();
    }

    override private function displayPart(): Void
    {
        var array = new Array<{obj: DisplayObject, z: Int}>();
        for(key in displays.keys()){
            if(key == currentItem.ref || currentBox.buttons.exists(key) || key == currentItem.author)
                array.push(displays.get(key));
        }
        array.sort(sortDisplayObjects);
        for(obj in array){
            displayArea.addChild(obj.obj);
        }

        var node = displaysFast.get(boxesRef[boxIndex]);
        Lib.trace(node.x.toString());
        displayArea.x = Std.parseFloat(node.att.X);
        displayArea.y = Std.parseFloat(node.att.Y);
        var mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(displayArea.x, displayArea.y, Std.parseFloat(node.att.Width), Std.parseFloat(node.att.Height));
        displayArea.mask = mask;

        boxIndex++;

        addChild(displayArea);
    }
}