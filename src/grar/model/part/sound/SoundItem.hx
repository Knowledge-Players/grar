package grar.model.part;

import grar.model.part.Item;

class SoundItem extends Item {

	public function new( id : ItemData, as : Bool, l : Bool, dv : Float ) {

		super(id);

		this.autoStart = as;
		this.loop = l;
		this.defaultVolume = dv;
	}

	/**
	 * Autostart the sound
	 **/
    public var autoStart (default, default) : Bool;

	/**
	 * Loop the sound
	 **/
    public var loop (default, default) : Bool;

	/**
	 * Default volume. 0 = mute, 1 = max volume
	 **/
    public var defaultVolume (default, default) : Float;

    override public function isSound():Bool
    {
        return true;
    }
}