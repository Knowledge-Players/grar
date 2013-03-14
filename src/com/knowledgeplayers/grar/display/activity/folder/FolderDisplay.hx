package com.knowledgeplayers.grar.display.activity.folder;

import Std;
import Std;
import nme.display.BitmapData;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import nme.display.BitmapData;
import aze.display.TileSprite;
import aze.display.TileLayer;
import nme.Lib;
import com.eclecticdesignstudio.motion.Actuate;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.structure.activity.folder.Folder;
import com.knowledgeplayers.grar.util.Grid;
import com.knowledgeplayers.grar.util.LoadData;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.SimpleButton;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Point;

/**
* Display of the folder activity
**/
class FolderDisplay extends ActivityDisplay {

    /**
    * Instance
    **/
    public static var instance (getInstance, null):FolderDisplay;

    /**
    * DisplayObject where to drag the elements
    **/
    public var targets (default, default):Array<{obj:DisplayObject, name:String, elem:FolderElementDisplay}>;

    /**
    * PopUp where additional text will be displayed
    **/
    public var popUp (default, default):{sprite: Sprite, titlePos: Point, contentPos: Point};

    /**
    * Grid to organize drag & drop display
    **/
    public var grids (default, null):Hash<Grid>;

    /**
    * Tell whether or not the targets use spritesheets
    **/
    public var targetSpritesheet (default, default):Bool = false;

    private var elementTemplate:{background:BitmapData, buttonIcon:BitmapData, buttonPos:Point};

    private var elementsArray:Array<FolderElementDisplay>;

    private var background:Bitmap;

    /**
    * @return the instance
    **/

    private function new()
    {
        super();
        grids = new Hash<Grid>();
        targets = new Array<{obj:DisplayObject, name:String, elem:FolderElementDisplay}>();
        elementsArray = new Array<FolderElementDisplay>();
    }

    public static function getInstance():FolderDisplay
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
            addChildAt(displays.get(target).obj, displays.get(target).z);
        }
        // Instructions
        var localizedText = Localiser.instance.getItemContent(folder.instructionContent);
        cast(displays.get(folder.ref).obj, ScrollPanel).setContent(KpTextDownParser.parse(localizedText));
        addChild(displays.get(folder.ref).obj);

        // Button
        if(folder.buttonRef.content != null)
            cast(displays.get(folder.buttonRef.ref).obj, TextButton).setText(Localiser.instance.getItemContent(folder.buttonRef.content));
        displays.get(folder.buttonRef.ref).obj.addEventListener(MouseEvent.CLICK, onValidate);
        addChild(displays.get(folder.buttonRef.ref).obj);
    }

    override private function onModelComplete(e:LocaleEvent):Void
    {
        //addChild(grids.get("drag").container);

        for(elem in cast(model, Folder).elements){
            var elementDisplay:FolderElementDisplay;
            //if(elementTemplate.buttonIcon != null)
                elementDisplay = new FolderElementDisplay(elem, grids.get("drag").cellSize.width, grids.get("drag").cellSize.height, elementTemplate.background, elementTemplate.buttonIcon, elementTemplate.buttonPos);
            //else
                //elementDisplay = new FolderElementDisplay(elem, grids.get("drag").cellSize.width, grids.get("drag").cellSize.height, elementTemplate.background);
            elementsArray.push(elementDisplay);
            grids.get("drag").add(elementDisplay, false);
            addChild(elementDisplay);
        }

        super.onModelComplete(e);
    }

    override private function createElement(elemNode:Fast):Void
    {
        super.createElement(elemNode);
        switch(elemNode.name.toLowerCase()){
            case "target" :
                var target:DisplayObject;
                if(elemNode.has.src)
                    target = cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.src), Bitmap);
                else{
                    var layer = new TileLayer(spritesheets.get(elemNode.att.spritesheet));
                    layer.addChild(new TileSprite(elemNode.att.id));
                    target = layer.view;
                    cast(target, Sprite).mouseChildren = false;
                    layer.render();
                    targetSpritesheet = true;
                }
                addElement(target, elemNode);
                targets.push({obj: target, name: elemNode.att.ref, elem: null});

            case "popup" :
                var popUpSprite = new Sprite();
                var titlePos = new Point(0,0);
                var contentPos = titlePos;
                if(elemNode.has.src)
                    popUpSprite.addChild(cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.src), Bitmap));
                else{
                    var layer = new TileLayer(spritesheets.get(elemNode.att.spritesheet));
                    layer.addChild(new TileSprite(elemNode.att.id));
                    popUpSprite.addChild(layer.view);
                    layer.render();
                }
                if(elemNode.has.buttonIcon){
                    var buttonIcon: BitmapData;
                    if(elemNode.att.buttonIcon.indexOf(".") < 0){
                        buttonIcon = DisplayUtils.getBitmapDataFromLayer(new TileLayer(spritesheets.get(elemNode.att.spritesheet)), elemNode.att.buttonIcon);
                    }
                    else
                        buttonIcon = cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.buttonIcon), Bitmap).bitmapData;
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
                var layer = null;
                if(elemNode.has.src)
                    background = cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.src), Bitmap).bitmapData;
                else{
                    layer = new TileLayer(spritesheets.get(elemNode.att.spritesheet));
                    background = DisplayUtils.getBitmapDataFromLayer(layer, elemNode.att.id);
                }
                if(elemNode.has.buttonIcon){
                    if(elemNode.att.buttonIcon.indexOf(".") < 0){
                        buttonIcon = DisplayUtils.getBitmapDataFromLayer(layer, elemNode.att.buttonIcon);
                    }
                    else
                        buttonIcon = cast(LoadData.instance.getElementDisplayInCache(elemNode.att.buttonIcon), Bitmap).bitmapData;
                    buttonPos = new Point(Std.parseFloat(elemNode.att.buttonX), Std.parseFloat(elemNode.att.buttonY));
                }
                elementTemplate = {background: background, buttonIcon: buttonIcon, buttonPos: buttonPos};

            case "grid" :
                var cellWidth = elemNode.has.cellWidth ? Std.parseFloat(elemNode.att.cellWidth) : 0;
                var cellHeight = elemNode.has.cellHeight ? Std.parseFloat(elemNode.att.cellHeight) : 0;
                var grid = new Grid(Std.parseInt(elemNode.att.numRow), Std.parseInt(elemNode.att.numCol), cellWidth, cellHeight, Std.parseFloat(elemNode.att.gapCol), Std.parseFloat(elemNode.att.gapRow), Std.string(elemNode.att.alignX), Std.string(elemNode.att.alignY));
                grid.x = Std.parseFloat(elemNode.att.x);
                grid.y = Std.parseFloat(elemNode.att.y);

                grids.set(elemNode.att.ref, grid);
        }
    }

    override private function unLoad(keepLayer:Int = 0):Void
    {
        super.unLoad(2);
        for(grid in grids){
            grid.empty();
        }
    }

    // Handlers

    private function onValidate(e:MouseEvent):Void
    {
        if(cast(model, Folder).controlMode == "auto")
            Lib.trace("next");
        else
            cast(model, Folder).validate();
        endActivity();
    }

    private function onClosePopUp(ev:MouseEvent):Void
    {
        popUp.sprite.removeChildAt(popUp.sprite.numChildren - 1);
        popUp.sprite.visible = false;
    }
}