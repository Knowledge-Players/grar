package com.knowledgeplayers.grar.display.activity.cards;

import com.knowledgeplayers.grar.structure.activity.Activity;
import aze.display.TileClip;
import aze.display.TileLayer;
import motion.Actuate;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.StyleParser;

import com.knowledgeplayers.grar.structure.activity.cards.Cards;
import com.knowledgeplayers.grar.util.Grid;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;

/**
* Display of the model activity
**/
class CardsDisplay extends ActivityDisplay {

	/**
    * Instance
    **/
	public static var instance (get_instance, null):CardsDisplay;

	/**
    * PopUp where additional text will be displayed
    **/
	public var popUp (default, default):Sprite;

	/**
    * Grid to dispatch cards
    **/
	public var grids (default, null):Map<String, Grid>;

	private var flipLayer:TileLayer;
	private var flipClip:TileClip;
	private var flipDirection:Int;
	private var cardInProgress:CardsElementDisplay;
	private var nextCard:CardsElementDisplay;
	private var nextText:String;
	private var elementsContainer:Sprite;
	private var background:Bitmap;

	private var content:Fast;
	private var stylesheet:String;

	private var elementBackground:String;
	private var elementsArray:Array<CardsElementDisplay>;

	/**
    * @return the instance
    **/

	public static function get_instance():CardsDisplay
	{
		if(instance == null)
			instance = new CardsDisplay();
		return instance;
	}

	/**
    *
    **/

	public function clickCard(pCard:CardsElementDisplay, pText:String)
	{
		nextCard = pCard;
		nextText = pText;
		if(popUp.visible){
			closePopUp();
		}
		else{
			launchCard();
		}
	}

	// Private

	override private function displayActivity():Void
	{
		super.displayActivity();
	}

	override public function set_model(model:Activity):Activity
	{
		for(i in 0...cast(model, Cards).elements.length){
			var elementDisplay = new CardsElementDisplay(cast(model, Cards).elements[i].content, grids.get("dispatch").cellSize.width, grids.get("dispatch").cellSize.height, elementBackground);
			elementsArray.push(elementDisplay);
			grids.get("dispatch").add(elementDisplay, false);
			addChild(elementDisplay);
		}

		// TODO Container
		//grids.get("dispatch").alignContainer(grids.get("dispatch").container, background);
		return super.set_model(model);
	}

	override private function createElement(elemNode:Fast):Void
	{
		super.createElement(elemNode);
		switch(elemNode.name.toLowerCase()){
			case "target" :
				var target = {obj: new Bitmap(AssetsStorage.getBitmapData(elemNode.att.src)), ref: elemNode.att.ref};
				addElement(target.obj, elemNode);
			case "popup" :
				var pop:Bitmap = new Bitmap(AssetsStorage.getBitmapData(elemNode.att.background));
				popUp.addChild(pop);
				var icon:Bitmap = new Bitmap(AssetsStorage.getBitmapData(elemNode.att.buttonIcon));
				popUp.addChild(icon);
				popUp.addEventListener(MouseEvent.CLICK, onClosePopUp);
				popUp.visible = false;
				popUp.alpha = 0;
				addChild(popUp);
				if(elemNode.has.style)
					stylesheet = elemNode.att.style;
			case "animationelement" :
				var tilesheet = spritesheets.get(elemNode.att.spritesheet);
				flipLayer = new TileLayer(tilesheet);
				flipClip = new TileClip(flipLayer, elemNode.att.id);
				flipClip.loop = false;
				flipLayer.addChild(flipClip);
				addChild(flipLayer.view);
			case "grid" :
				var grid = new Grid(Std.parseInt(elemNode.att.numRow), Std.parseInt(elemNode.att.numCol), Std.parseFloat(elemNode.att.cellWidth), Std.parseFloat(elemNode.att.cellHeight), Std.parseFloat(elemNode.att.gapCol), Std.parseFloat(elemNode.att.gapRow));
				grid.x = Std.parseFloat(elemNode.att.x);
				grid.y = Std.parseFloat(elemNode.att.y);
				grids.set(elemNode.att.ref, grid);
			case "element" : elementBackground = elemNode.att.src;
		}
	}

	private function onClosePopUp(ev:MouseEvent):Void
	{
		nextCard = null;
		nextText = null;
		closePopUp();
	}

	private function closePopUp()
	{
		popUp.removeChildAt(popUp.numChildren - 1);
		popUp.visible = false;
		flipLayer.view.visible = true;
		flipLayer.view.x = popUp.x + popUp.width / 2;
		flipLayer.view.y = popUp.y + popUp.height / 2;
		setChildIndex(flipLayer.view, numChildren - 1);
		flipDirection = -1;
		addEventListener(Event.ENTER_FRAME, onEnterFrameClip);
		Actuate.tween(flipLayer.view, 0.8, {x: cardInProgress.x + cardInProgress.width / 2, y: cardInProgress.y + cardInProgress.height / 2}).onComplete(launchCard);
	}

	private function launchCard()
	{
		flipLayer.view.visible = false;
		for(i in 0...elementsArray.length){

			elementsArray[i].visible = true;

		}
		if(nextCard != null){
			nextCard.visible = false;
			cardInProgress = nextCard;
			flipLayer.view.x = cardInProgress.x + cardInProgress.width / 2;
			flipLayer.view.y = cardInProgress.y + cardInProgress.height / 2;
			setChildIndex(flipLayer.view, numChildren - 1);
			flipLayer.view.visible = true;
			flipDirection = 1;
			addEventListener(Event.ENTER_FRAME, onEnterFrameClip);
			Actuate.tween(flipLayer.view, 0.8, {x: popUp.x + popUp.width / 2, y:popUp.y + popUp.height / 2}).onComplete(showPopUp, [nextText]);
		}

	}

	private function showPopUp(pText:String)
	{
		var previousStyleSheet = null;
		if(stylesheet != null){
			previousStyleSheet = StyleParser.currentStyleSheet;
			StyleParser.currentStyleSheet = stylesheet;
		}

		var content = new Sprite();
		var offSetY:Float = 0;

		var isFirst:Bool = true;

		for(element in KpTextDownParser.parse(pText)){
			var padding = StyleParser.getStyle(element.style).getPadding();
			var item = element.createSprite(popUp.width - padding[1] - padding[3]);

			if(isFirst){
				offSetY += padding[0];
			}
			item.x = padding[3];
			item.y = offSetY;
			offSetY += item.height;
			content.addChild(item);

		}

		if(previousStyleSheet != null)
			StyleParser.currentStyleSheet = previousStyleSheet;

		popUp.addChild(content);
		setChildIndex(popUp, numChildren - 1);
		popUp.visible = true;
		Actuate.tween(popUp, 0.5, {alpha: 1});
		flipLayer.view.visible = false;
	}

	private function onEnterFrameClip(e:Event)
	{
		flipClip.currentFrame += 1 * flipDirection;
		flipLayer.render();
		if(flipClip.currentFrame == flipClip.totalFrames || flipClip.currentFrame == 0){
			removeEventListener(Event.ENTER_FRAME, onEnterFrameClip);
		}
	}

	override private function unLoad(keepLayer:Int = 0):Void
	{
		super.unLoad(2);
		for(grid in grids){
			grid.empty();
		}
	}

	private function new()
	{
		super();
		grids = new Map<String, Grid>();
		popUp = new Sprite();
		elementsArray = new Array<CardsElementDisplay>();
	}
}