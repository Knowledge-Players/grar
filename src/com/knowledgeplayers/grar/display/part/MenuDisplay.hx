package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * Display of a menu
 */

class MenuDisplay extends Sprite {
    private var parts: Array<Part>;

    /**
     * Constructor
     * @param	game : Game model linked to the menu
     */

    public function new(game: Game)
    {
        super();
        addChild(KpTextDownParser.parse("Bienvenue dans le menu"));
        var yOffset: Float = getChildAt(0).height;
        parts = game.getAllParts();
        for(part in parts){
            var sprite = KpTextDownParser.parse(part.name);
            sprite.name = part.name;
            sprite.y = yOffset;
            yOffset += sprite.height;
            sprite.addEventListener(MouseEvent.CLICK, onPartClick);
            var status = KpTextDownParser.parse(": " + (part.isDone ? "fini" : "pas fini"));//UiFactory.createButton("Text", "continueButton");
            //status.addEventListener(MouseEvent.CLICK, onPartClick);
            status.x = sprite.width;
            sprite.addChild(status);
            sprite.buttonMode = true;
            sprite.graphics.beginFill(0, 0.01);
            sprite.graphics.drawRect(0, 0, sprite.width, sprite.height);
            sprite.graphics.endFill();
            sprite.mouseChildren = false;
            addChild(sprite);
        }
    }

    /**
     * Abstract function which launch the given part
     * @param	part : Part to start
     */

    dynamic public function launchPart(part: Part)
    {}

    // Private

    private function onPartClick(e: MouseEvent): Void
    {
        var target = cast(e.target, Sprite);//.parent;
        for(part in parts){
            if(part.name == target.name){
                launchPart(part);
                break;
            }
        }
    }

}