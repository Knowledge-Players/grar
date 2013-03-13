package com.knowledgeplayers.grar.display.component;

import haxe.xml.Fast;
import com.knowledgeplayers.grar.structure.Game;
import nme.display.Sprite;
class ProgressBar extends Sprite{

    private var colorProgress:Int;
    public function new():Void{
        super();

    }

    public function init(_node:Fast):Void{

        this.x = Std.parseFloat(_node.att.x);
        this.y = Std.parseFloat(_node.att.y);
        graphics.beginFill (Std.parseInt(_node.att.background));
        graphics.drawRect (0, 0, Std.parseFloat(_node.att.width), Std.parseFloat(_node.att.height));
        graphics.endFill();

        colorProgress = Std.parseInt(_node.att.progressColor);

    }

}