package com.knowledgeplayers.grar.display;

import nme.display.Stage;
import com.knowledgeplayers.grar.display.layout.Layout;
import haxe.xml.Fast;
import nme.Lib;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.display.Sprite;


class LayoutDisplay extends Sprite {

    private var layouts: Hash<Layout>;
    private var gameD:GameDisplay;

/**
* Layout Display
**/

    public function new():Void {

    super();
    Lib.trace("LayoutDisplay");
    layouts = new Hash<Layout>();
}
    /**
    * Parsing du Xml
    **/
    public function parseXml(xml:Xml):Void{


        var fastXml =new Fast(xml);
        var layoutNode: Fast = fastXml.node.Layouts;
        for (lay in layoutNode.elements)
            {

                var layout:Layout = new Layout(lay);

                layouts.set(lay.att.ref,layout);
            }

    }
    /**
    * Initialisation des éléments
    **/
    public function init(gameD:GameDisplay):Void
    {
        Lib.trace("init"+layouts);
        this.gameD = gameD;
        displayLayout("default");
    }


    /**
    * Affichage des éléments
    **/

    public function displayLayout(_ref:String):Void{

        Lib.trace(Lib.current.stageWidth);
        Lib.trace(Lib.current.stageHeight);
        var sizeTotal = 0;
        for( row in layouts.get(_ref).rows){

            Lib.trace("row size : "+row.size);
            var rowContainer = new Sprite();

            if (row.size !="*")
                {
                    rowContainer.height= Std.parseFloat(row.size);
                    sizeTotal += Std.int(rowContainer.height);
                }

            else
            rowContainer.height = sizeTotal;

            rowContainer.width = Lib.current.stageWidth;

            for( column in row.columns)
                {
                    var columnContainer = new Sprite();
                    if(column.size !="*")
                        {
                            var percent = column.size;
                            //columnContainer.width =

                        }

                }



        }
    }


}
