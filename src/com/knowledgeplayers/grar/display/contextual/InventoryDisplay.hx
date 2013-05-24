package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.structure.Token;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.FastList;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;

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
    * Transition when the token icon appears
    **/
	public var iconTransition (default, default):String;

	/**
    * Reference to the transition when tooltip appears
    **/
	public var tipTransitionIn (default, default):String;

	/**
    * Reference to the transition when tooltip disappears
    **/
	public var tipTransitionOut (default, default):String;

	/**
    * Reference to the transition when inventory appears
    **/
	public var transitionIn (default, default):String;

	/**
    * Reference to the transition when inventory disappears
    **/
	public var transitionOut (default, default):String;

	private var tokens:FastList<String>;
	private var slots:Hash<Sprite>;
	private var tooltip:ScrollPanel;
	private var tooltipOrigin:Point;
	// Fullscreen display
	private var contentToken:ScrollPanel;
	private var closeButton:DefaultButton;
	private var largeImage:Bitmap;
	private var background:Sprite;
	private var title:ScrollPanel;

	private var fullScreenTransitionIn:String;
	private var fullScreenTransitionOut:String;

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
		transitionIn = fast.has.transitionIn ? fast.att.transitionIn : null;
		transitionOut = fast.has.transitionOut ? fast.att.transitionOut : null;

		var icon = fast.node.Icon;
		iconScale = icon.has.scale ? Std.parseFloat(icon.att.scale) : 1;
		iconPosition = new Point(Std.parseFloat(icon.att.x), Std.parseFloat(icon.att.y));
		iconTransition = icon.att.transitionIn;

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
		tipTransitionIn = tip.has.transitionIn ? tip.att.transitionIn : null;
		tipTransitionOut = tip.has.transitionOut ? tip.att.transitionOut : null;

		if(fast.has.src)
			slotBackground = AssetsStorage.getBitmapData(fast.att.src);
		else
			slotBackground = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, fast.att.id);
		if(fast.has.srcUnlocked)
			slotBackgroundUnlocked = AssetsStorage.getBitmapData(fast.att.srcUnlocked);
		else if(fast.has.idUnlocked)
			slotBackgroundUnlocked = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, fast.att.idUnlocked);

		slots = new Hash<Sprite>();

		if(fast.hasNode.Fullscreen){

			var fullscreen:Fast = fast.node.Fullscreen;
			fullScreenTransitionIn = fullscreen.has.transitionIn ? fullscreen.att.transitionIn : null;
			fullScreenTransitionOut = fullscreen.has.transitionOut ? fullscreen.att.transitionOut : null;

			if(fullscreen.hasNode.Text){
				var text:Fast = fullscreen.node.Text;
				contentToken = new ScrollPanel(Std.parseFloat(text.att.width), Std.parseFloat(text.att.height), text.has.style ? text.att.style : null);
				contentToken.x = Std.parseFloat(text.att.x);
				contentToken.y = Std.parseFloat(text.att.y);
			}
			if(fullscreen.hasNode.Title){
				var t:Fast = fullscreen.node.Title;
				title = new ScrollPanel(Std.parseFloat(t.att.width), Std.parseFloat(t.att.height), t.has.style ? t.att.style : null);
				title.x = Std.parseFloat(t.att.x);
				title.y = Std.parseFloat(t.att.y);
			}
			if(fullscreen.hasNode.Item){
				var img:Fast = fullscreen.node.Item;
				largeImage = new Bitmap();
				largeImage.scaleX = largeImage.scaleY = Std.parseFloat(img.att.scale);
				largeImage.x = Std.parseFloat(img.att.x);
				largeImage.y = Std.parseFloat(img.att.y);
			}
			closeButton = UiFactory.createButtonFromXml(fullscreen.node.Button);
			if(fullscreen.node.Button.att.action == "close")
				closeButton.addEventListener("close", closeFullscreen);
			if(fullscreen.hasNode.Background){
				var bkg:Fast = fullscreen.node.Background;
				background = new Sprite();
				DisplayUtils.initSprite(background, Std.parseFloat(bkg.att.width), Std.parseFloat(bkg.att.height), Std.parseInt(bkg.att.color), Std.parseFloat(bkg.att.alpha));
			}
		}
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

		addEventListener(Event.ADDED_TO_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transitionIn);
		});
		addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transitionOut);
		});
	}

	// Handlers

	private function onTokenActivated(e:TokenEvent):Void
	{
		if(slots.exists(e.token.ref)){
			var slot = slots.get(e.token.ref);
			while(slot.numChildren > 0)
				slot.removeChildAt(slot.numChildren - 1);
			slot.addChild(new Bitmap(slotBackgroundUnlocked));
			var icon = new Bitmap(GameManager.instance.tokensImages.get(e.token.ref).small);
			icon.scaleX = icon.scaleY = iconScale;
			icon.x = iconPosition.x;
			icon.y = iconPosition.y;
			slot.addChild(icon);
			TweenManager.applyTransition(icon, iconTransition);
			slot.mouseChildren = false;
			slot.addEventListener(MouseEvent.ROLL_OVER, onOverToken);
			slot.addEventListener(MouseEvent.MOUSE_OUT, onOutToken);
			slot.addEventListener(MouseEvent.CLICK, onClickToken);
		}
	}

	private function onClickToken(e:MouseEvent):Void
	{
		parent.addChild(background);
		var slot = cast(e.target, Sprite);
		var tokenName:String = null;
		for(key in slots.keys()){
			if(slots.get(key) == slot)
				tokenName = key;
			var token:Token = GameManager.instance.inventory.get(tokenName);
			contentToken.setContent(Localiser.instance.getItemContent(token.content));
			largeImage.bitmapData = GameManager.instance.tokensImages.get(tokenName).large;
			title.setContent(Localiser.instance.getItemContent(token.name));
			closeButton.setText(Localiser.instance.getItemContent(token.fullScreenContent));
		}
		parent.addChild(largeImage);
		parent.addChild(closeButton);
		parent.addChild(contentToken);
		parent.addChild(title);
		if(fullScreenTransitionIn != null){
			TweenManager.applyTransition(largeImage, fullScreenTransitionIn);
			TweenManager.applyTransition(background, fullScreenTransitionIn);
			TweenManager.applyTransition(closeButton, fullScreenTransitionIn);
			TweenManager.applyTransition(contentToken, fullScreenTransitionIn);
			TweenManager.applyTransition(title, fullScreenTransitionIn);

		}

	}

	private function closeFullscreen(e:ButtonActionEvent):Void
	{
		if(fullScreenTransitionOut != null){
			TweenManager.applyTransition(largeImage, fullScreenTransitionOut);
			TweenManager.applyTransition(background, fullScreenTransitionOut);
			TweenManager.applyTransition(closeButton, fullScreenTransitionOut);
			TweenManager.applyTransition(contentToken, fullScreenTransitionOut);
			TweenManager.applyTransition(title, fullScreenTransitionOut).onComplete(removeElements);

		}
		else{
			removeElements();
		}
	}

	private function removeElements():Void
	{
		parent.removeChild(background);
		parent.removeChild(largeImage);
		parent.removeChild(closeButton);
		parent.removeChild(contentToken);
		parent.removeChild(title);
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
		if(tipTransitionIn != null)
			TweenManager.applyTransition(tooltip, tipTransitionIn);
		addChild(tooltip);
	}

	private function onOutToken(e:MouseEvent):Void
	{
		var slot = cast(e.target, Sprite);

		if(tipTransitionOut != null)
			TweenManager.applyTransition(tooltip, tipTransitionOut).onComplete(function()
			{
				if(contains(tooltip))
					removeChild(tooltip);
				tooltip.x = tooltipOrigin.x;
				tooltip.y = tooltipOrigin.y;
				slot.addEventListener(MouseEvent.ROLL_OVER, onOverToken);
			});
	}
}
