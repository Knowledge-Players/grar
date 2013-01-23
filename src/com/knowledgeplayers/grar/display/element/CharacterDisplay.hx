package com.knowledgeplayers.grar.display.element;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import nme.display.Sprite;
import nme.geom.Point;

/**
 * Graphic representation of a character of the game
 */

class CharacterDisplay extends Sprite {
    /**
     * Starting point of the character
     */
    public var origin: Point;

    /**
    * Model of the character
    **/
    public var model: Character;

    public function new(?model: Character)
    {
        super();
        this.model = model;
    }

}