package grar.parser;

import grar.model.Grar;
import grar.model.tracking.TrackingMode;

import haxe.xml.Fast;

class XmlToGrar {

    static public function parse( xml : Xml ) : Grar {

        var m : TrackingMode;
        var s : { value : String, tracking : String };
        var id : String;

        var sFast : Fast = new Fast(xml);
        var parametersNode : Fast = sFast.node.Grar.node.Parameters;

        try {

            m = Type.createEnum(TrackingMode, parametersNode.node.Mode.innerData);
        
        } catch (e:String) {

            m = AUTO;
            trace("Couldn't convert '"+parametersNode.node.Mode.innerData+"' to TrackingMode: "+e);
        }
        s = { value: parametersNode.node.State.innerData, tracking: parametersNode.node.State.has.tracking ? parametersNode.node.State.att.tracking : "off" };
        id = parametersNode.node.Id.innerData;

        var layout : String = parametersNode.node.Layout.att.file;
        var langs : String = parametersNode.node.Languages.att.file;
        var displayNode : Fast = sFast.node.Grar.node.Display;
        var structureNode : Fast = sFast.node.Grar.node.Structure;

        var ref : String = structureNode.att.ref;

        return new Grar(m, id, s, ref, Loading(langs, layout, displayNode, structureNode));
    }
}