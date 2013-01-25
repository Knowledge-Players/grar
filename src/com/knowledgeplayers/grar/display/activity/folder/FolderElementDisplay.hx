package com.knowledgeplayers.grar.display.activity.folder;

import nme.filters.DropShadowFilter;
import nme.geom.Point;
import nme.Lib;
import nme.events.MouseEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import nme.display.Sprite;

/**
* Display of an element in a folder activity
**/
class FolderElementDisplay extends Sprite {
    /**
    * Text of the element
**/
    public var text (default, null): ScrollPanel;

    /**
    * Content ID
**/
    public var content (default, null): String;

    /**
    * Origin before the drag
**/
    public var origin (default, default): Point;

    /**
    * Constructor
    * @param content : Text of the element
    * @param width : Width of the element
    * @param height : Height of the element
**/

    public function new(content: String, width: Float, height: Float)
    {
        super();
        this.content = content;
        text = new ScrollPanel(width, height);
        origin = new Point();
        buttonMode = true;
        filters.push(new DropShadowFilter());
        addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        addEventListener(MouseEvent.MOUSE_UP, onUp);
    }

    public function init(): Void
    {
        var localizedText = Localiser.instance.getItemContent(content + "_title");
        text.setContent(KpTextDownParser.parse(localizedText));
        addChild(text);
    }

    public function blockElement(): Void
    {
        removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
        buttonMode = false;
    }

    // Handler

    private function onDown(e: MouseEvent): Void
    {
        origin.x = x;
        origin.y = y;
        parent.setChildIndex(this, parent.numChildren - 1);
        startDrag();
    }

    private function onUp(e: MouseEvent): Void
    {
        var folder = cast(parent, FolderDisplay);
        if(dropTarget == folder.target)
            folder.drop(this);
        else{
            stopDrag();
            x = origin.x;
            y = origin.y;
        }
    }
}
