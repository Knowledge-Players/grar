package com.knowledgeplayers.grar.display.component;

import haxe.xml.Fast;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import nme.display.Sprite;
import nme.events.Event;
import nme.geom.Point;

/**
 * Graphic representation of a character of the game
 */

class CharacterDisplay extends TileImage {

	/**
    * Model of the character
    **/
	public var model:Character;

	/**
	* Reference to the panel where to display its name
	**/
	public var nameRef (default, default):String;

	public function new(?xml: Fast, layer:TileLayer, ?model:Character)
	{
		xml.x.remove("spritesheet");
		super(xml, layer, false);
		this.model = model;
	}

}