package com.knowledgeplayers.grar.structure;

import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.tracking.Connection.Mode;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.events.IEventDispatcher;

interface Game implements IEventDispatcher {
	public var mode (default, default):Mode;
	public var title (default, default):String;
	public var state (default, default):String;
	public var inventory (default, null):Array<Token>;
	public var uiLoaded (default, default):Bool;
	public var ref (default, default):String;
	public var menu (default, default):Xml;

	public function start(?partId:String):Null<Part>;

	public function init(xml:Xml):Void;

	public function addPart(partId:String, part:Part):Void;

	public function getAllParts():Array<Part>;

	public function getAllItems():Array<PartElement>;

	public function addLanguage(value:String, path:String, flagIconPath:String):Void;

	public function initTracking(?mode:Mode):Void;

	public function getLoadingCompletion():Float;

	public function toString():String;

	public function getItemName(id:String):Null<String>;
}
