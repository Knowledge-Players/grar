package com.knowledgeplayers.grar.display.component.button;

import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import nme.Lib;
import aze.display.TileSprite;
import aze.display.TileClip;
import aze.display.TileLayer;
import nme.display.Sprite;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;

class MenuButton extends CustomEventButton{

    public var hitBox:Sprite;
    public var status:TileClip;
    public var layerStatus:TileLayer;
    private var textSprite:Sprite;

    public function new(tilesheet:TilesheetEx, tile:String, eventName:String,?hitBoxWidth:Float,?hitBoxHeight:Float,?_status:String)
    {
        super(tilesheet, tile,eventName);
        layer.view.visible=false;

        hitBox = setHitBox(hitBoxWidth,hitBoxHeight);

        layerStatus = new TileLayer(tilesheet);
        addChild(layerStatus.view);

        //var test = new TileSprite(_status);
        status = getStatus(_status);

        layerStatus.addChild(status);

        status.currentFrame = 0;

        layerStatus.render();


    }

    private function setHitBox(_w:Float,_h:Float):Sprite{

        var _hitBox = new Sprite();

        _hitBox.graphics.beginFill(0x999999,.1);
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

        //_stat.currentFrame = 1;
        return _stat;
    }

    public function setText(_text:String):Void{

        textSprite = KpTextDownParser.parse(_text);
        if(!contains(textSprite))
            addChild(textSprite);

        textSprite.mouseEnabled = false;
    }


}