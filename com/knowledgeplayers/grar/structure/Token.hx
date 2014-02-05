package com.knowledgeplayers.grar.structure;

import haxe.xml.Fast;

/**
* A token that can be earn during parts or activities and store into the inventory
**/
class Token {
	/**
    * Unique identifier
    **/
	public var id:String;
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
	public var isActivated (default, default):Bool;

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
    * icon of this token
    **/
	public var icon (default, default):String;

	/**
    * Image to display when it's fullscreen
    **/
	public var image (default, default):String;

	/**
    * Constructor
    * @param    fast : Xml descriptor of the token
    **/
	public function new(?_fast:Fast):Void
	{
		if(_fast != null){
			id = _fast.att.id;
			ref = _fast.att.ref;
			type = _fast.has.type ? _fast.att.type : null;
			name = _fast.has.name ?_fast.att.name : null;
			content = _fast.att.content;
			icon = _fast.has.icon ? _fast.att.icon : null;
			image = _fast.has.src ? _fast.att.src : null;
			fullScreenContent = _fast.has.fullScreenContent ? _fast.att.fullScreenContent : null;
			isActivated = _fast.has.unlocked ? _fast.att.unlocked == "true" : false;
		}
		else{
			ref="undefined";
			isActivated = false;
		}
	}

}