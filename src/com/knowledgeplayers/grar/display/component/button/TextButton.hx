package com.knowledgeplayers.grar.display.component.button;

import com.knowledgeplayers.grar.display.element.AnimationDisplay;
import nme.Lib;
import aze.display.TileClip;
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

	public function new(tilesheet:TilesheetEx, tile:String, ?eventName:String, ?_styleSheet:String, ?_animations:Hash<AnimationDisplay>)
	{
		super(tilesheet, tile, (eventName == null ? "next" : eventName), _animations);

		styleSheet = _styleSheet;
		if(eventName == null)
			propagateNativeEvent = true;
	}

	/**
     * Setter of the text
     * @param	text : Text to set
     */

	public function setText(text:String):Void
	{
		if(textSprite != null && contains(textSprite))
			removeChild(textSprite);
		var previousStyleSheet = null;
		if(styleSheet != null){
			previousStyleSheet = StyleParser.currentStyleSheet;
			StyleParser.currentStyleSheet = styleSheet;
		}

		textSprite = new Sprite();
		var offSetY:Float = 0;
		var isFirst:Bool = true;

		for(element in KpTextDownParser.parse(text)){
			element.style = className;
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

		textSprite.y = -textSprite.height / 2;

		/*textSprite.graphics.beginFill(0);
        textSprite.graphics.drawRect(0,0,textSprite.width, textSprite.height);
        textSprite.graphics.endFill();*/

		#if flash
            if(StyleParser.getStyle(className).getAlignment() == TextFormatAlign.CENTER)
        #else
		if(StyleParser.getStyle(className).getAlignment() == "CENTER")
			#end
			textSprite.x = -width / 2;
		else
			#if flash
            if(StyleParser.getStyle(className).getAlignment() == TextFormatAlign.RIGHT)
        #else
		if(StyleParser.getStyle(className).getAlignment() == "RIGHT")
			#end
			textSprite.x = width / 2 - textSprite.width;
		else
			#if flash
            if(StyleParser.getStyle(className).getAlignment() == TextFormatAlign.LEFT)
        #else
		if(StyleParser.getStyle(className).getAlignment() == "LEFT")
			#end
			textSprite.x = -width / 2;

		if(previousStyleSheet != null)
			StyleParser.currentStyleSheet = previousStyleSheet;

		addChild(textSprite);
	}

}