package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.grar.display.layout.Layout;
import haxe.xml.Fast;
import nme.Lib;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.display.Sprite;


class LayoutDisplay extends Sprite {

    private var layouts: Hash<Layout>;

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
    public function init():Void
    {
        Lib.trace("init"+layouts);
    }


/**
* Affichage des éléments
**/


}
