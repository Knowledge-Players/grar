package com.knowledgeplayers.grar.display.activity.folder;

import com.knowledgeplayers.grar.display.component.container.PopupDisplay;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import aze.display.TilesheetEx;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import nme.filters.BitmapFilter;
import StringTools;
import motion.Actuate;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.folder.Folder;
import com.knowledgeplayers.grar.structure.activity.folder.FolderElement;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.SimpleButton;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;

/**
* Display of an element in a folder activity
**/
class FolderElementDisplay extends WidgetContainer {

	/**
    * Model
    **/
	public var model (default, null):FolderElement;

	private var shadows:Map<String, BitmapFilter>;
	private var originWidth:Float;
	private var originHeight:Float;
	private var stylesheet:String;
    private var popUp:PopupDisplay;
	/**
    * Constructor
    * @param content : Text of the element
    * @param width : Width of the element
    * @param height : Height of the element
**/

	public function new(?xml: Fast, ?tilesheet: TilesheetEx,?model:FolderElement)
	{
		super(xml,tilesheet);
		this.model = model;
		originWidth = width;
		originHeight = height;

		//this.stylesheet = stylesheet;

		buttonMode = true;



		//shadows = new Map<String, BitmapFilter>();
		// Remove both {} and split on comma
		/*var filtersArray:Array<String> = filters.substr(1, filters.length - 2).split(",");
		var filtersHash:Map<String, String> = new Map<String, String>();
		for(filter in filtersArray){
			filtersHash.set(StringTools.trim(filter.split(":")[0]), StringTools.trim(filter.split(":")[1]));
		}*/
		//shadows.set("down", FilterManager.getFilter(filtersHash.get("down")));
		//shadows.set("up", FilterManager.getFilter(filtersHash.get("up")));


        var text = cast(displays.get(model.ref),ScrollPanel);

		var localizedText = Localiser.instance.getItemContent(model.content + "_front");

		text.setContent(localizedText);

		//this.filters = [shadows.get("down")];

		addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		addEventListener(MouseEvent.MOUSE_UP, onUp);
		addEventListener(Event.ADDED_TO_STAGE, onAdd);

	}

    override private function setButtonAction(button:DefaultButton, action:String):Void {
            if (action =="flip")
            {
            button.buttonAction = onPlusClick;
            }

    }




	public function blockElement():Void
	{
		removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		removeEventListener(MouseEvent.MOUSE_UP, onUp);
		buttonMode = false;
	}

	/*public function reset():Void
	{
		width = originWidth;
		height = originHeight;
		if(!hasEventListener(MouseEvent.MOUSE_DOWN))
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		if(!hasEventListener(MouseEvent.MOUSE_UP))
			addEventListener(MouseEvent.MOUSE_UP, onUp);
		buttonMode = true;
	}*/

	// Handler

	private function onAdd(ev:Event):Void
	{
		//origin = new Point(x, y);
	}

	private function onDown(e:MouseEvent):Void
	{
		//origin.x = x;
		//origin.y = y;
		parent.setChildIndex(this, parent.numChildren - 1);
		//filters = [shadows.get("up")];
		startDrag();
	}

	private function onUp(e:MouseEvent):Void
	{
		var folder = cast(parent, FolderDisplay);
		var i:Int = 1;
		var outOfBound = false;
		var currentTarget = folder.targets[0];
		while(!hitTestObject(currentTarget.obj) && !outOfBound){
			if(i < folder.targets.length)
				currentTarget = folder.targets[i]
			else
				outOfBound = true;
			i++;
		}
		if(outOfBound || (cast(folder.model, Folder).controlMode == "auto" && model.target != currentTarget.name)){
			stopDrag();
			Actuate.tween(this, 0.5, {x: origin.x, y: origin.y});
		}
		else{
			if(folder.grids.exists("drop"))
				folder.grids.get("drop").add(this, false);
			else if(!folder.targetSpritesheet){
				x = currentTarget.obj.x;
				y = currentTarget.obj.y;
				width = currentTarget.obj.width;
				height = currentTarget.obj.height;
			}
			else{
				width = currentTarget.obj.width;
				height = currentTarget.obj.height;
				x = currentTarget.obj.x - width / 2;
				y = currentTarget.obj.y - height / 2;
			}
			stopDrag();
			model.currentTarget = currentTarget.name;
			if(cast(folder.model, Folder).controlMode == "auto")
				blockElement();
			else if(currentTarget.elem != null){
				Actuate.tween(currentTarget.elem, 0.5, {x: origin.x, y: origin.y});
				currentTarget.elem.reset();
				currentTarget.elem.model.currentTarget = "";
			}
			currentTarget.elem = this;
		}
		//filters = [shadows.get("down")];
	}

	private function onPlusClick(?_target:DefaultButton):Void
	{
        if(popUp == null)
        {
            popUp = cast(parent, FolderDisplay).popUp;
            popUp.init(model.content);
            parent.addChild(popUp);
        }
    }

	private function createSprite(text:String, width:Float):Sprite
	{
		var previousStyleSheet = null;
		if(stylesheet != null){
			previousStyleSheet = StyleParser.currentStyleSheet;
			StyleParser.currentStyleSheet = stylesheet;
		}

		var content = new Sprite();
		var offSetY:Float = 0;
		var isFirst:Bool = true;

		for(element in KpTextDownParser.parse(text)){
			var padding = StyleParser.getStyle(element.style).getPadding();
			var item = element.createSprite(width - padding[1] - padding[3]);

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

		return content;
	}
}
