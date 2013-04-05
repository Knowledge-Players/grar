package com.knowledgeplayers.grar.display.component.button;

import nme.text.TextFormatAlign;
import nme.text.TextField;
import nme.display.Sprite;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.display.text.StyledTextField;

/**
 * Button with text
 */

class TextButton extends CustomEventButton {
    private var text:String;
    private var textSprite:Sprite;
    private var styleSheet:String;

    /**
     * Constructor
     * @param	tilesheet : UI tilesheet
     * @param	tile : Tile containing the button
     * @param	eventName : Event triggered by the button
     * @param	stylesheet : Style sheet for the text
     */

    public function new(tilesheet:TilesheetEx, tile:String, ?eventName:String, ?_styleSheet:String)
    {
        super(tilesheet, tile, (eventName == null ? "next" : eventName));
        styleSheet = _styleSheet;
        if(eventName == null)
            propagateNativeEvent = true;

        //setText(text);
    }

    /**
     * Setter of the text
     * @param	text : Text to set
     */

    public function setText(text:String):Void
    {
        var previousStyleSheet = null;
        if(styleSheet != null){
            previousStyleSheet = StyleParser.currentStyleSheet;
            StyleParser.currentStyleSheet = styleSheet;
        }

        textSprite = new Sprite();
        var offSetY:Float = 0;
        var isFirst:Bool = true;

        for(element in KpTextDownParser.parse(text)){
            var padding = StyleParser.getStyle(element.style).getPadding();
            var item = element.createSprite(width - padding[1] - padding[3]);

            if(isFirst){
                offSetY += padding[0];
            }
            item.x = padding[3];
            item.y = offSetY;
            offSetY += item.height;

            textSprite.addChild(item);

        }
        if(previousStyleSheet != null)
            StyleParser.currentStyleSheet = previousStyleSheet;

        //centerText();
        if(!contains(textSprite))
            addChild(textSprite);
    }
}