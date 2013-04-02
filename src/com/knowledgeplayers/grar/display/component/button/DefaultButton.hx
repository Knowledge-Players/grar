package com.knowledgeplayers.grar.display.component.button;
import aze.display.TileClip;
import browser.Lib;
import nme.geom.Point;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * Custom base button class
 * @author jbrichardet
 */

class DefaultButton extends Sprite {

    /**
     * Layer of the button
     */
    public var layer:TileLayer;

    /**
     * Switch to enable the button
     */
    public var enabled (default, enable):Bool;

    /**
    * Reference of the button
    **/
    public var ref (default, default):String;

    /**
    * Scale of the button
    **/
    public var scale (default, setScale):Float;

    /**
    * Mirror
    **/
    public var mirror (default, setMirror):Int;

    /**
    * Icon to add over the button
    **/
    private var icon:TileSprite;

    /**
     * Sprite containing the upstate
     */
    private var upState:TileSprite;

    /**
     * Sprite containing the overstater
     */
    private var overState:TileSprite;

    /**
     * Sprite containing the downstate
     */
    private var downState:TileSprite;

    private var clip:TileClip;

    /**
     * Constructor. Downstate and overstate are automatically set if their tile are
     * name upstateName+"_pressed" and upstateName+"_over"
     * @param	tilesheet : UI Sheet
     * @param	tile : Tile containing the upstate
     * @param	tilePressed : Tile containing the downstate
     * @param	tileOver : Tile containing the overstate
     */

    public function new(tilesheet:TilesheetEx, tile:String)
    {
        super();

        layer = new TileLayer(tilesheet);
        //upState = new TileSprite(tile);
        //downState = new TileSprite(tile);
        //overState = new TileSprite(tile);
        clip = new TileClip(tile);
        mouseChildren = false;

        init();
    }

    /**
     * Enable or disable the button
     * @param	activate : True to activate the button
     * @return true if the button is now activated
     */

    public function enable(activate:Bool):Bool
    {
        enabled = buttonMode = mouseEnabled = activate;

        return activate;
    }

    public function setStateIcon(state:ButtonState, tileId:String)
    {
        var visible = false;
        switch(state){
            case UP :
                //visible = upState.visible;
                //layer.removeChild(upState);
                //upState = new TileSprite(tileId);
                //layer.addChild(upState);
                //upState.visible = visible;
            case DOWN :
                //visible = downState.visible;
                //layer.removeChild(downState);
                //downState = new TileSprite(tileId);
                //layer.addChild(downState);
                //downState.visible = visible;
            case OVER :
                //visible = overState.visible;
                //layer.removeChild(overState);
                //overState = new TileSprite(tileId);
                //layer.addChild(overState);
                //overState.visible = visible;
        }

        layer.addChild(clip);

        layer.render();
    }

    public function setIcon(icon:TileSprite, iconPos:Point):TileSprite
    {
        icon.x = iconPos.x;
        icon.y = iconPos.y;
        layer.addChild(icon);
        layer.render();
        return this.icon = icon;
    }

    public function setScale(scale:Float):Float
    {
        return scaleX = scaleY = this.scale = scale;
    }

    public function setMirror(mirror:Int):Int
    {
        for(sprite in layer.children)
            cast(sprite, TileSprite).mirror = mirror;
        layer.render();
        return this.mirror = mirror;
    }

    // Abstract

    private function onMouseOver(event:MouseEvent):Void
    {}

    private function onMouseOut(event:MouseEvent):Void
    {}

    private function onClick(event:MouseEvent):Void
    {}

    private function onDblClick(event:MouseEvent):Void
    {}

    private function open(event:MouseEvent):Void
    {}

    private function close(event:MouseEvent):Void
    {}

    // Private

    private function setAllListeners(listener:MouseEvent -> Void):Void
    {
        removeAllEventsListeners(listener);
        addEventListener(MouseEvent.MOUSE_OUT, listener);
        addEventListener(MouseEvent.MOUSE_OVER, listener);
        addEventListener(MouseEvent.ROLL_OVER, listener);
        addEventListener(MouseEvent.ROLL_OUT, listener);
        addEventListener(MouseEvent.CLICK, listener);
        addEventListener(MouseEvent.DOUBLE_CLICK, listener);
        addEventListener(MouseEvent.MOUSE_DOWN, listener);
        addEventListener(MouseEvent.MOUSE_UP, listener);
    }

    private function onOver(event:MouseEvent):Void
    {
        //upState.visible = false;
        //overState.visible = false;
        if(clip.frames.length >0)
            {
                clip.currentFrame = 1;
            }
        layer.render();
    }

    private function onOut(event:MouseEvent):Void
    {
        //overState.visible = false;
        //upState.visible = false;
        if(clip.frames.length >0)
        {
            clip.currentFrame = 0;
        }
        layer.render();
    }

    private function onClickDown(event:MouseEvent):Void
    {
        //overState.visible = false;
        //downState.visible = false;

        layer.render();
    }

    private function onClickUp(event:MouseEvent):Void
    {
        //upState.visible = false;
        //downState.visible = false;

        layer.render();
    }

    private function init():Void
    {
        enabled = true;

        //downState.visible = false;
        //overState.visible = false;
        //upState.visible = false;

        //layer.addChild(upState);
        //layer.addChild(downState);
        //layer.addChild(overState);
        layer.addChild(clip);
        setAllListeners(onMouseEvent);

        addChild(layer.view);

        layer.render();

        // TODO Test if this is still necessary
        // Hack for C++ hitArea (NME 3.4.4)
        #if cpp
			graphics.beginFill (0xFFFFFF, 0.01);
			graphics.drawRect (-upState.width/2, -upState.height/2, upState.width, upState.height);
		#end
    }

    private function removeAllEventsListeners(listener:MouseEvent -> Void):Void
    {
        removeEventListener(MouseEvent.MOUSE_OUT, listener);
        removeEventListener(MouseEvent.MOUSE_OVER, listener);
        removeEventListener(MouseEvent.ROLL_OVER, listener);
        removeEventListener(MouseEvent.ROLL_OUT, listener);
        removeEventListener(MouseEvent.CLICK, listener);
        removeEventListener(MouseEvent.DOUBLE_CLICK, listener);
        removeEventListener(MouseEvent.MOUSE_DOWN, listener);
        removeEventListener(MouseEvent.MOUSE_UP, listener);
    }

    // Listener

    private function onMouseEvent(event:MouseEvent):Void
    {
        if(!enabled){
            event.stopImmediatePropagation();
            return;
        }

        switch (event.type) {
            case MouseEvent.MOUSE_OUT: onMouseOut(event);
            case MouseEvent.MOUSE_OVER: onMouseOver(event);
            case MouseEvent.ROLL_OVER: onOver(event);
            case MouseEvent.ROLL_OUT: onOut(event);
            case MouseEvent.CLICK: onClick(event);
            case MouseEvent.MOUSE_DOWN: onClickDown(event);
            case MouseEvent.MOUSE_UP: onClickUp(event);
            case MouseEvent.DOUBLE_CLICK: onDblClick(event);
        }
    }
}

enum ButtonState {
    UP;
    DOWN;
    OVER;
}