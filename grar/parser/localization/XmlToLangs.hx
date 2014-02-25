package grar.parser.localization;

import grar.model.localization.Locale;

import haxe.ds.StringMap;
import haxe.xml.Fast;

class XmlToLangs {

	static public function parse( xml : Xml ) : StringMap<Locale> {

		var f : Fast = new Fast(xml);

		var l : StringMap<Locale> = new StringMap();

		for (lang in f.node.Langs.nodes.Lang) {

            l.set( lang.att.value, { path: lang.att.folder, pic: lang.att.pic } );
        }
        return l;
	}
}