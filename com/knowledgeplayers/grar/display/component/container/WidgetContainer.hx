package com.knowledgeplayers.grar.display.component.container;

import nme.events.Event;
import com.knowledgeplayers.grar.factory.UiFactory;
import nme.display.Sprite;
import nme.events.MouseEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import aze.display.TileSprite;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import com.knowledgeplayers.grar.util.DisplayUtils;
import nme.display.Bitmap;
import haxe.xml.Fast;

/**
* Base for widget that can contain other widget
**/
class WidgetContainer extends Widget{

	/**
	* Background for the container. Could be an int or a src
	**/
	public var background (default, null):String;

	/**
	* Mask width
	**/
	public var maskWidth:Float;

	/**
	* Mask height
	**/
	public var maskHeight:Float;

	/**
	* Tilesheet for the container
	**/
	public var tilesheet (default, set_tilesheet):TilesheetEx;

	/**
	* Enable the scroll. True by default
	**/
	public var scrollable (default, default):Bool = true;

	/**
	* Content alpha
	**/
	public var contentAlpha (default, set_contentAlpha):Float;

	/**
	* Content transition
	**/
	public var contentTransition (default, default):String;

	/**
     * Content root
     */
	public var content (default, default):Sprite;

	public var renderNeeded: Bool = false;

	private var scrollBar:ScrollBar;
	private var layer: TileLayer;

	public function set_contentAlpha(alpha: Float):Float
	{
		return content.alpha = contentAlpha = alpha;
	}

	public function setBackground(bkg:String, alpha: Float = 1):String
	{
		if(bkg != null){
			if(Std.parseInt(bkg) != null){
				DisplayUtils.initSprite(this, maskWidth, maskHeight, Std.parseInt(bkg), alpha);
			}
			else if(bkg.indexOf(".") < 0){
				var tile = new TileSprite(layer, bkg);
				tile.alpha = alpha;
				layer.addChild(tile);
				tile.x += tile.width / 2;
				tile.y += tile.height / 2;
				layer.render();
			}
			else if(AssetsStorage.hasAsset(bkg)){
				var bkg:Bitmap = new Bitmap(AssetsStorage.getBitmapData(bkg));
				bkg.alpha = alpha;
				addChildAt(bkg, 0);
			}
		}

		return background = bkg;
	}

	public function set_tilesheet(tilesheet:TilesheetEx):TilesheetEx
	{
		if(layer == null)
			layer = new TileLayer(tilesheet);
		else
			layer.tilesheet = tilesheet;
		layer.render();
		return this.tilesheet = tilesheet;
	}

	/**
	* Empty the container
	**/
	public function clear()
	{
		removeChild(content);
		content = new Sprite();
		var max = (background != null && background != "") ? 1 : 0;
		while(numChildren > max)
			removeChildAt(numChildren - 1);
	}

	public function maskSprite(sprite: Sprite, maskWidth: Float = 1, maskHeight: Float = 1, maskX: Float = 0, maskY: Float = 0):Void
	{
		var mask = new Sprite();
		DisplayUtils.initSprite(mask, maskWidth, maskHeight, 0, 1, maskX == 0 ? sprite.x : maskX, maskY == 0 ? sprite.y : maskY);
		if(sprite.parent != null)
			sprite.parent.addChild(mask);
		sprite.mask = mask;
	}

	override public function toString():String
	{
		return super.toString()+' $maskWidth x $maskHeight $background';
	}

	// Privates

	private function new(?xml: Fast, ?tilesheet: TilesheetEx)
	{
		content = new Sprite();
		addChild(content);
		if(xml != null){
			maskWidth = xml.has.width ? Std.parseFloat(xml.att.width) : 1;
			maskHeight = xml.has.height ? Std.parseFloat(xml.att.height) : 1;
			contentAlpha = xml.has.contentAlpha ? Std.parseFloat(xml.att.contentAlpha) : 1;
			if(xml.has.contentTransition)
				contentTransition = xml.att.contentTransition;
			if(xml.has.scrollable)
				scrollable =  xml.att.scrollable == "true";
			else
				scrollable = false;
			// Default tilesheet
			if(tilesheet != null)
				this.tilesheet = tilesheet;
			else
				this.tilesheet = UiFactory.tilesheet;
			content.addChild(layer.view);

			setBackground(xml.has.background ? xml.att.background:null, xml.has.alpha ? Std.parseFloat(xml.att.alpha) : 1);
		}
		addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		addEventListener(Event.ENTER_FRAME, checkRender);
		super(xml);
	}

	private function scrollToRatio(position:Float)
	{
		content.y = -position * content.height;
	}

	private function moveCursor(delta:Float)
	{
		scrollBar.moveCursor(delta);
	}

	private function displayContent():Void
	{
		maskSprite(content, maskWidth, maskHeight);

		TweenManager.applyTransition(content, contentTransition);
	}

	private function render():Void
	{
		if(layer.view.x == 0){
			layer.view.x = layer.view.width/2;
			layer.view.y = layer.view.height/2;
		}
		layer.render();
	}

	// Handlers

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

	private function checkRender(e:Event):Void
	{
		if(renderNeeded){
			render();
			renderNeeded = false;
		}
	}
}
