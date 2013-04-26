package com.knowledgeplayers.grar.display.element;

import nme.events.Event;
import aze.display.TileClip;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import nme.display.Sprite;

class AnimationDisplay extends Sprite {

    private  var layer:TileLayer;
    private var clip:TileClip;

    public function new(_id:String,_x:Float,_y:Float,_tileSheet:TilesheetEx,_scaleX:Float,_scaleY:Float,_type:String,_loop:Float,_alpha:Float,mirror:String){
        super();

        layer = new TileLayer(_tileSheet);
        clip = new TileClip(_id);
        clip.x = _x;
        clip.y = _y;
        clip.scaleX = _scaleX;
        clip.scaleY = _scaleY;
        clip.alpha = _alpha;

        if(mirror != null){
            clip.mirror = switch(mirror.toLowerCase()){
                case "horizontal" : 1;
                case "vertical" : 2;
            }
        }
        layer.addChild(clip);
        addChild(layer.view);

        layer.render();
    }


    /**
    * Play the animation with an Enter_Frame
    **/

    public function animElement():Void{

        this.addEventListener(Event.ENTER_FRAME, loop);
    }

    /**
    * Stop the animation
    **/

    public function stopElement():Void{
        this.removeEventListener(Event.ENTER_FRAME, loop);
        clip.currentFrame = 0;
        layer.render();
    }
    /*
     Goto the frame you want;
     */
    public function goto(_frame:Int):Void{
        clip.currentFrame = _frame;
        layer.render();
    }

    private function loop(e:Event):Void{
        clip.play();
        layer.render();
    }


}