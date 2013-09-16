package com.knowledgeplayers.grar.structure;

import haxe.xml.Fast;

/**
* A token that can be earn during parts or activities and store into the inventory
**/
class Token {
	/**
    * Reference to the display
    **/
	public var ref:String;

	/**
    * Type of the token
    **/
	public var type:String;

	/**
    * State of activation
    **/
	public var isActivated (default, default):Bool = false;

	/**
    * Key to the name of this token
    **/
	public var name (default, default):String;

	/**
    * Content of this token
    **/
	public var content (default, default):String;

	/**
    * Content of this token when it's fullscreen
    **/
	public var fullScreenContent (default, default):String;

	/**
    * Constructor
    * @param    fast : Xml descriptor of the token
    **/

	public function new(?_fast:Fast):Void
	{
		if(_fast != null){
			ref = _fast.att.ref;
			type = _fast.has.type ? _fast.att.type : null;
			name = _fast.att.name;
			content = _fast.att.content;
			fullScreenContent = _fast.has.fullScreenContent ? _fast.att.fullScreenContent : null;
		}
	}

}