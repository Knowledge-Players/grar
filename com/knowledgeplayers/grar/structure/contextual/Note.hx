package com.knowledgeplayers.grar.structure.contextual;

import haxe.xml.Fast;
import com.knowledgeplayers.grar.structure.Token;

class Note extends Token {

	/**
	* URL of the video contained in this note
	**/
	public var video (default, default):String;

	public function new(?note: Fast)
	{
		super(note);
		type = "note";
		if(note != null){
			video = note.has.video ? note.att.video : null;
		}
	}
}