package com.knowledgeplayers.grar.display.activity.cards;

import nme.events.Event;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.SimpleButton;
import nme.filters.DropShadowFilter;
import nme.geom.Point;
import nme.Lib;
import nme.events.MouseEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import nme.display.Sprite;
import com.eclecticdesignstudio.motion.Actuate;

/**
* Display of an element in a folder activity
**/
class CardsElementDisplay extends Sprite {
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

    public function new(content: String, width: Float, height: Float, background: String)
    {
        super();
        this.content = content;
        text = new ScrollPanel(width, height);
        buttonMode = true;

        var localizedText = Localiser.instance.getItemContent(content + "_title");
        text.setContent(KpTextDownParser.parse(localizedText));
        text.setBackground(background);
        addChild(text);

        addEventListener(MouseEvent.CLICK, onClick);
        addEventListener(Event.ADDED_TO_STAGE, onAdd);
    }

    public function blockElement(): Void
    {
        removeEventListener(MouseEvent.CLICK, onClick);
        buttonMode = false;
    }

    // Handler

    private function onAdd(ev: Event): Void
    {
        origin = new Point(x, y);
    }

    private function onClick(e: MouseEvent): Void
    {
        var cd = cast(parent, CardsDisplay);
        var localizedText = Localiser.instance.getItemContent(content);
        cd.clickCard(this, localizedText);
    }
}
