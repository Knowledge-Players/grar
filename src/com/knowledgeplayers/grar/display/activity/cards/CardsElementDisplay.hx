package com.knowledgeplayers.grar.display.activity.cards;

import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
* Display of an element in a folder activity
**/
class CardsElementDisplay extends Sprite {
    /**
    * Text of the element
**/
    public var text (default, null):ScrollPanel;

    /**
    * Content ID
**/
    public var content (default, null):String;

    /**
    * Constructor
    * @param content : Text of the element
    * @param width : Width of the element
    * @param height : Height of the element
**/

    public function new(content:String, width:Float, height:Float, background:String)
    {
        super();
        this.content = content;
        text = new ScrollPanel(width, height);
        buttonMode = true;

        var localizedText = Localiser.instance.getItemContent(content + "_title");
        text.setContent(localizedText);
        text.setBackground(background);
        addChild(text);

        addEventListener(MouseEvent.CLICK, onClick);
    }

    public function blockElement():Void
    {
        removeEventListener(MouseEvent.CLICK, onClick);
        buttonMode = false;
    }

    private function onClick(e:MouseEvent):Void
    {
        var cd = cast(parent, CardsDisplay);
        var localizedText = Localiser.instance.getItemContent(content);
        cd.clickCard(this, localizedText);
    }
}
