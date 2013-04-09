package com.knowledgeplayers.grar.display.component.button;

import aze.display.TileClip;
import aze.display.TileGroup;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import nme.events.Event;
import nme.events.MouseEvent;

/**
 * Button with an animation
 */
class AnimationButton extends CustomEventButton {
    /**
     * TileGroup for the button
     */
    public var iconGroup:TileGroup;

    /**
     * Tile for the background
     */
    public var fondIcon:TileSprite;

    /**
     * Tile for the animation
     */
    public var arrowIcon:TileClip;

    /**
     * Constructor
     * @param	tilesheet : UI sheet
     * @param	tile : Tile containing the button
     * @param	eventName : Custom event to dispatch
     */

    public function new(tilesheet:TilesheetEx, tile:String, ?eventName:String)
    {
        super(tilesheet, tile, (eventName == null ? "next" : eventName));

        if(eventName == null)
            propagateNativeEvent = true;
    }



    override private function onOver(event:MouseEvent):Void
    {
        super.onOver(event);

    }

    override private function onOut(event:MouseEvent):Void
    {
        super.onOut(event);

    }

    private function animRender(e:Event = null):Void
    {
        layer.render();
    }

}