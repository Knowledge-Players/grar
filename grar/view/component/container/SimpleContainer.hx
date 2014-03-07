package grar.view.component.container;

import aze.display.TilesheetEx;

import grar.view.part.PartDisplay;
import grar.view.component.container.WidgetContainer;
import grar.view.component.container.ScrollPanel;

import grar.util.DisplayUtils;

import grar.util.TweenUtils;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.events.Event;

using StringTools;

import haxe.ds.StringMap;

class SimpleContainer extends WidgetContainer {

	//public function new( ? xml : Fast, ? tilesheet : TilesheetEx ) {
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : TilesheetEx, 
							transitions : StringMap<TransitionTemplate>,  
							? scd : Null<WidgetContainerData>, ? tilesheet : TilesheetEx) {

        this.scd = scd;

		this.totalChildren = this.loadedChildren = 0;

		super(callbacks, applicationTilesheet, transitions, scd, tilesheet);
		
		if (scd != null && scd.spritesheetRef != null) {

			this.tilesheetName = scd.spritesheetRef;
		}

		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

    private var scd : WidgetContainerData;

	private var contentMask : Bitmap;
    private var bmpData : BitmapData;
    private var contentData : BitmapData;
	private var tilesheetName : String;
	private var totalChildren : Int;
	private var loadedChildren : Int;


	///
	// CALLBACKS
	//

	public dynamic function onContainerLoaded() : Void { }


	///
	// API
	//

	override public function maskSprite(sprite: Sprite, maskWidth: Float = 1, maskHeight: Float = 1, maskX: Float = 0, maskY: Float = 0):Void
	{

		if(contentMask != null){
			sprite.addChild(contentMask);
			sprite.mask = contentMask;
		}
		else
			super.maskSprite(sprite, maskWidth, maskHeight, maskX, maskY);
	}

	override public function clear()
	{
	}

	public function setText(pContent:String, ?pKey:String):Void
	{
		if(pKey != null && pKey != " "){
			if(displaysRefs.exists(pKey)){
					cast(displaysRefs.get(pKey), grar.view.component.container.ScrollPanel).setContent(pContent);
			}
		}
		else{
			for(elem in displays){
				if(Std.is(elem, grar.view.component.container.ScrollPanel)){
					cast(elem, grar.view.component.container.ScrollPanel).setContent(pContent);
					break;
				}
			}
		}
	}

	public function onAdded(e: Event): Void // Couldn't this be done in parent object ?
	{
		if (tilesheetName != null) {

			var ancestor = parent;
			
			while (!Std.is(ancestor, PartDisplay) && ancestor != null) {

				ancestor = ancestor.parent;
			}
			if (ancestor == null) {

				throw "[TileImage] Unable to find spritesheet '"+tilesheetName+"' for image '"+ref+"'.";
			}
			tilesheet = cast(ancestor, PartDisplay).spritesheets.get(tilesheetName);
			layer.tilesheet = tilesheet;
			layer.removeAllChildren();

			for (ce in scd.displays) {

				createElement(ce);
			}

			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
//		dispatchEvent(new DisplayEvent(DisplayEvent.LOADED));
		onContainerLoaded();
	}

	public function setMask() : Void {

		loadedChildren++;

		var mask : Null<String> = switch(scd.type){ case SimpleContainer(m): m; default: null; };

        if (loadedChildren == totalChildren && mask != null) {

            bmpData= DisplayUtils.getBitmapDataFromLayer(this.tilesheet, mask);

            contentMask = new Bitmap(bmpData) ;

            if (scd.wd.scale != null) {

                contentMask.scaleX = scd.wd.scale;
                contentMask.scaleY = scd.wd.scale;
            }

            contentData = new BitmapData(bmpData.width, bmpData.height, true, 0x0);

            contentMask.cacheAsBitmap = true;

	        contentData.draw(content);
	        var bmp = new Bitmap(contentData);
	        
	        if (scd.wd.scale != null) {

		        bmp.scaleX = scd.wd.scale;
		        bmp.scaleY = scd.wd.scale;
	        };
	        bmp.cacheAsBitmap = true;
	        bmp.mask = contentMask;
            bmp.smoothing = true;
	        var sprite = new Sprite();

	        sprite.addChild(contentMask);
	        sprite.addChild(bmp);

	        var text = null;

	        while (content.numChildren > 0) {

		        var child = content.removeChildAt(content.numChildren-1);
		        
		        if (Std.is(child, grar.view.component.container.ScrollPanel)) {

					text = child;
		        }
	        }
	        content.addChild(sprite);
	        
	        if (text != null) {

	            content.addChild(text);
	        }
        }
	}


	///
	// INTERNALS
	//

	override private function createSimpleContainer(d : WidgetContainerData) : Widget {

		var div = new SimpleContainer(callbacks, applicationTilesheet, transitions, d);
		totalChildren++;

// 		div.addEventListener(DisplayEvent.LOADED, setMask);
		div.onContainerLoaded = function() { setMask(); }

		addElement(div);
		return div;
	}

	override private function createText(d : WidgetContainerData) : ScrollPanel {

		var panel : ScrollPanel = super.createText(d);

		switch(d.type) {

			case ScrollPanel(styleSheet, style, content, trim):

				if (content != null && content.startsWith("$")) {

					addEventListener(Event.ADDED_TO_STAGE, function(e){

							var display : DisplayObject = parent;
							
							while (display != null && !Std.is(display, grar.view.Display)) {

								display = display.parent;
							}
							if (display != null) {

								var kpParent : grar.view.Display = cast display;
								kpParent.dynamicFields.push({ field: panel, content: content.substr(1) });
							}
							// Warn its parent about its change
							dispatchEvent(new Event(Event.CHANGE));

						}, 1000);
				}

			default: // nothing
		}
		return panel;
	}

	override private function setButtonAction(button : DefaultButton, action : String) : Void {

		if (action == "close") {

			button.buttonAction = function(? target : DefaultButton) {

					if (transitionOut != null) {

// 						TweenManager.applyTransition(this, transitionOut).onComplete(function(){
						TweenUtils.applyTransition(this, transitions, transitionOut).onComplete(function(){

								parent.removeChild(this);

							});

					} else {

						parent.removeChild(this);
					}
				}
		}
	}
}
