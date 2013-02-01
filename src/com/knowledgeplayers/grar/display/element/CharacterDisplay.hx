package com.knowledgeplayers.grar.display.element;

import nme.display.Bitmap;
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

    public var image (default, setImage): Bitmap;

    public function new(image: Bitmap, ?model: Character)
    {
        super();
        this.model = model;
        this.image = image;
    }

    public function setImage(image: Bitmap): Bitmap
    {
        if(this.image != null)
            removeChild(this.image);
        addChild(image);
        return this.image = image;
    }

}