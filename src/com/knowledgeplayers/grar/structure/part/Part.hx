package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import haxe.xml.Fast;
import nme.events.IEventDispatcher;
import nme.media.Sound;

interface Part implements IEventDispatcher {
    public var name (default, default): String;
    public var id (default, default): Int;
    public var file (default, null): String;
    public var display (default, default): String;
    public var isDone (default, default): Bool;

    public var characters (default, null): Hash<Character>;
    public var options (default, null): Hash<String>;
    public var activities (default, null): IntHash<Activity>;
    public var parts (default, null): IntHash<Part>;
    public var items (default, null): Array<Item>;
    public var inventory (default, null): Array<String>;
    public var soundLoop (default, default): Sound;

    public function init(xml: Fast, filePath: String = ""): Void;

    public function start(forced: Bool = false): Null<Part>;

    public function next(): Null<Part>;

    public function getNextItem(): Null<Item>;

    public function getAllParts(): Array<Part>;

    public function hasParts(): Bool;

    public function partsCount(): Int;

    public function activitiesCount(): Int;

    public function toString(): String;

    public function isDialog(): Bool;
}