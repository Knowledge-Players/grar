package com.knowledgeplayers.grar.display.component.button;
import com.knowledgeplayers.grar.display.element.AnimationDisplay;
import nme.Lib;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import nme.events.MouseEvent;

/**
 * Button with a customizable event
 * @author jbrichardet
 */

class CustomEventButton extends DefaultButton {
    /**
     * Type of the event to dispatch
     */
    public var eventType (default, default):String;

    /**
     * Control whether or not the native event (CLICK) must be propagated
     */
    public var propagateNativeEvent (default, default):Bool = false;

    public var activToggle:Bool =false;

    private var toggle:Bool = true;

    /**
     * Constructor
     * @param	eventName : Name of the customed event to dispatch
     * @param	tilesheet : UI sheet
     * @param	tile : Tile containing the button
     */

    private var animations:Hash<AnimationDisplay>;
    private var animEnCours:AnimationDisplay;

    public function new(tilesheet:TilesheetEx, tile:String, eventName:String,?_animations:Hash<AnimationDisplay>)
    {
        super(tilesheet, tile);
        this.eventType = eventName.toLowerCase();
        animations = _animations;
        animEnCours =null;

        if(animations != null)setAnimations(animations);
    }

    private function setAnimations(_animations:Hash<AnimationDisplay>):Void{

        for(key in _animations.keys()){

            var anim:AnimationDisplay = cast(_animations.get(key),AnimationDisplay);
            if(key != "over")
            {
                addChild(anim);
                animElement(key);
            }
        }
    }

    override private function onOver(event:MouseEvent):Void{

            if(!activToggle){
                super.clipOver();
                if(animations!=null)animElement("over");
            }
    }
    override private function onOut(event:MouseEvent):Void{

            if(!activToggle){
                super.clipOut();
                if(animations!=null)animElement("out");
            }
    }

    override private function onClick(event:MouseEvent):Void
    {
        //if(animEnCours != null)removeChild(animEnCours);

        if(activToggle) changeToggle();
        if(!propagateNativeEvent)
            event.stopImmediatePropagation();

        var e = new ButtonActionEvent(eventType);
        dispatchEvent(e);
    }

    private function changeToggle():Void{
            if(toggle){
                super.clipOver();
                toggle = false;
            }else
            {
                super.clipOut();
                toggle = true;
            }
    }

    private function animElement(_type:String):Void{

        if(animations != null){
            if(animEnCours != null)removeChild(animEnCours);

            var anim:AnimationDisplay = cast(animations.get(_type),AnimationDisplay);
            animEnCours = anim;
            addChild(anim);
            anim.animElement();
        }


    }
}