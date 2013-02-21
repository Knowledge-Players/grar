package com.knowledgeplayers.grar.display.element;

import aze.display.TileSprite;
import aze.display.SparrowTilesheet;
import aze.display.TileLayer;
import nme.events.Event;
import com.knowledgeplayers.grar.util.SpriteSheetLoader;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import nme.display.Sprite;
import nme.geom.Point;
import nme.Lib;
import aze.display.TilesheetEx;

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

    private var tileId: String;

    public function new(spritesheet: SparrowTilesheet, tileId: String, ?model: Character)
    {
        super();
        this.model = model;
        this.tileId = tileId;

        var layer = new TileLayer(spritesheet);
        var img = new TileSprite(tileId);
        layer.addChild(img);
        addChild(layer.view);
        layer.render();
    }
}