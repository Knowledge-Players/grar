package com.knowledgeplayers.grar.structure.activity.scanner;

import nme.geom.Point;
class ScannerPoint extends Point {

    public var content (default, default): String;

    public function new(x: Float, y: Float, ?content: String)
    {
        super(x, y);
        this.content = content;
    }
}
