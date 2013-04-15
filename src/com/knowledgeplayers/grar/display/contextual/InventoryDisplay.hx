package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import nme.events.MouseEvent;
import nme.geom.Point;
import com.knowledgeplayers.grar.event.TokenEvent;
import haxe.FastList;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.factory.UiFactory;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.util.LoadData;
import nme.display.BitmapData;
import haxe.xml.Fast;
import nme.display.Sprite;

/**
* View of an inventory
**/
class InventoryDisplay extends Sprite {
	/**
    * BitmapData for the slots when they're locked
    **/
	public var slotBackground (default, default):BitmapData;

	/**
    * BitmapData for the slots when they're unlocked
    **/
	public var slotBackgroundUnlocked (default, default):BitmapData;

	/**
    * Max width. Slots will be centered based on this width
    **/
	public var maxWidth (default, default):Float;

	/**
    * Point to place the token icon into the slot
    **/
	public var iconPosition (default, default):Point;

	/**
    * Scale of the token icon
    **/
	public var iconScale (default, default):Float;

	/**
    * Reference to the transition when tooltip appears
    **/
	public var transitionIn (default, default):String;

	/**
    * Reference to the transition when tooltip disappears
    **/
	public var transitionOut (default, default):String;

	private var tokens:FastList<String>;
	private var slots:Hash<Sprite>;
	private var tooltip:ScrollPanel;
	private var tooltipOrigin:Point;

	/**
    * Constructor
    * @param    fast : Fast XML
    **/

	public function new(?fast:Fast)
	{
		super();
		x = Std.parseFloat(fast.att.x);
		y = Std.parseFloat(fast.att.y);
		maxWidth = Std.parseFloat(fast.att.width);

		var icon = fast.node.Icon;
		iconScale = icon.has.scale ? Std.parseFloat(icon.att.scale) : 1;
		iconPosition = new Point(Std.parseFloat(icon.att.x), Std.parseFloat(icon.att.y));

		var tip:Fast = fast.node.Tooltip;
		tooltip = new ScrollPanel(Std.parseFloat(tip.att.width), Std.parseFloat(tip.att.height), tip.has.style ? tip.att.style : null);
		tooltip.mouseEnabled = false;
		var spritesheet:TilesheetEx = null;
		if(tip.has.spritesheet){
			spritesheet = cast(parent, PartDisplay).spritesheets.get(tip.att.spritesheet);
		}
		tooltip.setBackground(tip.att.background, spritesheet);
		tooltip.x = Std.parseFloat(tip.att.x);
		tooltip.y = Std.parseFloat(tip.att.y);
		tooltipOrigin = new Point(tooltip.x, tooltip.y);
		transitionIn = tip.has.transitionIn ? tip.att.transitionIn : null;
		transitionOut = tip.has.transitionOut ? tip.att.transitionOut : null;

		if(fast.has.src)
			slotBackground = cast(LoadData.instance.getElementDisplayInCache(fast.att.src), Bitmap).bitmapData;
		else
			slotBackground = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, fast.att.id);
		if(fast.has.srcUnlocked)
			slotBackgroundUnlocked = cast(LoadData.instance.getElementDisplayInCache(fast.att.srcUnlocked), Bitmap).bitmapData;
		else if(fast.has.idUnlocked)
			slotBackgroundUnlocked = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, fast.att.idUnlocked);

		slots = new Hash<Sprite>();
		GameManager.instance.addEventListener(TokenEvent.ADD, onTokenActivated);
	}

	/**
    * Init the inventory with all the tokens it will contained
    **/

	public function init(tokens:FastList<String>):Void
	{
		this.tokens = tokens;
		var xOffset:Float = maxWidth / 2 - slotBackground.width * Lambda.count(tokens) / 2;
		for(token in tokens){
			var slot = new Sprite();
			slot.addChild(new Bitmap(slotBackground));
			slot.x = xOffset;
			xOffset += slot.width;
			addChild(slot);
			slots.set(token, slot);
		}
	}

	// Handlers

	private function onTokenActivated(e:TokenEvent):Void
	{
		if(slots.exists(e.token.ref)){
			var slot = slots.get(e.token.ref);
			while(slot.numChildren > 0)
				slot.removeChildAt(slot.numChildren - 1);
			slot.addChild(new Bitmap(slotBackgroundUnlocked));
			var icon = new Bitmap(GameManager.instance.tokensImages.get(e.token.ref));
			icon.scaleX = icon.scaleY = iconScale;
			icon.x = iconPosition.x;
			icon.y = iconPosition.y;
			slot.addChild(icon);
			slot.mouseChildren = false;
			slot.addEventListener(MouseEvent.ROLL_OVER, onOverToken);
			slot.addEventListener(MouseEvent.MOUSE_OUT, onOutToken);
		}
	}

	private function onOverToken(e:MouseEvent):Void
	{
		var slot = cast(e.target, Sprite);
		slot.removeEventListener(MouseEvent.ROLL_OVER, onOverToken);
		tooltip.x += slot.x;
		tooltip.y += slot.y;
		for(key in slots.keys()){
			if(slots.get(key) == slot)
				tooltip.setContent(Localiser.instance.getItemContent(GameManager.instance.inventory.get(key).name));
		}
		if(transitionIn != null)
			TweenManager.applyTransition(tooltip, transitionIn);
		addChild(tooltip);
	}

	private function onOutToken(e:MouseEvent):Void
	{
		var slot = cast(e.target, Sprite);

		if(transitionOut != null)
			TweenManager.applyTransition(tooltip, transitionOut).onComplete(function()
			{
				if(contains(tooltip))
					removeChild(tooltip);
				tooltip.x = tooltipOrigin.x;
				tooltip.y = tooltipOrigin.y;
				slot.addEventListener(MouseEvent.ROLL_OVER, onOverToken);
			});
	}
}
