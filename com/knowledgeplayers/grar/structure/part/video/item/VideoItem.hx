package com.knowledgeplayers.grar.structure.part.video.item;

import haxe.xml.Fast;

class VideoItem extends Item {
	/**
	* Autostart the video
	**/
	public var autoStart (default, default):Bool;

	/**
	* Loop the video
	**/
	public var loop (default, default):Bool;

	/**
	* Default volume. 0 = mute, 1 = max volume
	**/
	public var defaultVolume (default, default):Float;

	/**
	* Time to capture an image
	**/
	public var capture (default, default):Float;

	/**
     * Constructor
     * @param	xml : fast xml node with structure info
     * @param	source : URL of the video
     */
	public function new(?xml:Fast, content:String = "", autoStart: Bool = false, loop: Bool = false, defaultVolume: Float = 1, capture: Float = 0)
	{
		super(xml, content);
		if(xml != null){
			this.autoStart = xml.has.autostart ? xml.att.autostart == "true" : false;
			this.loop = xml.has.loop ? xml.att.loop == "true" : false;
			this.defaultVolume = xml.has.volume ? Std.parseFloat(xml.att.volume) : 1;
			this.capture = xml.has.capture ? Std.parseFloat(xml.att.capture) : 0;
		}
		else{
			this.autoStart = autoStart;
			this.loop = loop;
			this.defaultVolume = defaultVolume;
			this.capture = capture;
		}
	}

	override public function isVideo():Bool
	{
		return true;
	}
}
