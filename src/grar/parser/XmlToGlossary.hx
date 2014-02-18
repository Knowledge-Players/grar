package grar.parser;

import grar.model.contextual.Glossary;

import haxe.xml.Fast;
import haxe.ds.StringMap;

class XmlToGlossary {
	
	static public function parse(xml : Xml) : Glossary {

		var f : Fast = new Fast(xml).node.Glossary;

		var definitions : StringMap<String> = new StringMap();

		for (def in f.nodes.Definition) {

			definitions.set(def.att.word, def.innerData);
		}

		return new Glossary(definitions);
	}
}