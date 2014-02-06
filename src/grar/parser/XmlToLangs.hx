package grar.parser;

import grar.model.LangsList;

class XmlToLangs {

	static public function parse( xml : Xml ) : List<{ k:String, l:String, p:String }> {

		var f : Fast = new Fast(xml);

		var l : List<{ k:String, l:String, p:String }> = new List();

		for (lang in f.node.Langs.nodes.Lang) {

            l.add({k: lang.att.value, l: lang.att.folder, p: lang.att.pic});
        }
        return l;
	}
}