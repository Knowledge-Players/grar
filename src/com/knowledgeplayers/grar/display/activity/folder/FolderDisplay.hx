package com.knowledgeplayers.grar.display.activity.folder;

import com.knowledgeplayers.grar.util.LoadData;
import Std;
import nme.events.MouseEvent;
import nme.display.SimpleButton;
import nme.display.Sprite;
import nme.Lib;
import nme.geom.Point;
import com.knowledgeplayers.grar.event.PartEvent;
import haxe.FastList;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import nme.Assets;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.event.LocaleEvent;
import nme.events.Event;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.folder.Folder;
import com.eclecticdesignstudio.motion.Actuate;

/**
* Display of the folder activity
**/
class FolderDisplay extends ActivityDisplay {

    /**
* Instance
**/
    public static var instance (getInstance, null): FolderDisplay;

    /**
* DisplayObject where to drag the elements
**/
    public var target (default, default): {obj: DisplayObject, ref: String};

    /**
* PopUp where additional text will be displayed
**/
    public var popUp (default, default): Sprite;

    /**
* Grid to organize drag & drop display
**/
    public var grids (default, null): Hash<Grid>;

    private var elementTemplate: {background: String, buttonIcon: String, buttonPos: Point};

    private var content:Fast;

    /**
* @return the instance
**/

    public static function getInstance(): FolderDisplay
    {
        if(instance == null)
            instance = new FolderDisplay();
        return instance;
    }

    public function drop(elem: FolderElementDisplay): Void
    {
        if(cast(model, Folder).elements.get(elem.content).target == target.ref){
            grids.get("drop").add(elem);
            elem.stopDrag();
            elem.blockElement();
        }
        else{
            elem.stopDrag();
            Actuate.tween(elem, 0.5, {x: elem.origin.x, y: elem.origin.y});
        }
    }

    // Private

    override private function onModelComplete(e: LocaleEvent): Void
    {
        for(elem in cast(model, Folder).elements){
            var elementDisplay = new FolderElementDisplay(elem.content, grids.get("drag").cellSize.width, grids.get("drag").cellSize.height, elementTemplate.background, elementTemplate.buttonIcon, elementTemplate.buttonPos);
            grids.get("drag").add(elementDisplay, false);
            addChild(elementDisplay);
        }


        super.onModelComplete(e);
    }



    override private function parseContent(content: Fast): Void
    {
        this.content = content;
        for (child in content.elements){
            if(child.name.toLowerCase() == "background"){

                var background=  cast(LoadData.getInstance().getElementDisplayInCache(child.att.src),Bitmap);
                ResizeManager.instance.addDisplayObjects(background, child);
                addChild(background);
            }
            else if(child.name.toLowerCase() == "target"){
                target = {obj: cast(LoadData.getInstance().getElementDisplayInCache(child.att.src),Bitmap), ref: child.att.ref};
                initDisplayObject(target.obj, child);
                ResizeManager.instance.addDisplayObjects(target.obj, child);
                addChild(target.obj);
            }
            else if(child.name.toLowerCase() == "popup"){



                popUp.addChild(cast(LoadData.getInstance().getElementDisplayInCache(content.node.PopUp.att.src),Bitmap));
                var icon = cast(LoadData.getInstance().getElementDisplayInCache(content.node.PopUp.att.buttonIcon),Bitmap);

                var button = new SimpleButton(icon, icon, icon, icon);
                button.x = Std.parseFloat(content.node.PopUp.att.buttonX);
                button.y = Std.parseFloat(content.node.PopUp.att.buttonY);
                button.addEventListener(MouseEvent.CLICK, onClosePopUp);
                popUp.addChild(button);
                initDisplayObject(popUp, content.node.PopUp);
                popUp.visible = false;
                popUp.alpha = 0;
                ResizeManager.instance.addDisplayObjects(popUp, content.node.PopUp);
                addChild(popUp);
            }
        }
        for(grid in content.nodes.Grid){
        var g = new Grid(Std.parseInt(grid.att.numRow), Std.parseInt(grid.att.numCol), Std.parseFloat(grid.att.cellWidth), Std.parseFloat(grid.att.cellHeight));
        g.x = Std.parseFloat(grid.att.x);
        g.y = Std.parseFloat(grid.att.y);
        grids.set(grid.att.ref, g);
    }

        var elemNode = content.node.Element;
        elementTemplate = {background:elemNode.att.src, buttonIcon: elemNode.att.buttonIcon, buttonPos: new Point(Std.parseFloat(elemNode.att.buttonX), Std.parseFloat(elemNode.att.buttonY))};

    }



    private function onClosePopUp(ev: MouseEvent): Void
    {
        popUp.removeChildAt(popUp.numChildren - 1);
        popUp.visible = false;
    }

    override private function unLoad(keepLayer: Int = 0): Void
    {
        super.unLoad(2);
        for(grid in grids){
            grid.empty();
        }
    }

    private function new()
    {
        super();
        grids = new Hash<Grid>();
        popUp = new Sprite();
    }
}