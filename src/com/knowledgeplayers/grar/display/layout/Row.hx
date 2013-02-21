package com.knowledgeplayers.grar.display.layout;

import haxe.xml.Fast;

class Row {
    public var columns:Array<Column>;
    public var size:String;

    public function new(_row:Fast):Void {

        columns = new Array<Column>();

        for (_column in _row.elements){

            initColumn(_column);
        }
        if(_row.has.columns){



            var columnsSize = Std.string(_row.att.columns);

            var nbColumns = columnsSize.split(",").length;
            for(i in 0...nbColumns){
                var size = columnsSize.split(",")[i];
                columns[i].size = size;
            }
        }
        else
        {
            columns[0].size = "100%";
        }




    }

    private function initColumn(_column:Fast):Void{

        var column = new Column(_column);
        columns.push(column);
    }


}
