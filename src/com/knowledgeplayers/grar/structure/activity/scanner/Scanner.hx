package com.knowledgeplayers.grar.structure.activity.scanner;

import nme.Lib;
import haxe.PosInfos;
import haxe.xml.Fast;
import nme.events.Event;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.geom.Point;
import haxe.FastList;
class Scanner extends Activity {
    public var pointsMap (default, null): FastList<ScannerPoint>;
    public var pointVisible (default, default): Bool;

    public function new(content: String)
    {
        super(content);
        pointsMap = new FastList<ScannerPoint>();

        XmlLoader.load(content, onLoadComplete, parseContent);
    }

    public override function toString(): String
    {
        return pointsMap.toString();
    }

    // Private

    override private function parseContent(content: Xml): Void
    {
        var fast = new Fast(content).node.Scanner;
        pointVisible = fast.att.PointVisible == "true";
        for(point in fast.nodes.Point){
            pointsMap.add(new ScannerPoint(Std.parseFloat(point.att.X), Std.parseFloat(point.att.Y), point.att.Content));
        }
    }
}
