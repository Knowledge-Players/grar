package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.tracking.Trackable;
import haxe.FastList;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.grar.structure.part.TextItem;
import haxe.xml.Fast;
import nme.events.IEventDispatcher;
import nme.media.Sound;

interface Part implements IEventDispatcher, implements PartElement, implements Trackable {
	public var file (default, null):String;
	public var display (default, default):String;
	public var isDone (default, default):Bool;
	public var parent (default, default):Part;

	public var button (default, default):{ref:String, content:Hash<String>};
	public var elements (default, null):Array<PartElement>;
	public var token (default, null):String;
	public var tokens (default, null):FastList<String>;
	public var soundLoop (default, default):Sound;

	public function init(xml:Fast, filePath:String = ""):Void;

	public function start():Null<Part>;

	public function end():Void;

	public function restart():Void;

	public function getNextElement(startIndex:Int = -1):Null<PartElement>;

	public function getElementIndex(element:PartElement):Int;

	public function getAllParts():Array<Part>;

	public function getAllItems():Array<Trackable>;

	public function hasParts():Bool;

	public function toString():String;

	public function isDialog():Bool;

	public function isStrip():Bool;

	public function isActivity():Bool;

	public function isText():Bool;

	public function isPattern():Bool;

	public function isPart():Bool;

	public function getItemName(id:String):Null<String>;
}