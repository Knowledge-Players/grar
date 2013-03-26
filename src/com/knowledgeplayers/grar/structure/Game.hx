package com.knowledgeplayers.grar.structure;

import com.knowledgeplayers.grar.structure.activity.Activity;
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

    public function start(partId:Int = 0):Null<Part>;

    public function init(xml:Xml):Void;

    public function addPart(partIndex:Int, part:Part):Void;

    public function getAllParts():Array<Part>;

    public function getAllActivities():Array<Activity>;

    public function addLanguage(value:String, path:String, flagIconPath:String):Void;

    public function initTracking(?mode:Mode):Void;

    public function getLoadingCompletion():Float;

    public function toString():String;
}
