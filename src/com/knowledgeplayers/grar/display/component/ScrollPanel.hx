package com.knowledgeplayers.grar.display.component;

import com.knowledgeplayers.grar.factory.UiFactory;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * ScrollPanel to manage text overflow, with auto scrollbar
 */

class ScrollPanel extends Sprite
{
	/**
	 * Text in the panel
	 */
	public var content (default, setContent): Sprite;
	
	/**
	 * ScrollBar of the panel. Null if the content is smaller than the panel
	 */
	public var scrollBar: ScrollBar;
	
	private var maskWidth: Float;
	private var maskHeight: Float;
	private var scrollLock: Bool;
	private var scrollable: Bool;

	/**
	 * Constructor
	 * @param	width : Width of the displayed content
	 * @param	height : Height of the displayed content
	 * @param	scrollLock : Disable scroll. False by default
	 */
	public function new(width: Float, height: Float, scrollLock: Bool = false ) 
	{
		super();
		maskWidth = width;
		maskHeight = height;
		this.scrollLock = scrollLock;
		addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
	}
	
	/**
	 * Set the text to the panel
	 * @param	content : Text to set
	 * @return the text
	 */
	public function setContent(content: Sprite) : Sprite 
	{
		clear();
		this.content = content;
		addChild(content);
		var mask = new Sprite();
		mask.graphics.beginFill(0x000000);
		mask.graphics.drawRect(0, 0, maskWidth, maskHeight);
		mask.graphics.endFill();
		content.mask = mask;
		addChild(mask);
		
		if(maskHeight < content.height && !scrollLock){
			scrollBar = UiFactory.createScrollBar(18, maskHeight, maskHeight/content.height, "scrollbar", "cursor");
			scrollBar.x = maskWidth - scrollBar.width;
			addChild(scrollBar);
			scrollBar.scrolled = scrollToRatio;
			scrollable = true;
		}
		else {
			scrollable = false;
		}
		
		return content;
	}
	
	// Private
	
	private function scrollToRatio(position: Float) 
	{
		content.y = -position * content.height;
	}
	
	private function clear() 
	{
		while (numChildren > 0)
			removeChildAt(numChildren - 1);
	}
	
	private function onWheel(e:MouseEvent):Void 
	{
		if (scrollable) {
			if (e.delta > 0 && content.y + e.delta > 0){
				content.y = 0;
			}
			else if (e.delta < 0 && content.y + e.delta < -(content.height - maskHeight)){
				content.y = -(content.height - maskHeight);
			}
			else{
				content.y += e.delta;
			}
			if(scrollBar != null)
				moveCursor(e.delta);
		}
	}
	
	private function moveCursor(delta: Float)
	{
		scrollBar.moveCursor(delta);
	}
	
}