package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.grar.util.SpriteSheetLoader;
import nme.events.Event;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.util.LoadData;
import aze.display.SparrowTilesheet;
import nme.display.DisplayObject;
import nme.geom.Point;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.grar.display.element.CharacterDisplay;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import aze.display.TileSprite;
import nme.display.Bitmap;
import haxe.xml.Fast;
import nme.display.Sprite;

class KpDisplay extends Sprite {
    private var displays:Hash<{obj:DisplayObject, z:Int}>;
    private var displaysFast:Hash<Fast>;
    private var spritesheets:Hash<SparrowTilesheet>;
    private var zIndex:Int = 0;
    private var textGroups:Hash<Hash<{obj:Fast, z:Int}>>;
    private var layers:Hash<TileLayer>;
    private var displayFast:Fast;
    private var numSpriteSheetsLoaded:Int = 0;
    private var totalSpriteSheets:Int = 0;

    /**
    * Parse the content of a display XML
    * @param    content : Content of the XML
    **/

    public function parseContent(content:Xml):Void
    {
        displayFast = new Fast(content.firstElement());

        totalSpriteSheets = Lambda.count(displayFast.nodes.SpriteSheet);

        if(totalSpriteSheets > 0){
            for(child in displayFast.nodes.SpriteSheet){
                loadSpritesheet(child);
            }
        }
        else{
            createDisplay();
        }

        ResizeManager.instance.onResize();
    }

    // Privates

    private function createDisplay():Void
    {
        for(child in displayFast.elements){
            createElement(child);
        }
    }

    private function createElement(elemNode:Fast):Void
    {
        switch(elemNode.name.toLowerCase()){
            case "background": createBackground(elemNode);
            case "item": createItem(elemNode);
            case "character": createCharacter(elemNode);
            case "button": createButton(elemNode);
            case "text": createText(elemNode);
            case "textgroup":createTextGroup(elemNode);
        }
    }

    private function createBackground(bkgNode:Fast):Void
    {
        displaysFast.set(bkgNode.att.ref, bkgNode);
        zIndex++;
    }

    private function createItem(itemNode:Fast):Void
    {
        if(itemNode.has.src){
            var itemBmp:Bitmap = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(itemNode.att.src), Bitmap).bitmapData);
            addElement(itemBmp, itemNode);
        }
        else{
            var itemTile = new TileSprite(itemNode.att.id);
            layers.get(itemNode.att.spritesheet).addChild(itemTile);
            addElement(layers.get(itemNode.att.spritesheet).view, itemNode);
        }

    }

    private function createButton(buttonNode:Fast):Void
    {
        var button:DefaultButton = UiFactory.createButtonFromXml(buttonNode);

        if(buttonNode.has.action)
            setButtonAction(cast(button, CustomEventButton), buttonNode.att.action);

        addElement(button, buttonNode);
    }

    private function createText(textNode:Fast):Void
    {
        var background:String = textNode.has.background ? textNode.att.background : null;
        var spritesheet = null;
        if(background != null && background.indexOf(".") < 0)
            spritesheet = spritesheets.get(textNode.att.background);

        var scrollable:Bool;
        if(textNode.has.scrollable)
            scrollable = textNode.att.scrollable == "true";
        else
            scrollable = true;

        var text = new ScrollPanel(Std.parseFloat(textNode.att.width), Std.parseFloat(textNode.att.height), scrollable, spritesheet);
        if(spritesheet != null && background != null)
            text.background = background;

        addElement(text, textNode);
    }

    private function createTextGroup(textNode:Fast):Void
    {

        var numIndex = 0;
        var hashTextGroup = new Hash<{obj:Fast, z:Int}>();

        for(child in textNode.elements){
            if(child.name.toLowerCase() == "text"){

                //createText(child);
                var text = new ScrollPanel(Std.parseFloat(child.att.width), Std.parseFloat(child.att.height));
                text.setBackground(child.att.background);
                hashTextGroup.set(child.att.ref, {obj:child, z:numIndex});

                addElement(text, child);

                numIndex++;

            }
        }
        textGroups.set(textNode.att.ref, hashTextGroup);
    }

    private function createCharacter(character:Fast)
    {
        var char:CharacterDisplay = new CharacterDisplay(spritesheets.get(character.att.spritesheet), character.att.id, new Character(character.att.ref));
        char.visible = false;
        char.origin = new Point(Std.parseFloat(character.att.x), Std.parseFloat(character.att.y));
        addElement(char, character);

    }

    private function addElement(elem:DisplayObject, node:Fast, initObject:Bool = true):Void
    {
        if(initObject)
            initDisplayObject(elem, node);
        if(node.has.id && !node.has.ref){
            displays.set(node.att.id, {obj: elem, z: zIndex});
            displaysFast.set(node.att.id, node);
        }
        else if(!node.has.ref){
            displays.set(node.att.src, {obj: elem, z: zIndex});
            displaysFast.set(node.att.src, node);
        }
        else{
            displays.set(node.att.ref, {obj: elem, z: zIndex});
            displaysFast.set(node.att.ref, node);
        }
        ResizeManager.instance.addDisplayObjects(elem, node);
        zIndex++;
    }

    private function initDisplayObject(display:DisplayObject, node:Fast, ?transition:String):Void
    {
        display.x = Std.parseFloat(node.att.x);
        display.y = Std.parseFloat(node.att.y);

        if(node.has.width)
            display.width = Std.parseFloat(node.att.width);
        else if(node.has.scaleX)
            display.scaleX = Std.parseFloat(node.att.scaleX);
        if(node.has.height)
            display.height = Std.parseFloat(node.att.height);
        else if(node.has.scaleY)
            display.scaleY = Std.parseFloat(node.att.scaleY);
    }

    private function loadSpritesheet(spritesheetNode:Fast):Void
    {
        var loader = new SpriteSheetLoader();
        loader.addEventListener(Event.COMPLETE, onSpriteSheetLoaded);

        loader.init(spritesheetNode.att.id, spritesheetNode.att.src);
    }

    private function setButtonAction(button:CustomEventButton, action:String):Void
    {}

    private function new()
    {
        super();
        displays = new Hash<{obj:DisplayObject, z:Int}>();
        displaysFast = new Hash<Fast>();
        spritesheets = new Hash<SparrowTilesheet>();
        textGroups = new Hash<Hash<{obj:Fast, z:Int}>>();
        layers = new Hash<TileLayer>();
    }

    // Handlers

    private function onSpriteSheetLoaded(ev:Event):Void
    {
        ev.target.removeEventListener(Event.COMPLETE, onSpriteSheetLoaded);
        spritesheets.set(ev.target.name, ev.target.spriteSheet);
        var layer = new TileLayer(ev.target.spriteSheet);
        layers.set(ev.target.name, layer);
        numSpriteSheetsLoaded++;
        if(numSpriteSheetsLoaded == totalSpriteSheets){
            createDisplay();
        }
    }
}
