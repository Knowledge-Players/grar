package com.knowledgeplayers.grar.display.component;

import flash.geom.Matrix;
import Std;
import flash.display.Bitmap;
import flash.display.BitmapData;
import haxe.xml.Fast;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.structure.part.dialog.Character;

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

        /*
            if(xml.has.filters){
            trace('jai des filtres');
            var transBMD:BitmapData = new BitmapData(Std.int(this.width),Std.int(this.height),true, 0x00ffffff); //Note the first two 0's mean the alpha level is 0
            var trans:Matrix = new Matrix(); //a transform matrix
            trans.scale(this.scaleX, this.scaleY); //scale the image
            transBMD.draw(this,trans); //draw original image but scale it
            var img:Bitmap = new Bitmap(transBMD);
            img.smoothing = true;

            addChild(img);
            trueLayer.removeAllChildren()

        }
         */

	}

}