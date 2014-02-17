package grar.parser;

import haxe.xml.Fast;

import grar.model.Grar;

class XmlToGrar {

    static public function parse( xml : Xml ) : Grar {

        var m : TrackingMode;
        var s : String;
        var id : String;

        var sFast : Fast = new Fast(xml);
        var parametersNode : Fast = sFast.node.Grar.node.Parameters;

        m = Type.createEnum(TrackingMode, parametersNode.node.Mode.innerData);
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