package com.knowledgeplayers.grar.structure.part;

interface PartElement {
    public var token (default, null):String;

    public function isActivity():Bool;

    public function isText():Bool;

    public function isPattern():Bool;

    public function isPart():Bool;
}
