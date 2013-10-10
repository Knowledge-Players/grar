package com.knowledgeplayers.grar.display.component;

import aze.display.TileClip;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.tracking.Trackable;
import haxe.xml.Fast;
import flash.display.Sprite;

// TODO extends Widget
class ProgressBar extends Sprite {

	private var backgroundColor:Int;
	private var progressColor:Int;
	private var layerProgressBar:TileLayer;
	private var icons:Map<String, TileClip>;
	private var barWidth:Float = 0;
	private var barHeight:Float = 0;
	private var iconScale:Float;
	private var xProgress:Float = 0;
	private var allItems:Array<Trackable>;

	public function new():Void
	{
		super();

		layerProgressBar = new TileLayer(UiFactory.tilesheet);
		addChild(layerProgressBar.view);
		icons = new Map<String, TileClip>();
		GameManager.instance.addEventListener(PartEvent.ENTER_PART, onEnterPart);
		GameManager.instance.addEventListener(GameEvent.GAME_OVER, function(e:GameEvent)
		{
			fillBar(barWidth);
		});
		allItems = GameManager.instance.game.getAllItems();
	}

	public function init(_node:Fast):Void
	{

		this.x = Std.parseFloat(_node.att.x);
		this.y = Std.parseFloat(_node.att.y);
		barWidth = Std.parseFloat(_node.att.width);
		barHeight = Std.parseFloat(_node.att.height);
		backgroundColor = Std.parseInt(_node.att.background);
		graphics.beginFill(backgroundColor);
		graphics.drawRect(0, 0, barWidth, barHeight);
		graphics.endFill();

		iconScale = _node.has.iconScale ? Std.parseFloat(_node.att.iconScale) : 1;
		progressColor = Std.parseInt(_node.att.progressColor);

		addIcons(_node.att.icon);
	}

	private function addIcons(prefix:String):Void
	{
		var xPos:Float = barWidth / (2 * allItems.length);
		var isFirst = true;
		for(item in allItems){
			var icon = new TileClip(layerProgressBar, prefix + "_" + item.id);
			icons.set(item.id, icon);
			icon.x = xPos;
			icon.y = -8;
			icon.scale = iconScale;
			icon.stop();
			layerProgressBar.addChild(icon);
			if(isFirst){
				fillBar(xPos);
				icon.currentFrame++;
				isFirst = false;
			}
			xPos += barWidth / allItems.length;
		}

		layerProgressBar.render();

	}

	private function onEnterPart(e:PartEvent):Void
	{
		if(icons.exists(e.partId)){
			// Toggle icon to done
			var icon = icons.get(e.partId);
			if(icon.currentFrame == 0)
				icon.currentFrame = 1;

			// Update others
			var i = 0;
			while(i < allItems.length && allItems[i].id != e.partId){
				icons.get(allItems[i].id).currentFrame = 1;
				i++;
			}

			for(j in (i + 1)...allItems.length)
				icons.get(allItems[j].id).currentFrame = 0;

			layerProgressBar.render();

			// Update ProgressBar
			if(icon.x > xProgress)
				fillBar(icon.x);
			else
				unfillBar(icon.x);
		}
		else{//} if(e.partId != GameManager.instance.game.getAllParts()[0].id){
			var allPart = GameManager.instance.game.getAllParts();
			var index = allPart.length;
			var lastActive:String = null;
			var isFirst = true;
			for(i in 0...allPart.length){
				if(allPart[i].id == e.partId)
					index = i;
				else if(icons.exists(allPart[i].id)){
					if(isFirst || index > i){
						icons.get(allPart[i].id).currentFrame = 1;
						lastActive = allPart[i].id;
						isFirst = false;
					}
					else
						icons.get(allPart[i].id).currentFrame = 0;
				}
			}
			if(icons.get(lastActive).x > xProgress)
				fillBar(icons.get(lastActive).x);
			else
				unfillBar(icons.get(lastActive).x);
		}

	}

	private function fillBar(end:Float):Void
	{
		graphics.beginFill(progressColor);
		graphics.drawRect(xProgress, 0, end - xProgress, barHeight);
		graphics.endFill();
		xProgress = end;
	}

	private function unfillBar(end:Float):Void
	{
		graphics.beginFill(backgroundColor);
		graphics.drawRect(barWidth, 0, -(barWidth - end), barHeight);
		graphics.endFill();
		xProgress = end;
	}

}