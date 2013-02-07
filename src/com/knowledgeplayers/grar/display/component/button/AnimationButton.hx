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
    public var iconGroup: TileGroup;

    /**
     * Tile for the background
     */
    public var fondIcon: TileSprite;

    /**
     * Tile for the animation
     */
    public var arrowIcon: TileClip;

    /**
     * Constructor
     * @param	tilesheet : UI sheet
     * @param	tile : Tile containing the button
     * @param	eventName : Custom event to dispatch
     */

    public function new(tilesheet: TilesheetEx, tile: String, ?eventName: String)
    {
        if(eventName == null){
            this.eventType = "next";
            propagateNativeEvent = true;
        }
        else
            this.eventType = eventName;

        super(eventType, tilesheet, tile);
        addIcon();
    }

    // P¨rivates

    private function addIcon(): Void
    {
        this.iconGroup = new TileGroup();
        this.fondIcon = new TileSprite("btCircle");
        this.arrowIcon = new TileClip("fleche_mc");
        iconGroup.addChild(this.fondIcon);
        iconGroup.addChild(this.arrowIcon);
        layer.addChild(iconGroup);
        iconGroup.x = 100;

        layer.render();
    }

    override private function onOver(event: MouseEvent): Void
    {
        super.onOver(event);
        startAnimIcon();
    }

    override private function onOut(event: MouseEvent): Void
    {
        super.onOut(event);
        endAnimIcon();
    }

    private function animRender(e: Event = null): Void
    {
        layer.render();
    }

    private function endAnimIcon(): Void
    {
        this.removeEventListener(Event.ENTER_FRAME, animRender);
        arrowIcon.currentFrame = 0;
        layer.render();
    }

    private function startAnimIcon(): Void
    {
        this.addEventListener(Event.ENTER_FRAME, animRender);
    }

}