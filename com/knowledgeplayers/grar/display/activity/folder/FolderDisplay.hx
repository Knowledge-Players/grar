package com.knowledgeplayers.grar.display.activity.folder;

import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.structure.activity.Activity;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.event.ButtonActionEvent;

import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.structure.activity.folder.Folder;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.util.Grid;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.display.SimpleButton;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.Lib;

/**
* Display of the folder activity
**/
class FolderDisplay extends ActivityDisplay {

	/**
    * Instance
    **/
	public static var instance (get_instance, null):FolderDisplay;

	/**
    * DisplayObject where to drag the elements
    **/
	public var targets (default, default):Array<{obj:DisplayObject, name:String, elem:FolderElementDisplay}>;

	/**
    * PopUp where additional text will be displayed
    **/
	public var popUp (default, default):{sprite:Sprite, titlePos:Point, contentPos:Point};

	/**
    * Grid to organize drag & drop display
    **/
	public var grids (default, null):Map<String, Grid>;

	/**
    * Tell whether or not the targets use spritesheets
    **/
	public var targetSpritesheet (default, default):Bool = false;

	private var elementTemplate:{background:BitmapData, width:Float, height:Float, filters:String, buttonIcon:BitmapData, buttonPos:Point};

	private var elementsArray:Array<FolderElementDisplay>;

	private var background:Bitmap;

	/**
    * @return the instance
    **/

	private function new()
	{
		super();
		grids = new Map<String, Grid>();
		targets = new Array<{obj:DisplayObject, name:String, elem:FolderElementDisplay}>();
		elementsArray = new Array<FolderElementDisplay>();
	}

	public static function get_instance():FolderDisplay
	{
		if(instance == null)
			instance = new FolderDisplay();
		return instance;
	}

	// Private

	override private function displayActivity():Void
	{
		super.displayActivity();
		var folder = cast(model, Folder);
		// Targets
		for(target in folder.targets){
			addChildAt(displays.get(target), cast(Math.min(displays.get(target).z, numChildren), Int));
		}
	}

	override public function set_model(model:Activity):Activity
	{
		for(elem in cast(model, Folder).elements){
			var elementDisplay:FolderElementDisplay;
			elementDisplay = new FolderElementDisplay(elem, elementTemplate.width, elementTemplate.height, elementTemplate.filters, elementTemplate.background, elementTemplate.buttonIcon, elementTemplate.buttonPos);
			elementsArray.push(elementDisplay);
			grids.get("drag").add(elementDisplay, false);
			addChild(elementDisplay);
		}
		return super.set_model(model);
	}

	override private function createElement(elemNode:Fast):Void
	{
		super.createElement(elemNode);
		switch(elemNode.name.toLowerCase()){
			case "target" :
				var target:Widget = new Image(elemNode);
				if(!elemNode.has.src){
					var layer:TileLayer = null;
					if(elemNode.has.spritesheet)
						layer = new TileLayer(spritesheets.get(elemNode.att.spritesheet));
					else
						layer = new TileLayer(UiFactory.tilesheet);
					UiFactory.addImageToLayer(elemNode, layer, true);
					target = new Image();
					target.addChild(layer.view);
					cast(target, Sprite).mouseChildren = false;
					targetSpritesheet = true;
				}
				addElement(target, elemNode);
				targets.push({obj: target, name: elemNode.att.ref, elem: null});

			case "popup" :
				var popUpSprite = new Image(elemNode);
				var titlePos = new Point(0, 0);
				var contentPos = titlePos;
				if(!elemNode.has.src){
					var layer:TileLayer = null;
					if(elemNode.has.spritesheet)
						layer = new TileLayer(spritesheets.get(elemNode.att.spritesheet));
					else
						layer = new TileLayer(UiFactory.tilesheet);
					UiFactory.addImageToLayer(elemNode, layer);
					popUpSprite.addChild(layer.view);
				}
				if(elemNode.has.buttonIcon){
					var buttonIcon:BitmapData;
					if(elemNode.att.buttonIcon.indexOf(".") < 0){
						if(elemNode.has.spritesheet)
							buttonIcon = DisplayUtils.getBitmapDataFromLayer(spritesheets.get(elemNode.att.spritesheet), elemNode.att.buttonIcon);
						else
							buttonIcon = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, elemNode.att.buttonIcon);
					}
					else
						buttonIcon = AssetsStorage.getBitmapData(elemNode.att.buttonIcon);
					var icon = new Bitmap(buttonIcon);
					var button = new SimpleButton(icon, icon, icon, icon);
					button.x = Std.parseFloat(elemNode.att.buttonX);
					button.y = Std.parseFloat(elemNode.att.buttonY);
					button.addEventListener(MouseEvent.CLICK, onClosePopUp);
					popUpSprite.addChild(button);
				}
				if(elemNode.has.titlePos){
					var pos = elemNode.att.titlePos.split(";");
					titlePos = new Point(Std.parseFloat(pos[0]), Std.parseFloat(pos[1]));
				}
				if(elemNode.has.contentPos){
					var pos = elemNode.att.contentPos.split(";");
					contentPos = new Point(Std.parseFloat(pos[0]), Std.parseFloat(pos[1]));
				}
				popUpSprite.visible = false;
				popUpSprite.alpha = 0;
				addElement(popUpSprite, elemNode);
				addChild(popUpSprite);
				popUp = {sprite: popUpSprite, titlePos: titlePos, contentPos: contentPos};

			case "element" :
				var background:BitmapData;
				var buttonIcon = null;
				var buttonPos = null;
				if(elemNode.has.src)
					background = AssetsStorage.getBitmapData(elemNode.att.src);
				else if(elemNode.has.spritesheet){
					background = DisplayUtils.getBitmapDataFromLayer(spritesheets.get(elemNode.att.spritesheet), elemNode.att.id);
				}
				else
					background = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, elemNode.att.id);
				if(elemNode.has.buttonIcon){
					if(elemNode.att.buttonIcon.indexOf(".") < 0){
						if(elemNode.has.spritesheet)
							buttonIcon = DisplayUtils.getBitmapDataFromLayer(spritesheets.get(elemNode.att.spritesheet), elemNode.att.buttonIcon);
						else
							buttonIcon = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, elemNode.att.buttonIcon);
					}
					else
						buttonIcon = AssetsStorage.getBitmapData(elemNode.att.buttonIcon);
					buttonPos = new Point(Std.parseFloat(elemNode.att.buttonX), Std.parseFloat(elemNode.att.buttonY));
				}
				elementTemplate = {background: background, width: Std.parseFloat(elemNode.att.width), height: Std.parseFloat(elemNode.att.height), filters: elemNode.att.filters, buttonIcon: buttonIcon, buttonPos: buttonPos};

			case "grid" :
				var cellWidth = elemNode.has.cellWidth ? Std.parseFloat(elemNode.att.cellWidth) : 0;
				var cellHeight = elemNode.has.cellHeight ? Std.parseFloat(elemNode.att.cellHeight) : 0;
				var align = elemNode.has.align ? Type.createEnum(GridAlignment, elemNode.att.align.toUpperCase()) : null;
				var gapCol = elemNode.has.gapCol ? Std.parseFloat(elemNode.att.gapCol) : 0;
				var gapRow = elemNode.has.gapRow ? Std.parseFloat(elemNode.att.gapRow) : 0;
				var grid = new Grid(Std.parseInt(elemNode.att.numRow), Std.parseInt(elemNode.att.numCol), cellWidth, cellHeight, gapCol, gapRow, align);
				grid.x = Std.parseFloat(elemNode.att.x);
				grid.y = Std.parseFloat(elemNode.att.y);

				grids.set(elemNode.att.ref, grid);
		}
	}

	override private function unLoad(keepLayer:Int = 0):Void
	{
		super.unLoad();
		for(grid in grids){
			grid.empty();
		}

	}

	// Handlers

	override private function onValidate(e:ButtonActionEvent):Void
	{
		if(cast(model, Folder).controlMode != "auto")
			cast(model, Folder).validate();
		endActivity();
	}

	private function onClosePopUp(ev:MouseEvent):Void
	{
		popUp.sprite.removeChildAt(popUp.sprite.numChildren - 1);
		popUp.sprite.visible = false;
	}
}