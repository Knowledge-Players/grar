package grar.model.part;

import grar.model.part.Item;

import haxe.ds.StringMap;

class TextItem extends Item {

	public function new( id : ItemData, a : String, t : String, s : String, is : {ref:String,content:StringMap<String>} ) {

		super(id);

		this.author = a;
		this.transition = t;
		this.sound = s;
		this.introScreen = is;
	}

	/**
     * Character who says this text
     */
	public var author (default, default) : String;

	/**
     * Transition between this item and the one before
     */
	public var transition (default, default) : String;

	/**
     * Sound to play during this item
     **/
	public var sound (default, default) : String;

	/**
	 * Introduction screen to show before this item
	 **/
	public var introScreen (default, default) : {ref:String, content:StringMap<String>};

	override public function isText():Bool
	{
		return true;
	}
}