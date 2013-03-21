package com.knowledgeplayers.grar.display.element;

import aze.display.SparrowTilesheet;
import aze.display.TileLayer;
import aze.display.TileSprite;
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
    public var origin:Point;

    /**
    * Scale of the character
    **/
    public var scale (default, setScale):Float;

    /**
    * Model of the character
    **/
    public var model:Character;

    private var layer:TileLayer;
    private var img:TileSprite;

    public function new(spritesheet:SparrowTilesheet, tileId:String, ?model:Character)
    {
        super();
        this.model = model;

        layer = new TileLayer(spritesheet);
        img = new TileSprite(tileId);
        layer.addChild(img);
        addChild(layer.view);
        layer.render();
    }

    public function setScale(scale:Float):Float
    {
        img.scale = scale;
        layer.render();
        return scale;
    }

}