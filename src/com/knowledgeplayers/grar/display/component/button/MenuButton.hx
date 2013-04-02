package com.knowledgeplayers.grar.display.component.button;

import nme.events.MouseEvent;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import nme.Lib;
import aze.display.TileSprite;
import aze.display.TileClip;
import aze.display.TileLayer;
import nme.display.Sprite;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;

class MenuButton extends CustomEventButton{

    private var hitBox:Sprite;
    private var status:TileClip;
    private var layerStatus:TileLayer;
    private var textSprite:Sprite;

    public function new(tilesheet:TilesheetEx, tile:String, eventName:String,?_status:String)
    {
        super(tilesheet, tile,eventName);
        layer.view.visible=false;

        hitBox = setHitBox(10,10);
        hitBox.alpha=0;
        if (_status != ""){
            layerStatus = new TileLayer(tilesheet);
            addChild(layerStatus.view);
            status = getStatus(_status);
            layerStatus.addChild(status);
            status.currentFrame = 0;
            layerStatus.render();
            }

    }

    private function setHitBox(_w:Float,_h:Float):Sprite{

        var _hitBox = new Sprite();

        _hitBox.graphics.beginFill(0xFFFFFF,1);
        _hitBox.graphics.drawRect(0,0,_w,_h);
        _hitBox.graphics.endFill();

        addChild(_hitBox);

        return _hitBox;
    }

    public function setStatus(num:Int):Void{

        status.currentFrame = num;
        layerStatus.render();
    }

    private function getStatus(_id:String):TileClip{
        var _stat = new TileClip(_id);


        return _stat;
    }

    public function setText(_text:String):Void{

        textSprite = KpTextDownParser.parse(_text);
        if(!contains(textSprite))
            addChild(textSprite);

        textSprite.mouseEnabled = false;
    }

    override private function onMouseOver(event:MouseEvent):Void
    {
        hitBox.alpha=1;
    }
    override private function onMouseOut(event:MouseEvent):Void
    {
        hitBox.alpha=0;
    }
/**
*  Align all elements of the Menu Button
**/

    public function alignElements():Void{

        hitBox.height =textSprite.height;
       var hWidth:Float = 0;
        if(status != null){
            textSprite.x = status.width;
            status.y = hitBox.y+(status.height/2);
            layerStatus.render();
            hWidth+=status.width;
        }

        hWidth+=textSprite.width;
        hitBox.width = hWidth;

        textSprite.y = hitBox.y;


    }


}