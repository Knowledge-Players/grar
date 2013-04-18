package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.display.style.Style;
import nme.events.Event;
import com.knowledgeplayers.grar.util.LoadData;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.StyleParser;
import aze.display.TileSprite;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * ScrollPanel to manage text overflow, with auto scrollbar
 */
class ScrollPanel extends Sprite {
	/**
     * Text in the panel
     */
	private var content (default, null):Sprite;

	/**
    * If true, the text won't scroll even if it's bigger than the panel
    **/
	public var scrollLock (default, default):Bool;

	/**
    * Style sheet used for this panel
    **/
	public var styleSheet (default, default):String;

	/**
	* Transition when the text appears
	**/
	public var textTransition (default, default):String;

	/**
	* Transition when the panel appears
	**/
	public var transitionIn (default, default):String;

	/**
	* Transition when the panel disappears
	**/
	public var transitionOut (default, default):String;

	private var scrollBar:ScrollBar;
	private var maskWidth:Float;
	private var maskHeight:Float;
	private var scrollable:Bool;

	/**
    * Background of the panel. It can be only a color or a reference to a Bitmap,
    **/
	private var background:String;

	/**
     * Constructor
     * @param	width : Width of the displayed content
     * @param	height : Height of the displayed content
     * @param	scrollLock : Disable scroll. False by default
     * @param   styleSheet : Style sheet used for this panel
     */

	public function new(width:Float, height:Float, ?_scrollLock:Bool = false, ?_styleSheet:String)
	{
		super();
		maskWidth = width;
		maskHeight = height;
		this.scrollLock = _scrollLock;
		styleSheet = _styleSheet;
		content = new Sprite();
		addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
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

		for(element in KpTextDownParser.parse(contentString)){
			var style:Style = StyleParser.getStyle(element.style);
			var padding = style.getPadding();
			var iconOffset:Float = 0;
			if(style.icon != null)
				iconOffset += style.icon.width;
			if(style.iconMargin != null)
				iconOffset += style.iconMargin[1] + style.iconMargin[3];
			var item = element.createSprite(maskWidth - padding[1] - padding[3] - iconOffset);

			if(isFirst){
				offSetY += padding[0];
				isFirst = false;
			}
			item.x = padding[3];
			item.y = offSetY;
			offSetY += item.height + StyleParser.getStyle(element.style).getLeading()[1];

			content.addChild(item);

		}

		var mask = new Sprite();
		DisplayUtils.initSprite(mask, maskWidth, maskHeight);
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

		if(transitionIn == null)
			displayText();
	}

	public function setBackground(bkg:String, ?tilesheet:TilesheetEx, alpha:Float = 1):Void
	{
		background = bkg;
		if(Std.parseInt(bkg) != null){
			DisplayUtils.initSprite(this, maskWidth, maskHeight, Std.parseInt(bkg), alpha);
		}
		else if(background.indexOf(".") < 0){
			if(tilesheet == null)
				tilesheet = UiFactory.tilesheet;
			var layer = new TileLayer(tilesheet);
			var tile = new TileSprite(background);
			layer.addChild(tile);
			addChildAt(layer.view, 0);
			tile.x += tile.width / 2;
			tile.y += tile.height / 2;
			layer.render();
		}
		else if(LoadData.getInstance().getElementDisplayInCache(background) != null){
			var bkg:Bitmap = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(background), Bitmap).bitmapData);
			bkg.width = maskWidth;
			bkg.height = maskHeight;

			this.addChildAt(bkg, 0);
		}
	}

	// Private

	private function scrollToRatio(position:Float)
	{
		content.y = -position * content.height;
	}

	private function clear()
	{
		content = new Sprite();
		var max = Std.parseInt(background) != null ? 0 : 1;
		while(numChildren > max)
			removeChildAt(numChildren - 1);
	}

	private function displayText():Void
	{
		addChild(content);
		TweenManager.applyTransition(content, textTransition);
	}

	private function moveCursor(delta:Float)
	{
		scrollBar.moveCursor(delta);
	}

	// Handlers

	private function onAdded(e:Event)
	{
		var actuator = TweenManager.applyTransition(this, transitionIn);
		if(actuator != null)
			actuator.onComplete(displayText);
	}

	private function onRemoved(e:Event)
	{
		TweenManager.applyTransition(this, transitionOut);
	}

	private function onWheel(e:MouseEvent):Void
	{
		if(scrollable){
			if(e.delta > 0 && content.y + e.delta > 0){
				content.y = 0;
			}
			else if(e.delta < 0 && content.y + e.delta < -(content.height - maskHeight)){
				content.y = -(content.height - maskHeight);
			}
			else{
				content.y += e.delta;
			}
			if(scrollBar != null)
				moveCursor(e.delta);
		}
	}

}