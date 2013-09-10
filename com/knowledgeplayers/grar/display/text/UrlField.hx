package com.knowledgeplayers.grar.display.text;
import com.knowledgeplayers.grar.display.style.StyleParser;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.Lib;
import nme.net.URLRequest;

/**
 * Url Filed
 */

class UrlField extends Sprite {
	/**
     * Url targeted by the field
     */
	public var url:String;

	private var textField:StyledTextField;

	/**
     * Constructor
     * @param	url : URL to target
     * @param	text : text to display instead of the URL
     */

	public function new(url:String, ?text:String)
	{
		super();
		this.url = url;
		textField = new StyledTextField(StyleParser.getStyle("url"));
		textField.text = (text == null ? url : text);
		textField.mouseEnabled = false;
		addChild(textField);
		buttonMode = true;
		addEventListener(MouseEvent.CLICK, onClick);
	}

	private function onClick(e:MouseEvent):Void
	{
		Lib.getURL(new URLRequest(url));
	}
}