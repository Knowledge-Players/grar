package com.knowledgeplayers.grar.display.component;

import aze.display.TileSprite;
import com.knowledgeplayers.grar.factory.UiFactory;
import aze.display.TileLayer;
import aze.display.TileClip;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.structure.Game;
import nme.display.Sprite;

class ProgressBar extends Sprite{

    private var colorProgress:Int;
    private var layerProgressBar:TileLayer;
    private var icons:Hash<TileClip>;
    private var barWidth:Float=0;

    public function new():Void{
        super();

        layerProgressBar = new TileLayer(UiFactory.tilesheet);
        addChild(layerProgressBar.view);
        icons = new Hash<TileClip>();

    }

    public function init(_node:Fast):Void{

        this.x = Std.parseFloat(_node.att.x);
        this.y = Std.parseFloat(_node.att.y);
        barWidth = Std.parseFloat(_node.att.width);
        graphics.beginFill (Std.parseInt(_node.att.background));
        graphics.drawRect (0, 0, barWidth, Std.parseFloat(_node.att.height));
        graphics.endFill();

        addIcons(_node.att.icon);


        colorProgress = Std.parseInt(_node.att.progressColor);

    }

    private function addIcons(id:String):Void{

        var intro = new TileClip(id+"_introduction");
        var simu = new TileClip(id+"_simulation");
        var conclu = new TileClip(id+"_conclusion");

        icons.set("intro",intro);
        icons.set("simu",simu);
        icons.set("conclu",conclu);

        var posX:Float = (barWidth/3)/2;
        for(key in icons.keys()){
            var icon:TileClip = cast(icons.get(key),TileClip);
            layerProgressBar.addChild(icon);
            icon.currentFrame = 1;
            icon.x =posX;
            icon.y =-5;

            posX+=barWidth/3;
        }

        layerProgressBar.render();

    }

}