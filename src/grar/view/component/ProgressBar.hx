package grar.view.component;

import aze.display.TileClip;
import aze.display.TileLayer;

import grar.view.component.container.WidgetContainer;
import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.tracking.Trackable;
import grar.util.DisplayUtils;

import haxe.ds.StringMap;

import flash.display.Sprite;

class ProgressBar extends WidgetContainer {

	//public function new(_node : Fast) : Void {
	public function new(pbd : WidgetContainerData) : Void {

		//super(_node);
		super(pbd);

		layerProgressBar = new TileLayer(UiFactory.tilesheet);

		addChild(layerProgressBar.view);

		icons = new StringMap();

		GameManager.instance.addEventListener(PartEvent.ENTER_PART, onEnterPart);

		GameManager.instance.addEventListener(GameEvent.GAME_OVER, function(e:GameEvent) {
				fillBar(maskWidth);
			});

		allItems = GameManager.instance.game.getAllItems();

		switch(pbd.type) {

			case ProgressBar(is, pc, i):

				this.iconScale = is;
				this.progressColor = pc;
				addIcons(i);

			default: // nothing
		}
	}

	private var backgroundColor:Int;
	private var progressColor:Int;
	private var layerProgressBar:TileLayer;
	private var icons:StringMap<TileClip>;
	private var iconScale:Float;
	private var xProgress:Float = 0;
	private var allItems:Array<Trackable>;

	private function addIcons(prefix:String):Void
	{
		var xPos:Float = maskWidth / (2 * allItems.length);
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
			xPos += maskWidth / allItems.length;
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
		else{
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
		DisplayUtils.initSprite(this, end - xProgress, maskHeight, progressColor, xProgress, 0);
		xProgress = end;
	}

	private function unfillBar(end:Float):Void
	{
		DisplayUtils.initSprite(this, -(maskWidth - end), maskHeight, backgroundColor, maskWidth, 0);
		xProgress = end;
	}

}