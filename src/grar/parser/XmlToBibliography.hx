package grar.parser;

import grar.model.contextual.Bibliography;

import haxe.xml.Fast;

class XmlToBibliography {

	static public function parse(xml : Xml) : Bibliography {

		var f : Fast = new Fast(xml).node.Bibliography;

		var entries : Array<Entry> = new Array();

		for (def in f.nodes.Entry) {

			var themes : List<String> = new List();
			var programs : List<String> = new List();

			for (theme in def.nodes.Theme) {

				themes.add(theme.innerData);
			}
			for (program in def.nodes.Program) {

				programs.add(program.innerData);
			}
			var entry : Entry = { title: "", author: "", editor: "", year: 0, programs: null, themes: null, link: "", sumup: "" };
			entry.title = def.node.Title.innerData;
			entry.author = def.node.Author.innerData;
			entry.editor = def.node.Editor.innerData;
			entry.year = Std.parseInt(def.node.Year.innerData);
			entry.programs = programs;
			entry.themes = themes;

			if (def.hasNode.Link) {

				entry.link = def.node.Link.innerData;
			}
			if (def.hasNode.SumUp) {

				entry.sumup = def.node.SumUp.innerData;
			}
			entries.push(entry);
		}

		return new Bibliography( entries );
	}
}