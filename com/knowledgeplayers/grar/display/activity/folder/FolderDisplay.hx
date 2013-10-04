package com.knowledgeplayers.grar.display.activity.folder;

import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.PopupDisplay;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.structure.activity.Activity;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.event.ButtonActionEvent;

import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.structure.activity.folder.Folder;
import com.knowledgeplayers.grar.util.Grid;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

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
	public var popUpContainer:Sprite;

	/**
    * Grid to organize drag & drop display
    **/
	public var grids (default, null):Map<String, Grid>;

	/**
    * Tell whether or not the targets use spritesheets
    **/
	public var targetSpritesheet (default, default):Bool = false;

    public var popUp:PopupDisplay;

	private var elementTemplate:Fast;

	private var elementsArray:Array<FolderElementDisplay>;

	private var background:Bitmap;

    private var btNext:DefaultButton;


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
			addChildAt(displays.get(target), cast(Math.min(displays.get(target).zz, numChildren), Int));
		}
	}

	override public function set_model(model:Activity):Activity
	{

        var model = super.set_model(model);
        for(elem in cast(model, Folder).elements){

			var elementDisplay:FolderElementDisplay = new FolderElementDisplay(elementTemplate,elem);
			elementsArray.push(elementDisplay);
			grids.get("drag").add(elementDisplay, false);
			addChild(elementDisplay);

		}

       displays.get("next").visible = false;

		return model;
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

                var pop = new PopupDisplay(elemNode);

				popUp = pop;


			case "element" :

				elementTemplate = elemNode;


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

	override private function onValidate(?_target:DefaultButton):Void
	{
		if(cast(model, Folder).controlMode != "auto")
			cast(model, Folder).validate();
		//endActivity();
	}

    override private function setButtonAction(button:DefaultButton, action:String):Void
    {
        if(action.toLowerCase() == ButtonActionEvent.NEXT){
            btNext = button;
            btNext.buttonAction = endActivity;
        }
    }

    public function elementOnTarget():Void{
        cast(model, Folder).validate();
       // trace('model.score : '+model.score);
        if ( model.score==100){
            displays.get("next").visible = true;

        }
    }


	/*private function onClosePopUp(ev:MouseEvent):Void
	{
		popUp.sprite.removeChildAt(popUp.sprite.numChildren - 1);
		popUp.sprite.visible = false;
	}*/
}