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

        textSprite = KpTextDownParser.parse(text);

        var alignment:Dynamic = StyleParser.getStyle().getAlignment();
        switch(alignment){
            case TextFormatAlign.CENTER:
                textSprite.x = width / 2 - textSprite.width / 2;
            case TextFormatAlign.RIGHT:
                textSprite.x = width - textSprite.width;
            case TextFormatAlign.LEFT, TextFormatAlign.JUSTIFY:
        }
        var padding = StyleParser.getStyle().getPadding();
        if(textSprite.width > 0 && padding.length > 0){
            textSprite.y += padding[0];
            textSprite.x += padding[3];
            var mask = new Sprite();
            mask.graphics.beginFill(0);
            mask.graphics.drawRect(textSprite.x, textSprite.y, width - padding[1], height - padding[2]);
            mask.graphics.endFill();
            textSprite.mask = mask;
            addChild(mask);
        }

        if(previousStyleSheet != null)
            StyleParser.currentStyleSheet = previousStyleSheet;

        //centerText();
        if(!contains(textSprite))
            addChild(textSprite);
    }

    // Private

    /*private function centerText():Void
    {

        textSprite.x = -textSprite.width / 2;

        textSprite.y = this.downState.y - (textSprite.height / 2);

        #if flash
			 // Remove 3px to match the center of the button
			textSprite.y -= 3;
		#end
    }*/

}