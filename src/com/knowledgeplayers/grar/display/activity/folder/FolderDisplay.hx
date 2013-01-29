package com.knowledgeplayers.grar.display.activity.folder;

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
    * Model for this display
**/
    public var folder (default, setModel): Folder;

    /**
    * DisplayObject where to drag the elements
**/
    public var target (default, default): DisplayObject;

    /**
    * PopUp where additional text will be displayed
**/
    public var popUp (default, default): Sprite;

    /**
    * Grid to organize drag & drop display
**/
    public var grids (default, null): Hash<Grid>;

    private var elementTemplate: {background: String, buttonIcon: String, buttonPos: Point};

    /**
    * @return the instance
**/

    public static function getInstance(): FolderDisplay
    {
        if(instance == null)
            instance = new FolderDisplay();
        return instance;
    }

    override public function setModel(model: Activity): Folder
    {
        folder = cast(model, Folder);
        folder.addEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
        folder.addEventListener(Event.COMPLETE, onEndActivity);
        this.model = folder;
        folder.loadActivity();

        return folder;
    }

    public function drop(elem: FolderElementDisplay): Void
    {
        if(folder.elements.get(elem.content).isAnswer){
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

    private function onEndActivity(e: Event): Void
    {
        model.endActivity();
        unLoad();
        folder.removeEventListener(PartEvent.EXIT_PART, onEndActivity);
    }

    private function onModelComplete(e: LocaleEvent): Void
    {
        for(elem in folder.elements){
            var elementDisplay = new FolderElementDisplay(elem.content, grids.get("drag").cellSize.width, grids.get("drag").cellSize.height, elementTemplate.background, elementTemplate.buttonIcon, elementTemplate.buttonPos);
            grids.get("drag").add(elementDisplay, false);
            addChild(elementDisplay);
        }

        dispatchEvent(new Event(Event.COMPLETE));
    }

    override private function parseContent(content: Fast): Void
    {
        for(child in content.elements){
            if(child.name.toLowerCase() == "background"){
                var background = new Bitmap(Assets.getBitmapData(child.att.Id));
                ResizeManager.instance.addDisplayObjects(background, child);
                addChild(background);
            }
            else if(child.name.toLowerCase() == "target"){
                target = new Bitmap(Assets.getBitmapData(child.att.Background));
                initDisplayObject(target, child);
                ResizeManager.instance.addDisplayObjects(target, child);
                addChild(target);
            }
            else if(child.name.toLowerCase() == "popup"){
                popUp.addChild(new Bitmap(Assets.getBitmapData(content.node.PopUp.att.Background)));
                var icon = new Bitmap(Assets.getBitmapData(content.node.PopUp.att.ButtonIcon));
                var button = new SimpleButton(icon, icon, icon, icon);
                button.x = Std.parseFloat(content.node.PopUp.att.ButtonX);
                button.y = Std.parseFloat(content.node.PopUp.att.ButtonY);
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
            var g = new Grid(Std.parseInt(grid.att.numRow), Std.parseInt(grid.att.numCol), Std.parseFloat(grid.att.CellWidth), Std.parseFloat(grid.att.CellHeight));
            g.x = Std.parseFloat(grid.att.X);
            g.y = Std.parseFloat(grid.att.Y);
            grids.set(grid.att.Ref, g);
        }

        var elemNode = content.node.Element;
        elementTemplate = {background: elemNode.att.Background, buttonIcon: elemNode.att.ButtonIcon, buttonPos: new Point(Std.parseFloat(elemNode.att.ButtonX), Std.parseFloat(elemNode.att.ButtonY))};

    }

    private function onClosePopUp(ev: MouseEvent): Void
    {
        popUp.removeChildAt(popUp.numChildren - 1);
        popUp.visible = false;
    }

    private function new()
    {
        super();
        grids = new Hash<Grid>();
        popUp = new Sprite();
    }
}
