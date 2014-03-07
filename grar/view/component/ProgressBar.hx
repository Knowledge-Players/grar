package grar.view.component;

import aze.display.TileClip;
import aze.display.TileLayer;

import grar.view.component.container.WidgetContainer;

import grar.model.tracking.Trackable;

import grar.util.DisplayUtils;

import haxe.ds.StringMap;

import flash.display.Sprite;

class ProgressBar extends WidgetContainer {

	//public function new(_node : Fast) : Void {
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : aze.display.TilesheetEx, 
							transitions : StringMap<TransitionTemplate>, pbd : WidgetContainerData) : Void {

		//super(_node);
		super(callbacks, applicationTilesheet, transitions, pbd);

		layerProgressBar = new TileLayer(applicationTilesheet);

		addChild(layerProgressBar.view);

		icons = new StringMap();

// Now done in Application
//		GameManager.instance.addEventListener(PartEvent.ENTER_PART, onEnterPart);
// 		allItems = GameManager.instance.game.getAllItems();

// call now done in Application
//		GameManager.instance.addEventListener(GameEvent.GAME_OVER, function(e:GameEvent) { fillBar(maskWidth); });


		switch(pbd.type) {

			case ProgressBar(is, pc, i):

				this.iconScale = is;
				this.progressColor = pc;
				addIcons(i);

			default: // nothing
		}
	}

	private var backgroundColor : Int;
	private var progressColor:Int;
	private var layerProgressBar:TileLayer;
	private var icons:StringMap<TileClip>;
	private var iconScale:Float;
	private var xProgress:Float = 0;
	private var allItems : Array<Trackable>;

	///
	// API
	//

	public function setGameOver() : Void {

		fillBar(maskWidth);
	}


//	private function onEnterPart(e:PartEvent):Void
	public function setEnterPart(part : grar.model.part.Part, allItems : Array<grar.model.tracking.Trackable>, 
									allParts : Array<grar.model.part.Part>) : Void {

		if (icons.exists(part.id)) {

			// Toggle icon to done
			var icon = icons.get(part.id);
			
			if (icon.currentFrame == 0) {

				icon.currentFrame = 1;
			}

			// Update others
			var i = 0;

			while (i < allItems.length) {

				switch (allItems[i]) {

					case Part(p):

						if(p.id == part.id) {

							break;
						}

						icons.get(p.id).currentFrame = 1;

						i++;
				}
			}
			for (j in (i + 1)...allItems.length) {

				switch (allItems[j]) {

					case Part(p):

						icons.get(p.id).currentFrame = 0;
				}
			}

			layerProgressBar.render();

			// Update ProgressBar
			if (icon.x > xProgress) {

				fillBar(icon.x);
			
			} else {

				unfillBar(icon.x);
			}
		
		} else {

			var index = allParts.length;
			var lastActive:String = null;
			var isFirst = true;
			
			for (i in 0...allParts.length) {

				if (allParts[i].id == part.id) {

					index = i;
				
				} else if (icons.exists(allParts[i].id)) {

					if (isFirst || index > i) {

						icons.get(allParts[i].id).currentFrame = 1;
						lastActive = allParts[i].id;
						isFirst = false;
					
					} else {

						icons.get(allParts[i].id).currentFrame = 0;
					}
				}
			}
			if (icons.get(lastActive).x > xProgress) {

				fillBar(icons.get(lastActive).x);
			
			} else {

				unfillBar(icons.get(lastActive).x);
			}
		}
	}


	///
	// INTERNALS
	//

	private function addIcons(prefix:String):Void
	{
		var xPos:Float = maskWidth / (2 * allItems.length);
		var isFirst = true;

		for(item in allItems) {

			switch (item) {

				case Part(p):

					var icon = new TileClip(layerProgressBar, prefix + "_" + p.id);
					icons.set(p.id, icon);
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
		}
		layerProgressBar.render();

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