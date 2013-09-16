package com.knowledgeplayers.grar.structure.contextual;

import haxe.xml.Fast;
import com.knowledgeplayers.grar.structure.Token;

class Note extends Token {
	/**
	* Subtitle of the note
	**/
	public var subtitle (default, default):String;
	/**
	* Icon of the note
	**/
	public var icon (default, default):String;

	public function new(?note: Fast)
	{
		super(note);
		type = "note";
		if(note != null){
			subtitle = note.has.subtitle ? note.att.subtitle : null;
			icon = note.has.icon ? note.att.icon : null;
		}
	}
}