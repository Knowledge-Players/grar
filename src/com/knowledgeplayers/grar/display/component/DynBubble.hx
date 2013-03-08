package com.knowledgeplayers.grar.display.component;

import com.eclecticdesignstudio.motion.Actuate;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.display.text.StyledTextField;

/**
 * Container that display text one character at a time
 * @deprecated
 */
class DynBubble
{	
	/**
	 * Instance of the DynBubble
	 */
	public static var instance (getInstance, null): DynBubble;

	private static var isActive: Bool;

	private function new() 
	{
	}

	/**
	 * @return the instance of the bubble
	 */
	public static function getInstance() : DynBubble
	{
		//instance == null ? return new DynBubble() : return instance;
        if(instance == null)
        instance = new DynBubble();
        return instance;
	}

	/**
	 * 
	 * @param	textField
	 * @param	timeNextLetter
	 * @param	timeSpace
	 * @param	timeLine
	 */
	public function convert(textField: StyledTextField, timeNextLetter: Float = 0.05, timeSpace: Float = 0.1, timeLine: Float = 0.5) : Void 
	{
		if (textField == null)
			return ;
		#if flash
			var message: String = textField.getRawText();
		#else
			var message: String = textField.text;
		#end
		nme.Lib.trace("message : "+message);
		textField.text = "";
		if(isActive)
			Actuate.timer(0.1).onComplete(updateTextField, [textField, message, timeNextLetter, "", timeSpace, timeLine]);
		else{
			isActive = true;
			updateTextField(textField, message, timeNextLetter, "", timeSpace, timeLine);			
		}
	}

	/**
	 * Stop the bubble
	 */
	public function stop() 
	{
		isActive = false;
		nme.Lib.trace("STOP ! is active ? "+isActive);
	}

	private function updateTextField(textField: StyledTextField, message: String, timeNextLetter: Float, tag: String, timeSpace: Float = 0.1, timeLine: Float = 0.5) : Void 
	{	
		if(message.length > 0 && isActive){
			var currentLetter: Int = 0;
			var tweakedTime: Float = timeNextLetter;
			if(message.charAt(0) == " ") tweakedTime += timeSpace;
			if(message.charAt(0) == "\n") tweakedTime += timeLine;
			if(message.charAt(0) == "<"){
				var endTag: Int = message.indexOf(">");
				tag = message.substr(1, endTag-1);
				currentLetter += endTag+1;
			}
			if(message.charAt(0) == "<" && message.charAt(1) == "/"){
				tag = "";
			}
			// End of the text, exiting the function
			if(message.charAt(currentLetter) == ""){
				isActive = false;
				return;
			}

			textField.appendText(message.charAt(currentLetter));

			#if flash
				var length: Int = textField.length;
			#else
				var length: Int = textField.text.length;
			#end
			if(tag != "")
				textField.setPartialStyle(StyleParser.instance.getStyle(tag), length-1, length);
			else{
				textField.setPartialStyle(textField.style, length-1, length);
			}
			Actuate.timer(tweakedTime).onComplete(updateTextField, [textField, message.substr(currentLetter+1), timeNextLetter, tag]);
		}
	}
}