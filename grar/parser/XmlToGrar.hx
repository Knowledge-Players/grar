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
	    var kalturaParams: KalturaSettings = null;
	    if(parametersNode.hasNode.Kaltura){
	        var kNode = parametersNode.node.Kaltura;
		    var pId = Std.parseInt(kNode.att.partnerId);
		    var secret = kNode.att.secret;
		    kalturaParams = {partnerId: pId, secret: secret};
            kalturaParams.serviceUrl = kNode.has.serviceUrl ? kNode.att.serviceUrl : null;
	    }

        var langs : String = parametersNode.node.Languages.att.file;
        var structureNode : Fast = sFast.node.Grar.node.Structure;

        return new Grar(m, id, kalturaParams, s, Loading(langs, structureNode));
    }
}