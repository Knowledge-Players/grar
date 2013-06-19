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

class CharacterDisplay extends Widget {
	/**
     * Starting point of the character
     */
	//public var origin:{pos:Point, scale:Float};

	/**
    * Model of the character
    **/
	public var model:Character;

	/**
	* Reference to the panel where to display its name
	**/
	public var nameRef (default, default):String;

	private var layer:TileLayer;
	private var img:TileSprite;

	public function new(?xml: Fast, spritesheet:TilesheetEx, tileId:String, ?model:Character, ?mirror:String)
	{
		super(xml);
		this.model = model;

		if(spritesheet == null)
			throw "[CharacterDisplay] Spritesheet is null for character \"" + model.getName() + "\".";

		layer = new TileLayer(spritesheet);
		img = new TileSprite(layer, tileId);
		if(mirror != null){
			img.mirror = switch(mirror.toLowerCase()){
				case "horizontal" : 1;
				case "vertical" : 2;
				case _ : throw '[CharacterDisplay] Unsupported mirror $mirror';
			}
		}
		layer.addChild(img);
		addChild(layer.view);
		layer.render();
	}

	override public function set_scale(scale:Float):Float
	{
		this.scale = img.scale = scale;
		layer.render();
		return scale;
	}

}