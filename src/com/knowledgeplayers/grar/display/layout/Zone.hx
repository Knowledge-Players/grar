package com.knowledgeplayers.grar.display.layout;


import com.knowledgeplayers.grar.display.component.ProgressBar;
import com.knowledgeplayers.grar.display.part.MenuDisplay;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.DisplayUtils;
import nme.Lib;
import com.knowledgeplayers.grar.event.LayoutEvent;
import nme.display.Sprite;
import haxe.xml.Fast;


class Zone extends Sprite {
    public var ref: String;

    private var zoneWidth: Float;
    private var zoneHeight: Float;

    public function new(_width: Float, _height: Float): Void
    {
        super();
        //DisplayUtils.initSprite(this, width, height);
        zoneWidth = _width;
        zoneHeight = _height;
    }


    public function init(_zone: Fast): Void
    {
        if(_zone.has.bgColor)
            DisplayUtils.initSprite(this, zoneWidth, zoneHeight, Std.parseInt(_zone.att.bgColor));
        else
            DisplayUtils.initSprite(this, zoneWidth, zoneHeight);
        if(_zone.has.ref){
            var layer = new TileLayer(UiFactory.tilesheet);

            ref = _zone.att.ref;
            dispatchEvent(new LayoutEvent(LayoutEvent.NEW_ZONE, ref, this));
            for(element in _zone.elements){
                switch(element.name.toLowerCase()){
                    case "button":addChild(UiFactory.createButtonFromXml(element));
                    case "image": layer.addChild(UiFactory.createImageFromXml(element));
                    case "background": DisplayUtils.setBackground(element.att.src, this);
                    case "text": addChild(UiFactory.createTextFromXml(element));
                    case "menu": var menu = new MenuDisplay(LayoutManager.instance.game);
                        menu.init(element);
                        menu.x = Std.parseFloat(element.att.x);
                        menu.y = Std.parseFloat(element.att.y);
                        addChild(menu);
                    case "progressbar": var progress = new ProgressBar(LayoutManager.instance.game);
                        progress.init(element);
                        addChild(progress);
                }
            }
            addChild(layer.view);
            layer.render();
        }
        else if(_zone.has.rows){
            var heights = initSize(_zone.att.rows, height);
            var yOffset: Float = 0;
            var i = 0;
            for(row in _zone.nodes.Row){
                var zone = new Zone(zoneWidth, heights[i]);
                zone.x = x;
                zone.y = yOffset;
                zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
                zone.init(row);
                yOffset += zone.zoneHeight;
                addChild(zone);
                i++;
            }
        }
        else if(_zone.has.columns){
            var widths = initSize(_zone.att.columns, width);
            var xOffset: Float = 0;
            var j = 0;
            for(column in _zone.nodes.Column){
                var zone = new Zone(widths[j], zoneHeight);
                zone.x = xOffset;
                zone.y = y;
                zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
                zone.init(column);
                xOffset += zone.zoneWidth;
                addChild(zone);
                j++;
            }
        }
        else{
            Lib.trace("[Zone] This zone is empty. Are you sure your XML is correct ?");
        }
    }

    private function initSize(sizes: String, maxSize: Float): Array<Dynamic>
    {
        var sizeArray: Array<Dynamic> = sizes.split(",");
        var starPosition: Int = -1;
        for(i in 0...sizeArray.length){
            sizeArray[i] = StringTools.trim(sizeArray[i]);
            if(sizeArray[i].indexOf("%") > 0){
                sizeArray[i] = Std.parseFloat(sizeArray[i].substr(0, sizeArray[i].length - 1)) * maxSize / 100;
            }
            else if(sizeArray[i] == "*"){
                starPosition = i;
            }
        }
        for(size in sizeArray){
            if(size != "*")
                maxSize -= Std.parseFloat(size);
        }
        if(starPosition != -1)
            sizeArray[starPosition] = maxSize;

        return sizeArray;
    }

    // Handlers

    private function onNewZone(e: LayoutEvent): Void
    {
        dispatchEvent(e);
    }
}