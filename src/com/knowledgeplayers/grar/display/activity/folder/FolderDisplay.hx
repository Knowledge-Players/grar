package com.knowledgeplayers.grar.display.activity.folder;

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
    public var targets (default, default):Array<{obj:DisplayObject, name:String}>;

    /**
    * PopUp where additional text will be displayed
    **/
    public var popUp (default, default):Sprite;

    /**
    * Grid to organize drag & drop display
    **/
    public var grids (default, null):Hash<Grid>;

    /**
    * Tell whether or not the targets use spritesheets
    **/
    public var targetSpritesheet (default, default):Bool = false;

    private var elementTemplate:{background:BitmapData, buttonIcon:String, buttonPos:Point};

    private var elementsArray:Array<FolderElementDisplay>;

    private var background:Bitmap;

    /**
    * @return the instance
    **/

    private function new()
    {
        super();
        grids = new Hash<Grid>();
        popUp = new Sprite();
        targets = new Array<{obj:DisplayObject, name:String}>();
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
        addChild(grids.get("drag").container);

        for(elem in cast(model, Folder).elements){
            var elementDisplay:FolderElementDisplay;
            if(elementTemplate.buttonIcon != null)
                elementDisplay = new FolderElementDisplay(elem.content, grids.get("drag").cellSize.width, grids.get("drag").cellSize.height, elementTemplate.background, elementTemplate.buttonIcon, elementTemplate.buttonPos);
            else
                elementDisplay = new FolderElementDisplay(elem.content, grids.get("drag").cellSize.width, grids.get("drag").cellSize.height, elementTemplate.background);
            elementDisplay.target = elem.target;
            elementsArray.push(elementDisplay);
            grids.get("drag").add(elementDisplay, false);
            addChild(elementDisplay);
            //grids.get("drag").addChild(elementDisplay);

        }

        //grids.get("drag").alignContainer(grids.get("drag").container, background);

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
                targets.push({obj: target, name: elemNode.att.ref});

            case "popup" :
                if(elemNode.has.src)
                    popUp.addChild(cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.src), Bitmap));
                else{
                    var layer = new TileLayer(spritesheets.get(elemNode.att.spritesheet));
                    layer.addChild(new TileSprite(elemNode.att.id));
                    popUp.addChild(layer.view);
                    layer.render();
                }
                if(elemNode.has.buttonIcon){
                    var icon = cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.buttonIcon), Bitmap);
                    var button = new SimpleButton(icon, icon, icon, icon);
                    button.x = Std.parseFloat(elemNode.att.buttonX);
                    button.y = Std.parseFloat(elemNode.att.buttonY);
                    button.addEventListener(MouseEvent.CLICK, onClosePopUp);
                    popUp.addChild(button);
                }

                popUp.visible = false;
                popUp.alpha = 0;
                addElement(popUp, elemNode);

            case "element" :
                var background:BitmapData;
                var buttonIcon = null;
                var buttonPos = null;
                if(elemNode.has.src)
                    background = cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.buttonIcon), Bitmap).bitmapData;
                else{
                    var layer = new TileLayer(spritesheets.get(elemNode.att.spritesheet));
                    var tile = new TileSprite(elemNode.att.id);
                    layer.addChild(tile);
                    layer.render();
                    background = tile.bmp.bitmapData;
                }
                if(elemNode.has.buttonIcon){
                    buttonIcon = elemNode.att.buttonIcon;
                    buttonPos = new Point(Std.parseFloat(elemNode.att.buttonX), Std.parseFloat(elemNode.att.buttonY));
                }
                elementTemplate = {background: background, buttonIcon: buttonIcon, buttonPos: buttonPos};

            case "grid" : var grid = new Grid(Std.parseInt(elemNode.att.numRow), Std.parseInt(elemNode.att.numCol), elemNode.att.cellWidth, elemNode.att.cellHeight, Std.parseFloat(elemNode.att.gapCol), Std.parseFloat(elemNode.att.gapRow), Std.string(elemNode.att.alignX), Std.string(elemNode.att.alignY));
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
    }

    private function onClosePopUp(ev:MouseEvent):Void
    {
        popUp.removeChildAt(popUp.numChildren - 1);
        popUp.visible = false;
    }
}