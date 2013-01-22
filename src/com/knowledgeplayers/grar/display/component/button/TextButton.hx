package com.knowledgeplayers.grar.display.component.button;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.display.text.StyledTextField;

/**
 * Button with text
 */

class TextButton extends CustomEventButton
{	
	private var textField: StyledTextField;
	
	/**
	 * Constructor
	 * @param	tilesheet : UI tilesheet
	 * @param	tile : Tile containing the button
	 * @param	eventName : Event triggered by the button
	 * @param	text : Text of the button
	 * @param	tag : Tag of the text
	 */
	public function new(tilesheet: TilesheetEx, tile: String, ?eventName: String, text: String = "", ?tag: String) 
	{
		super((eventName==null?"next":eventName), tilesheet, tile);
		if (eventName == null)
			propagateNativeEvent = true;
		
		textField = new StyledTextField();
		textField.selectable = false;
		textField.mouseEnabled = false;
		setText(text, tag);
		
		addChild(textField);
	}
	
	/**
	 * Setter of the text
	 * @param	text : Text to set
	 * @param	tag : Tag of the text
	 */
	public function setText(text: String, ?tag: String) : Void
	{
		if (tag != null)
			textField.style = StyleParser.instance.getStyle(tag);
		if (text != null)
			textField.text = text;
		
		centerText();
	}
	
	/**
	 * @return the text of the button
	 */
	public function getText() : String
	{
		return textField.text;
	}
	
	// Private
	
	private function centerText() : Void 
	{
		textField.x = -textField.width / 2;
		textField.y = -(textField.height / 2);
		
		#if flash
			 // Remove 3px to match the center of the button
			textField.y -= 3;
		#end
	}
	
}