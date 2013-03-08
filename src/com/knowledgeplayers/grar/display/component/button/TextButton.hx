package com.knowledgeplayers.grar.display.component.button;

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
    private var text: String;
    private var textSprite: Sprite;

    /**
     * Constructor
     * @param	tilesheet : UI tilesheet
     * @param	tile : Tile containing the button
     * @param	eventName : Event triggered by the button
     * @param	text : Text of the button
     * @param	tag : Tag of the text
     */

    public function new(tilesheet: TilesheetEx, tile: String, ?eventName: String, text: String = "")
    {
        super((eventName == null ? "next" : eventName), tilesheet, tile);
        if(eventName == null)
            propagateNativeEvent = true;

        setText(text);
    }

    /**
     * Setter of the text
     * @param	text : Text to set
     */

    public function setText(text: String): Void
    {
        textSprite = KpTextDownParser.parse(text,this.downState.width);
        centerText();
        if(!contains(textSprite))
            addChild(textSprite);
    }

    // Private

    private function centerText(): Void
    {

        textSprite.x =-textSprite.width/2;

        textSprite.y = this.downState.y-(textSprite.height/2);

        #if flash
			 // Remove 3px to match the center of the button
			textSprite.y -= 3;
		#end
    }

}