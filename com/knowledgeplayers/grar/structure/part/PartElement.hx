package com.knowledgeplayers.grar.structure.part;

interface PartElement extends Identifiable{
	/**
	* Token contains into the part element
	**/
	public var token (default, null):String;
	/**
	* This element is an endScreen ?
	**/
	public var endScreen (default, null):Bool;

	/**
	* Reference to the display of this element
	**/
	public var ref (default, default):String;

	/**
	* This element is a text ?
	**/
	public function isText():Bool;

	/**
	* This element is a pattern ?
	**/
	public function isPattern():Bool;

	/**
	* This element is a part ?
	**/
	public function isPart():Bool;

	/**
	* This element is a video ?
	**/
	public function isVideo():Bool;

    public function isSound():Bool;
}
