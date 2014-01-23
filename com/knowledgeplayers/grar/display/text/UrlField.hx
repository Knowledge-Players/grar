package com.knowledgeplayers.grar.display.text;
import com.knowledgeplayers.grar.display.style.StyleParser;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLRequest;

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

	public function new(url:String)
	{
		super();
		this.url = url;
        trace('url  : '+url);
		mouseEnabled = false;
		buttonMode = true;
		addEventListener(MouseEvent.CLICK, onClick);
	}

	private function onClick(e:MouseEvent):Void
	{
		Lib.getURL(new URLRequest(url));
	}
}