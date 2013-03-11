package com.knowledgeplayers.grar.display.activity.folder;

import com.knowledgeplayers.grar.structure.activity.folder.Folder;
import nme.Lib;
import nme.display.Bitmap;
import nme.display.BitmapData;
import com.eclecticdesignstudio.motion.Actuate;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.LoadData;
import nme.display.Bitmap;
import nme.display.SimpleButton;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.filters.DropShadowFilter;
import nme.geom.Point;

/**
* Display of an element in a folder activity
**/
class FolderElementDisplay extends Sprite {
    /**
    * Text of the element
**/
    public var text (default, null):ScrollPanel;

    /**
    * Content ID
**/
    public var content (default, null):String;

    /**
    * Origin before the drag
**/
    public var origin (default, default):Point;

    /**
    * Target ref for this element
    **/
    public var target (default, default):String;

    private var shadows:Hash<DropShadowFilter>;

    private var btIcon:String;
    private var btPos:Point;
    /**
    * Constructor
    * @param content : Text of the element
    * @param width : Width of the element
    * @param height : Height of the element
**/

    public function new(content:String, width:Float, height:Float, background:BitmapData, ?buttonIcon:String, ?buttonPos:Point)
    {
        super();
        this.content = content;
        text = new ScrollPanel(width, height);
        buttonMode = true;
        btIcon = buttonIcon;
        btPos = buttonPos;

        shadows = new Hash<DropShadowFilter>();
        shadows.set("down", new DropShadowFilter(10, 45, 0x000000, 0.3, 10, 10));
        shadows.set("up", new DropShadowFilter(15, 45, 0x000000, 0.2, 10, 10));

        var localizedText = Localiser.instance.getItemContent(content + "_title");
        text.setContent(KpTextDownParser.parse(localizedText));
        var bkg = new Bitmap(background);
        text.x = bkg.width / 2 - text.width / 2;
        text.y = bkg.height / 2 - text.height / 2;
        addChildAt(bkg, 0);
        filters = [shadows.get("down")];

        addChild(text);

        if(btIcon != null){
            var icon = cast(LoadData.getInstance().getElementDisplayInCache(btIcon), Bitmap);
            var button = new SimpleButton(icon, icon, icon, icon);
            button.addEventListener(MouseEvent.CLICK, onPlusClick);
            button.x = btPos.x;
            button.y = btPos.y;
            addChild(button);
        }
        //else
        //    addEventListener(MouseEvent.CLICK, onPlusClick);

        addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        addEventListener(MouseEvent.MOUSE_UP, onUp);
        addEventListener(Event.ADDED_TO_STAGE, onAdd);

    }

    public function blockElement():Void
    {
        removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
        removeEventListener(MouseEvent.MOUSE_UP, onUp);
        buttonMode = false;
    }

    // Handler

    private function onAdd(ev:Event):Void
    {
        origin = new Point(x, y);
    }

    private function onDown(e:MouseEvent):Void
    {
        origin.x = x;
        origin.y = y;
        parent.setChildIndex(this, parent.numChildren - 1);
        filters = [shadows.get("up")];
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
        if(outOfBound || (cast(folder.model, Folder).controlMode == "auto" && this.target != currentTarget.name)){
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
            blockElement();
        }
        filters = [shadows.get("down")];
    }

    private function onPlusClick(ev:MouseEvent):Void
    {
        // TODO modifier quand la grid sera propre
        var popUp = cast(parent, FolderDisplay).popUp;
        if(!popUp.visible){
            var localizedText = Localiser.instance.getItemContent(content);
            popUp.addChild(KpTextDownParser.parse(localizedText));
            parent.setChildIndex(popUp, parent.numChildren - 1);
            popUp.visible = true;
            Actuate.tween(popUp, 0.5, {alpha: 1});
        }
    }
}
