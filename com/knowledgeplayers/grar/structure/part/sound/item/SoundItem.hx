package com.knowledgeplayers.grar.structure.part.sound.item;

import haxe.xml.Fast;

class SoundItem extends Item {
/**
	* Autostart the sound
	**/
    public var autoStart (default, default):Bool;


/**
	* Loop the sound
	**/
    public var loop (default, default):Bool;

/**
	* Default volume. 0 = mute, 1 = max volume
	**/
    public var defaultVolume (default, default):Float;
/**
     * Constructor
     * @param	xml : fast xml node with structure info
     * @param	source : URL of the sound
     */
    public function new(?xml:Fast, content:String = "", autoStart: Bool = false, loop: Bool = false, defaultVolume: Float = 1)
    {
        super(xml, content);
        if(xml != null){
            this.autoStart = xml.has.autostart ? xml.att.autostart == "true" : false;

            this.loop = xml.has.loop ? xml.att.loop == "true" : false;
            this.defaultVolume = xml.has.volume ? Std.parseFloat(xml.att.volume) : 1;

        }
        else{
            this.autoStart = autoStart;
            this.loop = loop;
            this.defaultVolume = defaultVolume;

        }
    }

    override public function isSound():Bool
    {
        return true;
    }
}
