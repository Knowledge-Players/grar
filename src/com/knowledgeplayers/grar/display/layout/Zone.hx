package com.knowledgeplayers.grar.display.layout;


import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.XmlLoader;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import aze.display.TileSprite;
import com.eclecticdesignstudio.motion.easing.Quart;
import com.eclecticdesignstudio.motion.Actuate;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import nme.events.Event;
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
    private var menu:MenuDisplay;
    private var layer:TileLayer;

    public function new(_width: Float, _height: Float): Void
    {
        super();
        //DisplayUtils.initSprite(this, width, height);
        zoneWidth = _width;
        zoneHeight = _height;
    }

    public function init(_zone: Fast): Void
    {
        if(_zone.has.text)
            {
                Lib.trace(Localiser.instance.currentLocale);
                //XmlLoader.load();
            }
        if(_zone.has.bgColor)
            DisplayUtils.initSprite(this, zoneWidth, zoneHeight, Std.parseInt(_zone.att.bgColor));
        else
            DisplayUtils.initSprite(this, zoneWidth, zoneHeight);
        if(_zone.has.ref){
            layer = new TileLayer(UiFactory.tilesheet);

            ref = _zone.att.ref;
            dispatchEvent(new LayoutEvent(LayoutEvent.NEW_ZONE, ref, this));
            addChild(layer.view);

            for(element in _zone.elements){
                switch(element.name.toLowerCase()){
                    case "background": createBackground(element);
                    case "image": createImage(element);
                    case "text":createText(element);
                    case "button": createButton(element);
                    case "progressbar": createProgressBar(element);
                    case "menu":createMenu(element);
                }
            }

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

    public function createButton(_child:Fast):DefaultButton{

        var button: DefaultButton = null;


        button = UiFactory.createButtonFromXml(_child);
        if(_child.att.type=="event")
        {
            cast(button,CustomEventButton).addEventListener(_child.att.action,onActionEvent);
        }
        addChild(button);

        return button;
    }

    public function createImage(imageNode: Fast): TileSprite
    {
        var image = UiFactory.createImageFromXml(imageNode);
        layer.addChild(image);

        return image;


    }

    private function createHeader():Void{

    }
    private function createProgressBar(element:Fast):ProgressBar{
        var progress = new ProgressBar();
        progress.init(element);
        addChild(progress);

        return progress;
    }

    private function createText(element:Fast):ScrollPanel{
        var textF = UiFactory.createTextFromXml(element);

        textF.content = KpTextDownParser.parse(Localiser.instance.getItemContent(element.att.content));

        addChild(textF);

        return textF;

    }

    public function createBackground(bkgNode:Fast,?_container:Sprite): Sprite{

        if (_container == null)
        {
            _container = new Sprite();
            addChild(_container);
        }

        var background = new Sprite();

        var color:Int;
        if (bkgNode.has.color)
            color=Std.parseInt(bkgNode.att.color);
        else
            color=Std.parseInt("0xFFFFFF");
            background.graphics.beginFill(color);
            background.graphics.drawRect(Std.parseFloat(bkgNode.att.x),Std.parseFloat(bkgNode.att.y),Std.parseFloat(bkgNode.att.width),Std.parseFloat(bkgNode.att.height));
            background.graphics.endFill();

        if(bkgNode.has.filter){
            _container.filters=[UiFactory.createFilterFromXml(bkgNode)];
        }

        _container.addChild(background);

        return _container;

    }

    public function createMenu(element:Fast):Void{

        menu = new MenuDisplay(Std.parseFloat(element.att.width),Std.parseFloat(element.att.height));
        menu.initMenu(element);
        menu.transitionIn = element.att.transitionIn;
        menu.transitionOut = element.att.transitionOut;
        menu.x= Std.parseFloat(element.att.x);
        menu.y= Std.parseFloat(element.att.y);

        addChild(menu);
    }



    public function onActionEvent(e:Event):Void{
       switch(e.type){
           case "open_menu":TweenManager.applyTransition(menu,menu.transitionIn);
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