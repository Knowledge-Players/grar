package com.knowledgeplayers.grar.display.text;

import com.knowledgeplayers.grar.display.style.Style;
import com.knowledgeplayers.grar.display.style.StyleParser;
import nme.text.TextField;
import nme.text.TextFormat;


/**
 * Textfield with embedded style
 */
class StyledTextField extends TextField {
    /**
     * Style of the text
     */
    public var style(default, setStyle):Style;

    /**
     * Constructor
     * @param	style : Style of the text
     */

    public function new(?style:Style)
    {
        super();

        if(style != null)
            setStyle(style);
        else
            setStyle(StyleParser.getStyle("text"));

        //Default Values
        autoSize = nme.text.TextFieldAutoSize.LEFT;
        embedFonts = true;
        selectable = mouseEnabled = false;
    }

    /**
     * Set the style of the text
     * @param	style : Style to set
     * @return  the style
     */

    public function setStyle(style:Style):Style
    {
        this.style = style;
        if(style != null)
            applyStyle(style);

        return style;
    }

    /**
     * Set a style between bounds
     * @param	style : Style to set
     * @param	startIndex : First affected char
     * @param	endIndex : Last affected char
     */

    public function setPartialStyle(style:Style, startIndex:Int, endIndex:Int):Void
    {
        applyStyle(style, startIndex, endIndex);
    }

    // Private

    private function applyStyle(style:Style, startIndex:Int = -1, endIndex:Int = -1):Void
    {
        var textFormat:TextFormat = new TextFormat(style.getFont().fontName, style.getSize(), style.getColor(), style.getBold(), style.getItalic(), style.getUnderline(), null, null, style.getAlignment(), 0, 0, 0, style.getLeading()[0]);

        if(startIndex == -1 || endIndex == -1)
            defaultTextFormat = textFormat;
        else{
            setTextFormat(textFormat, startIndex, endIndex);
        }
    }
}