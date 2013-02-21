package com.knowledgeplayers.grar.display.layout;
import nme.Lib;
import haxe.xml.Fast;
class Layout {

    public var rows:Array<Row>;
    public var ref:String;

    public function new(_fast:Fast):Void {

        rows = new Array<Row>();

        for (_row in _fast.elements){

            initRow(_row);
        }
        if(_fast.has.rows){



            var rowsSize = Std.string(_fast.att.rows);
            var nbRows = rowsSize.split(",").length;
            for(i in 0...nbRows){
                var size = rowsSize.split(",")[i];
                rows[i].size = size;

            }


        }
        else
        {
            rows[0].size = "*";
        }

        if(_fast.has.ref)
           ref = _fast.att.ref;


    }

    private function initRow(_row:Fast):Void{

        var row = new Row(_row);
        rows.push(row);
    }


}
