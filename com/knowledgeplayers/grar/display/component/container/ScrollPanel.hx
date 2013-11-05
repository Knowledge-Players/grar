package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.display.style.KpTextDownElement;
import aze.display.TileSprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.localisation.Localiser;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.Style;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import flash.display.Sprite;

/**
* ScrollPanel to manage text overflow, with auto scrollbar
*/
class ScrollPanel extends WidgetContainer {

	/**
    * Style sheet used for this panel
    **/
	public var styleSheet (default, default):String;

	/**
	* Used to force a style on this scrollpanel
	**/
	public var style (default, default):String;

	/**
	* If true, resize the panel to the text width
	**/
	public var trim (default, default):Bool;

		/**
     * Constructor
     * @param	width : Width of the displayed content
     * @param	height : Height of the displayed content
     * @param	scrollLock : Disable scroll. False by default
     * @param   styleSheet : Style sheet used for this panel
     */
	public function new(?xml: Fast, ?width:Float, ?height:Float, ?_styleSheet:String)
	{
		super(xml);
		if(xml != null){
			styleSheet = xml.has.styleSheet ? xml.att.styleSheet : null;
			style = xml.has.style ? xml.att.style : null;
			if(xml.has.content){
				setContent(Localiser.instance.getItemContent(xml.att.content));

			}
			trim = xml.has.trim ? xml.att.trim == "true" : false;
		}
		if(_styleSheet != null)
			styleSheet = _styleSheet;
	}

	/**
     * Set the text to the panel
     * @param	content : Text to set
     * @return the text
     */

	public function setContent(contentString:String):Void
	{
		clear();
		var previousStyleSheet = null;
		if(styleSheet != null){
			previousStyleSheet = StyleParser.currentStyleSheet;
			StyleParser.currentStyleSheet = styleSheet;
		}

		var offSetY:Float = 0;
		var isFirst:Bool = true;

		var maskLine = new Sprite();

		var text = new Sprite();
		for(element in KpTextDownParser.parse(contentString)){
			if(style != null)
				element.style = style;
			var style:Style = StyleParser.getStyle(element.style);
			if(style == null)
				throw "[ScrollPanel] There is no style \"" + element.style + "\" in style sheet \"" + StyleParser.currentStyleSheet + "\".";
			var padding = style.getPadding();
			var iconOffset:Float = 0;
			if(style.icon != null)
				iconOffset += style.icon.width;
			if(style.iconMargin != null)
				iconOffset += style.iconMargin[1] + style.iconMargin[3];
			var item = element.createSprite(maskWidth - padding[1] - padding[3] - iconOffset, trim);

			if(isFirst){
				offSetY += padding[0];
				isFirst = false;
			}
			item.x = padding[3];
			item.y = offSetY;
			offSetY += item.height + style.getLeading()[1];
			if(scrollable){
				for(i in 0...element.numLines){
					var m = new Sprite();
					m.y = item.y + (i * element.lineHeight);
					m.x = item.x;
					DisplayUtils.initSprite(m, element.lineWidth, element.lineHeight + 2);
					maskLine.addChild(m);
				}
			}
			text.addChild(item);
		}
		content.alpha = contentAlpha;
		content.addChild(text);
		if(!scrollable)
			DisplayUtils.initSprite(maskLine, text.width, maskHeight);
		content.addChild(maskLine);
		text.mask = maskLine;
		addChild(content);
		displayContent(trim);

		if(previousStyleSheet != null)
			StyleParser.currentStyleSheet = previousStyleSheet;

	}
}