package grar.view.component;

import aze.display.TileLayer;
import aze.display.TilesheetEx;

import grar.view.component.TileImage;

typedef CharacterData = {

	var tid : TileImageData;
	var charRef : String;
	var nameRef : Null<String>;
}

/**
 * Graphic representation of a character of the game
 */
class CharacterDisplay extends TileImage {

	//public function new(?xml: Fast, layer:TileLayer, ?model:Character) {
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : TilesheetEx, cd : CharacterData, layer : TileLayer) {

		super(callbacks, applicationTilesheet, cd.tid, layer, false);

		this.charRef = cd.charRef;
		
		if (cd.nameRef != null) {

			this.nameRef = cd.nameRef;
		}
	}

	/**
     * Ref to the character
     **/
	public var charRef (default, default) : String;

	/**
	 * Reference to the panel where to display its name
	 **/
	public var nameRef (default, default) : String;


	///
	// API
	//

	public function getName() : String { // TODO invert calls (replace by a setName function)

		return onLocalizedContentRequest(charRef.split("_")[0]);
	}
}

/* Previously, we had also:

import com.knowledgeplayers.grar.localisation.Localiser;

class Character {

	public var ref (default, default):String;

	public function new(?ref:String)
	{
		this.ref = ref;
	}

	public function getName():String
	{
		return Localiser.instance.getItemContent(ref.split("_")[0]);
	}
}
*/