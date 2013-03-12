package com.knowledgeplayers.grar.display.part;

import nme.events.Event;
import nme.filters.DropShadowFilter;
import com.knowledgeplayers.grar.display.component.button.AnimationButton;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import haxe.FastList;
import com.knowledgeplayers.grar.structure.activity.Activity;
import nme.Lib;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.factory.UiFactory;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * Display of a menu
 */

class MenuDisplay extends Sprite {
    /**
    * Orientation of the menu. Must be Horizontal or Vertical
    **/
    public var orientation (default, setOrientation): String;

    /**
    * Type of the menu. The menu could index parts or activities
    **/
    public var type (default, setType): String;

    /**
    * Prototype for the buttons of the menu
    **/
    public var buttonPartPrototype (default, default): Fast;

    /**
    * Prototype for the buttons of the menu
    **/
    public var buttonActivityPrototype (default, default): Fast;

    /**
    * transition open menu
    **/
    public var transitionIn:String;
    /**
    * transition close menu
    **/
    public var transitionOut:String;

    /**
    *  Button Close Menu
    **/
    public var btClose:DefaultButton;

    private var parts: Array<Part>;
    private var activities: Array<Activity>;
    private var items: List<MenuItem>;
    private var layer: TileLayer;
    private var typeInt: Int;
    private var game: Game;



    /**
     * Constructor
     * @param	game : Game model linked to the menu
     */

    public function new(game: Game)
    {
        super();
        layer = new TileLayer(UiFactory.tilesheet);
        addChild(layer.view);
        items = new List<MenuItem>();

        this.game = game;
    }

    /**
    * @:setter for orientation
    * @param    orientation : The orientation set
    * @return the orientation
    **/

    public function setOrientation(orientation: String): String
    {
        this.orientation = orientation.toLowerCase();
        return this.orientation;
    }

    /**
    * @:setter for type
    * @param    type : The type set
    * @return the type
    **/

    public function setType(type: String): String
    {
        this.type = type.toLowerCase();
        typeInt = switch(type){
            case "part": 1;
            case "activity": 2;
            case "both": 3;

        }
        return this.type;

    }
    private function onActionEvent(e:Event):Void{
        switch(e.type){


            case "close_menu": TweenManager.applyTransition(this,transitionOut);
        }
    }
    /**
    * Init the menu with an XML descriptor
    * @param    xml : XML descriptor
    **/
    private function createButton(_child:Fast):Void{

        var button: DefaultButton = null;
        button = UiFactory.createButtonFromXml(_child);
        if(_child.att.type=="event")
            {
                cast(button,CustomEventButton).addEventListener(_child.att.action,onActionEvent);
            }
        addChild(button);
    }

    public function init(display: Fast): Void
    {
        orientation = display.att.orientation;
        type = display.att.type;

        // TODO FilterManager
        var shadow:DropShadowFilter = new DropShadowFilter(0,90,0x000000,.3,70,0,3,1);
        this.filters=[shadow];
        /**/

        for (child in display.elements)
            {
                switch(child.name.toLowerCase()){
                    case "button":createButton(child);
                    case "text": addChild(UiFactory.createTextFromXml(child));
                    case "background":createBackground(child);
                }
            }

        //Part
        if(typeInt & 1 == 1){
            var partXOffset = Std.parseFloat(display.node.Part.att.xOffset);
            var partYOffset = Std.parseFloat(display.node.Part.att.yOffset);
            for(child in display.node.Part.elements){
                switch(child.name.toLowerCase()){
                    case "button": buttonPartPrototype = child;
                    case "image": createImage(child);
                    case "background":createBackground(child);

                }
            }
        }
        //Activities
        if(((typeInt & (1 << 1)) >> 1) == 1){
            var activityXOffset = Std.parseFloat(display.node.Activity.att.xOffset);
            var activityYOffset = Std.parseFloat(display.node.Activity.att.yOffset);
            for(child in display.node.Activity.elements){
                switch(child.name.toLowerCase()){
                    case "button": buttonActivityPrototype = child;
                    case "image": createImage(child);
                    case "background":createBackground(child);
                }
            }
        }

        if(typeInt & 1 == 1){
            parts = game.getAllParts();
            if(((typeInt & (1 << 1)) >> 1) == 1){
                // Both
                activities = game.getAllActivities();
                for(part in parts){
                    addButton(true, part.name);
                    for(activity in activities){
                        if(activity.container == part){
                            addButton(false, activity.name);
                        }
                    }
                }
            }
            else{
                // Part Only
                for(part in parts){
                    addButton(true, part.name);
                }
            }
        }
        else{
            // Activity Only
            activities = game.getAllActivities();
            for(activity in activities){
                addButton(false, activity.name);
            }
        }

        if(orientation == "vertical"){
            var offset: Float = 0;
            for(item in items){
                var node: Fast;
                if(item.isPart)
                    node = display.node.Part;
                else
                    node = display.node.Activity;
                if(node.has.xOffset)
                    item.button.x = Std.parseFloat(node.att.xOffset);
                item.button.y = offset;
                addChild(item.button);
                // TODO Height of a tilesprite is wrong
                //offset += item.button.height;
                if(node.has.yOffset)
                    offset += Std.parseFloat(node.att.yOffset);
            }
        }
        else{
            var offset: Float = 0;
            for(item in items){
                var node: Fast;
                if(item.isPart)
                    node = display.node.Part;
                else
                    node = display.node.Activity;
                if(node.has.yOffset)
                    item.button.y = Std.parseFloat(node.att.yOffset);
                item.button.x = offset;
                addChild(item.button);
                offset += item.button.width;
                if(node.has.xOffset)
                    offset += Std.parseFloat(node.att.xOffset);
            }
        }

        layer.render();
    }

    // Private

    private function onClick(e: MouseEvent): Void
    {
        var target = cast(e.target, DefaultButton);
        if(parts != null){
            for(part in parts){
                if(part.name == target.name){
                    GameManager.instance.displayPart(part);
                    break;
                }
            }
        }
        if(activities != null){
            for(activity in activities){
                if(activity.name == target.name){
                    GameManager.instance.displayActivity(activity);
                    break;
                }
            }
        }
    }

    private function createImage(imageNode: Fast): Void
    {
        var image = new TileSprite(imageNode.att.id);
        image.scaleX = Std.parseFloat(imageNode.att.scaleX);
        image.scaleY = Std.parseFloat(imageNode.att.scaleY);
        image.x = Std.parseFloat(imageNode.att.x);
        image.y = Std.parseFloat(imageNode.att.y);
        layer.addChild(image);


    }

    private function createBackground(bkgNode:Fast,?_container:Sprite): Sprite{

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


        _container.addChild(background);

        return _container;

    }

    private function createHeader():Void{

    }

    private function addButton(isPart: Bool, text: String = ""): Void
    {
        var button: DefaultButton = null;
        if(isPart)
            button = UiFactory.createButtonFromXml(buttonPartPrototype);
        else
            button = UiFactory.createButtonFromXml(buttonActivityPrototype);
        if(Std.is(button, TextButton))
            cast(button, TextButton).setText(text);
        button.name = text;
        button.addEventListener(MouseEvent.CLICK, onClick);
        items.add({button: button, isPart: isPart});
    }
}

typedef MenuItem = {button: DefaultButton, isPart: Bool}