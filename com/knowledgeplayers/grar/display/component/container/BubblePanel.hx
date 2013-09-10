package com.knowledgeplayers.grar.display.component.container;

import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.factory.UiFactory;
import nme.display.Sprite;
import nme.events.Event;
import nme.text.TextFormatAlign;

/**
 * Display text in a bubble
 */

class BubblePanel extends ScrollPanel {
	private var spriteSheet:TilesheetEx;
	private var scaleNine:ScaleNine;

	/**
     * Constructor
     * @param	width : Width of the displayed content
     * @param	height : Height of the displayed content
     * @param	scrollLock : Disable scroll. False by default
     * @param   styleSheet : Style sheet used for this panel
     */

	public function new(width:Float, height:Float, ?_scrollLock:Bool = false, ?_spriteSheet:TilesheetEx, ?_styleSheet:String)
	{
		super(width, height, _scrollLock, _styleSheet);
		spriteSheet = _spriteSheet;
	}

	/**
     * Set the text to the panel
     * @param	content : Text to set
     * @return the text
     */

	override public function setContent(contentString:String):Sprite
	{
		clear();

		var previousStyleSheet = null;
		if(styleSheet != null){
			previousStyleSheet = StyleParser.currentStyleSheet;
			StyleParser.currentStyleSheet = styleSheet;
		}

		// TODO clean with new KPTD
		content = new Sprite();//KpTextDownParser.parse(contentString);
		var posXMask:Float = 0;
		var posYMask:Float = 0;
		if(scaleNine != null){
			content.x = scaleNine.middleTile.x - scaleNine.middleTile.width / 2;
			content.y = scaleNine.middleTile.y - scaleNine.middleTile.height / 2;
			maskWidth = scaleNine.middleTile.width;
			maskHeight = scaleNine.middleTile.height;
			posXMask = content.x;
			posYMask = content.y;
		}

		// Type Conflict between Flash and native for TextFormatAlign
		var alignment:Dynamic = StyleParser.getStyle().getAlignment();
		switch(alignment){
			case TextFormatAlign.CENTER:
				content.x = maskWidth / 2 - content.width / 2;
			case TextFormatAlign.RIGHT:
				content.x = maskWidth - content.width;
			case TextFormatAlign.LEFT, TextFormatAlign.JUSTIFY:
		}
		var padding = StyleParser.getStyle().getPadding();
		if(content.width > 0 && padding.length > 0){
			content.y += padding[0];
			content.x += padding[3];
			var mask = new Sprite();
			mask.graphics.beginFill(0);
			mask.graphics.drawRect(0, 0, maskWidth - padding[1], maskHeight - padding[2]);
			mask.graphics.endFill();
			content.mask = mask;
			addChild(mask);
		}

		addChild(content);
		var mask = new Sprite();
		mask.graphics.beginFill(0x000000);
		mask.graphics.drawRect(posXMask, posYMask, maskWidth, maskHeight);
		mask.graphics.endFill();
		this.mask = mask;
		addChild(mask);

		if(maskHeight < content.height && !scrollLock){
			scrollBar = UiFactory.createScrollBar(18, maskHeight, maskHeight / content.height, "scrollbar", "cursor");
			scrollBar.x = maskWidth - scrollBar.width;
			addChild(scrollBar);
			scrollBar.scrolled = scrollToRatio;
			scrollable = true;
		}
		else{
			scrollable = false;
		}

		if(previousStyleSheet != null)
			StyleParser.currentStyleSheet = previousStyleSheet;
		return content;
	}

	override public function setBackground(bkg:String, ?tilesheet:TilesheetEx):Void
	{
		if(spriteSheet == null){
			super.setBackground(bkg, tilesheet);
		}
		else{
			scaleNine = new ScaleNine(maskWidth, maskHeight);
			scaleNine.addEventListener("onScaleInit", onInitScale);
			scaleNine.init(spriteSheet);
		}
	}

	// Private

	private function onInitScale(e:Event):Void
	{
		e.currentTarget.removeEventListener("onScaleInit", onInitScale);
		addChildAt(e.currentTarget, 0);
	}

}