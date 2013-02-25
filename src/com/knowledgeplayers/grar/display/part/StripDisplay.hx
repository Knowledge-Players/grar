package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.strip.pattern.BoxPattern;
import com.knowledgeplayers.grar.structure.part.strip.StripPart;
import com.knowledgeplayers.grar.structure.part.TextItem;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;

/**
 * Display for the strip parts, like a comic
 */
class StripDisplay extends PartDisplay {

    private var boxesref: Array<String>;
    private var currentBox: BoxPattern;
    private var currentItem: TextItem;
    private var boxIndex: Int = 0;


    public function new(part: StripPart)
    {
        super(part);
        boxesref = new Array<String>();
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
            boxesref.push(boxNode.att.ref);
            displaysFast.set(boxNode.att.ref, boxNode);
        }

        super.parseContent(content);
    }

    override private function startPattern(pattern: Pattern): Void
    {
        super.startPattern(pattern);

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

        var node = displaysFast.get(boxesref[boxIndex]);
        displayArea.x = Std.parseFloat(node.att.x);
        displayArea.y = Std.parseFloat(node.att.y);
        var mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(displayArea.x, displayArea.y, Std.parseFloat(node.att.width), Std.parseFloat(node.att.height));
        displayArea.mask = mask;

        boxIndex++;

        addChild(displayArea);
    }
}