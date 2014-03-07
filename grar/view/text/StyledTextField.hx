package grar.view.text;

import grar.view.style.Style;

import flash.text.TextField;
import flash.text.TextFormat;

/**
 * Textfield with embedded style
 */
class StyledTextField extends TextField {

	/**
     * Constructor
     * @param	style : Style of the text
     */
	public function new(? style : Style) {

		super();

		if (style != null) {

			set_style(style);
		}
		// done in parent/owner object  else {

		// done in parent/owner object 	set_style(StyleParser.getStyle("text"));
		// done in parent/owner object }

		//Default Values
		autoSize = flash.text.TextFieldAutoSize.LEFT;
		embedFonts = false; //true; // FIXME problem with openfl Assets.getFont
		selectable = mouseEnabled = false;
	}

	/**
     * Style of the text
     */
	public var style(default, set) : Null<Style> = null;

	/**
     * Set the style of the text
     * @param	style : Style to set
     * @return  the style
     */

	public function set_style(style : Style) : Style {

		this.style = style;
		
		if (style != null) {

			applyStyle(style);
		}

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

	private function applyStyle(style : Style, startIndex : Int = -1, endIndex : Int = -1):Void
	{
//trace("font name is : "+style.getFont().fontName+", "+style.getFont().fontStyle+", "+style.getFont().fontType+
//		", Asset is "+style.getFont());

		var textFormat:TextFormat = new TextFormat(style.getFont().fontName, style.getSize(), style.getColor(), style.getBold(), style.getItalic(), style.getUnderline(), null, null, style.getAlignment(), 0, 0, 0, style.getLeading()[0]);
		//var textFormat:TextFormat = new TextFormat(style.get("font"), style.getSize(), style.getColor(), style.getBold(), style.getItalic(), style.getUnderline(), null, null, style.getAlignment(), 0, 0, 0, style.getLeading()[0]);

		if(startIndex == -1 || endIndex == -1)
			defaultTextFormat = textFormat;
		else{
			setTextFormat(textFormat, startIndex, endIndex);
		}
	}
}