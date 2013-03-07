package com.knowledgeplayers.grar.display.activity.folder;

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
    public var target (default, default):{obj:DisplayObject, ref:String};

    /**
* PopUp where additional text will be displayed
**/
    public var popUp (default, default):Sprite;

    /**
* Grid to organize drag & drop display
**/
    public var grids (default, null):Hash<Grid>;

    private var elementTemplate:{background:String, buttonIcon:String, buttonPos:Point};

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
        elementsArray = new Array<FolderElementDisplay>();
    }

    public static function getInstance():FolderDisplay
    {
        if(instance == null)
            instance = new FolderDisplay();
        return instance;
    }

    public function drop(elem:FolderElementDisplay):Void
    {

        addChild(grids.get("drop").container);

        if(cast(model, Folder).elements.get(elem.content).target == target.ref){
            grids.get("drop").add(elem, false);
            elem.stopDrag();
            elem.blockElement();
        }
        else{
            elem.stopDrag();
            Actuate.tween(elem, 0.5, {x: elem.origin.x, y: elem.origin.y});
        }

        grids.get("drop").alignContainer(grids.get("drop").container, background);
    }

    // Private

    override private function displayActivity():Void
    {
        super.displayActivity();
        for(target in cast(model, Folder).targets){
            addChildAt(displays.get(target).obj, displays.get(target).z);
        }
    }

    override private function onModelComplete(e:LocaleEvent):Void
    {
        addChild(grids.get("drag").container);

        for(elem in cast(model, Folder).elements){
            var elementDisplay = new FolderElementDisplay(elem.content, grids.get("drag").cellSize.width, grids.get("drag").cellSize.height, elementTemplate.background, elementTemplate.buttonIcon, elementTemplate.buttonPos);
            elementsArray.push(elementDisplay);
            grids.get("drag").add(elementDisplay, false);
            grids.get("drag").container.addChild(elementDisplay);

        }

        grids.get("drag").alignContainer(grids.get("drag").container, background);

        super.onModelComplete(e);
    }

    override private function createElement(elemNode:Fast):Void
    {
        super.createElement(elemNode);
        switch(elemNode.name.toLowerCase()){
            case "target" : target = {obj: cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.src), Bitmap), ref: elemNode.att.ref};
                addElement(target.obj, elemNode);
            case "popup" : popUp.addChild(cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.src), Bitmap));
                var icon = cast(LoadData.getInstance().getElementDisplayInCache(elemNode.att.buttonIcon), Bitmap);

                var button = new SimpleButton(icon, icon, icon, icon);
                button.x = Std.parseFloat(elemNode.att.buttonX);
                button.y = Std.parseFloat(elemNode.att.buttonY);
                button.addEventListener(MouseEvent.CLICK, onClosePopUp);
                popUp.addChild(button);
                popUp.visible = false;
                popUp.alpha = 0;
                addElement(popUp, elemNode);
            case "element" : elementTemplate = {background:elemNode.att.src, buttonIcon: elemNode.att.buttonIcon, buttonPos: new Point(Std.parseFloat(elemNode.att.buttonX), Std.parseFloat(elemNode.att.buttonY))};
            case "grid" : var grid = new Grid(Std.parseInt(elemNode.att.numRow), Std.parseInt(elemNode.att.numCol), elemNode.att.cellWidth, elemNode.att.cellHeight, Std.parseFloat(elemNode.att.gapCol), Std.parseFloat(elemNode.att.gapRow), Std.string(elemNode.att.alignX), Std.string(elemNode.att.alignY));
                grid.x = Std.parseFloat(elemNode.att.x);
                grid.y = Std.parseFloat(elemNode.att.y);

                grids.set(elemNode.att.ref, grid);
        }
    }

    private function onClosePopUp(ev:MouseEvent):Void
    {
        popUp.removeChildAt(popUp.numChildren - 1);
        popUp.visible = false;
    }

    override private function unLoad(keepLayer:Int = 0):Void
    {
        super.unLoad(2);
        for(grid in grids){
            grid.empty();
        }
    }
}