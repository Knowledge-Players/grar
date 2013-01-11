package com.knowledgeplayers.grar.display.button;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.display.text.StyledTextField;

/**
 * ...
 * @author jbrichardet
 */

class TextButton extends CustomEventButton
{	
	private var textField: StyledTextField;
	
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
	
	public function setText(text: String, ?tag: String) : Void
	{
		if (tag != null)
			textField.style = StyleParser.instance.getStyle(tag);
		if (text != null)
			textField.text = text;
		
		centerText();
	}
	
	public function getText() : String
	{
		return textField.text;
	}
	
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