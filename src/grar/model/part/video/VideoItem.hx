package grar.model.part.video;

import grar.model.part.Item;

class VideoItem extends Item {

	public function new( id : ItemData, as : Bool, af : Bool, l : Bool, dv : Float, c : Float, t : Null<String> ) {

		super(id);

		this.autoStart = as;
		this.autoFullscreen = af;
		this.loop = l;
		this.defaultVolume = dv;
		this.capture = c;
		this.thumbnail = t;
	}

	/**
	 * Autostart the video
	 **/
	public var autoStart (default, default) : Bool;

    /**
	 * Autofullscreen the video
	 **/
	public var autoFullscreen (default, default) : Bool;

	/**
	 * Loop the video
	 **/
	public var loop (default, default) : Bool;

	/**
	 * Default volume. 0 = mute, 1 = max volume
	 **/
	public var defaultVolume (default, default) : Float;

	/**
	 * Time to capture an image
	 **/
	public var capture (default, default) : Float;
	
	/**
	 * Thumbnail
	 **/
	public var thumbnail (default, default) : String;

	override public function isVideo():Bool
	{
		return true;
	}
}