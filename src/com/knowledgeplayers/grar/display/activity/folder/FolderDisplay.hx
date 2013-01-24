package com.knowledgeplayers.grar.display.activity.folder;

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
    * Grid to organize drag & drop display
**/
    public var grids (default, null): Hash<Grid>;

    private var depths: IntHash<DisplayObject>;
    private var elements: FastList<FolderElementDisplay>;

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
        for(i in 1...Lambda.count(depths) + 1){
            if(depths.get(i) != null)
                addChild(depths.get(i));
        }
        for(elem in elements){
            elem.init();
            grids.get("drag").add(elem, false);
            addChild(elem);
        }

        dispatchEvent(new Event(Event.COMPLETE));
    }

    override private function parseContent(content: Fast): Void
    {
        var background = new Bitmap(Assets.getBitmapData(content.node.Background.att.Id));
        depths.set(Std.parseInt(content.node.Background.att.Z), background);
        ResizeManager.instance.addDisplayObjects(background, content.node.Background);

        target = new Bitmap(Assets.getBitmapData(content.node.Target.att.Background));
        initDisplayObject(target, content.node.Target);
        depths.set(Std.parseInt(content.node.Target.att.Z), target);
        ResizeManager.instance.addDisplayObjects(target, content.node.Target);

        for(grid in content.nodes.Grid){
            var g = new Grid(Std.parseInt(grid.att.numRow), Std.parseInt(grid.att.numCol), Std.parseFloat(grid.att.CellWidth), Std.parseFloat(grid.att.CellHeight));
            g.x = Std.parseFloat(grid.att.X);
            g.y = Std.parseFloat(grid.att.Y);
            grids.set(grid.att.Ref, g);
        }
        for(text in content.nodes.Text){
            var element = new FolderElementDisplay(text.att.Ref, grids.get("drag").cellSize.width, grids.get("drag").cellSize.height);
            element.text.setBackground(text.att.Background);
            elements.add(element);
        }

    }

    private function new()
    {
        super();
        depths = new IntHash<DisplayObject>();
        elements = new FastList<FolderElementDisplay>();
        grids = new Hash<Grid>();
    }
}
