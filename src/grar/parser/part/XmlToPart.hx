package grar.parser.part;

import grar.model.part.Part;
import grar.model.part.PartElement;
import grar.model.part.ActivityPart;
import grar.model.part.dialog.DialogPart;
import grar.model.part.strip.StripPart;
import grar.model.part.Pattern;
import grar.model.part.Item;

import grar.parser.part.XmlToPattern;
import grar.parser.part.XmlToItem;

import grar.util.ParseUtils;

import haxe.xml.Fast;

enum PartType {

	Part;
	Activity;
	Dialog;
	Strip;
}

typedef PartialPart = {

	var pd : PartData;
	var type : PartType;
}

class XmlToPart {

	///
	// API
	//

	/**
	 * @param Xml describing the part
	 */
	static public function parse(xml : Xml) : PartialPart {

		var f : Fast = new Fast(xml);
		var pp : PartialPart = { };
		pp.xml = xml;

		var t : String = f.has.type ? f.att.type.toLowerCase() : "";

		switch (t) {

			case "dialog":

				pp.type = Dialog;
				pp.pd = parsePartData( xml );

			case "strip" :

				pp.type = Strip;
				pp.pd = parsePartData( xml );

			case "activity":

				pp.type = Activity;
				pp.pd = parsePartData( xml );

			case "" :

				pp.type = Part;
				pp.pd = parsePartData( xml );

			default: 

				throw "unexpected type attribute value $t";
		}

		return pp;
	}

	static public function parseContent(pp : PartialPart, xml : Xml) : { p : Part, pps : Array<PartialPart> } {

		var f : Fast = new Fast(xml);

		var p : Part;
		var pps : Array<PartialPart>;

		switch (pp.type) {

			case Dialog:

				var pd : PartData = parsePartContentData(pp.pd, xml);
				pps = pd.partialSubParts;
				p = new DialogPart(pd);

			case Strip:

				var pd : PartData = parsePartContentData(pp.pd, xml);
				pps = pd.partialSubParts;
				p = new StripPart(pd);

			case Activity:

				var apd : { pd : PartData, g : Array<Group>, r : StringMap<Rule>, gi : Int, nra : Int } = parseActivityPartContent(pp.pd, xml);
				pps = apd.pd.partialSubParts;
				p = new ActivityPart(apd.pd, apd.g, apd.r, apd.gi, apd.nra);

			case Part:

				var pd : PartData = parsePartContentData(pp.pd, xml);
				pps = pd.partialSubParts;
				p = new Part(pd);
		}

		return { p: p, pps: pps };
	}


	///
	// INTERNALS
	//

	static function parsePartContentData(pd : PartData, xml : Xml) : PartData {

		var f : Fast = (xml.nodeType == Xml.Element && xml.nodeName == "Part") ? new Fast(xml) : new Fast(xml).node.Part;

		pd = parsePartHeader(pd, f);

		for (child in f.elements) {

			pd = parsePartElement(pd, child);
		}
		for (elem in pd.elements) {

			switch (elem) {

				case Item(i):

					if (i.button == null || Lambda.empty(i.button)) {

						i.button = pd.buttons;
					}
					for (image in i.tokens) {

						pd.tokens.add(image);
					}

				case Pattern(p):

					for (item in p.patternContent) {

						for (image in item.tokens) {

							pd.tokens.add(image);
						}
					}
					for (image in p.tokens) {

						pd.tokens.add(image);
					}

				case Part(p):

					for (image in p.tokens) {

						pd.tokens.add(image);
					}
			}
		}

		return pd;
	}

	static function parsePartElement(pd : PartData, node : Fast) : PartData {

		switch (node.name.toLowerCase()) {

			case "text":

				pd.elements.push( Item(XmlToItem.parse(node.x)) );
			
			case "part":

				pd.nbSubPartTotal++;

				pd.partialSubParts.push( parse(node.x) );
			
			case "sound":

#if (flash || openfl)
				pd.soundLoopSrc = node.att.content;
#else
				pd.soundLoop = node.att.content;
#end
			case "button":

				var content = null;
				
				if (node.has.content) {

					content = ParseUtils.parseHash(node.att.content);
				}
				pd.buttons.set(node.att.ref, content);
				
				if (node.has.goTo) {

					if (node.att.goTo == "") {

						pd.buttonTargets.set(node.att.ref, null);
					
					} else {

						for (elt in pd.elements) {

							switch (elt) {

								case Item(i) if (i.isText() || i.content == node.att.goTo):

									pd.buttonTargets.set(node.att.ref, elt);

								default: // nothing
							}
						}
					}
				}
			
			case "pattern": // should happen only for DialogParts and StripParts
			
				pd.elements.push(Pattern(XmlToPattern.parse(node)));
		}

		return pd;
	}

	static function parseActivityPartContent(pd : PartData, xml : Xml) : { pd : PartData, g : Array<Group>, r : StringMap<Rule>, gi : Int, nra : Int } {

		var f : Fast = (xml.nodeType == Xml.Element && xml.nodeName == "Part") ? new Fast(xml) : new Fast(xml).node.Part;
		
		var groups : Array<Group> = new Array();
		var rules : StringMap<Rule> = new StringMap();
		var groupIndex : Int = -1;
		var numRightAnswers : Int = 0;

		for (child in f.elements) {

			switch (child.name.toLowerCase()) {

				case "group":

					var group : Group = createGroup(child);
					groups.push(group);

				case "rule" :

					var rule : Rule = { id: child.att.id, type: child.att.type.toLowerCase(), value: child.att.value.toLowerCase() };
					rules.set(rule.id, rule);
			}
		}
		// If no rules has been set on a group, all applies
		for (group in groups) {

			if (group.rules != null) {

				for (rule in rules) {

					group.rules.push(rule.id);
				}
			}
		}

		pd = parsePartContentData(pd, xml);

		return { pd: pd, g: groups, r: rules, gi: groupIndex, nra: numRightAnswers };
	}

	static function createInput(f : Fast, ? group : Group) : Input {

		var values;

		if (f.has.values) {

			values = ParseUtils.parseListOfValues(f.att.values);
		
		} else {

			values = new Array<String>();
		}
		return {id: f.att.id, ref: f.att.ref, content: ParseUtils.parseHash(f.att.content), values: values, selected: false, group: group};
	}

	static inline function createGroup(f : Fast) : Group {

		var rules : Array<String> = null;
		
		if (f.has.rules) {

			rules = ParseUtils.parseListOfValues(f.att.rules);
		}
		if (f.hasNode.Group) {

			var groups : Array<Group> = [];

			for (group in f.nodes.Group) {

				groups.push(createGroup(group));
			}
			var group : Group = {id: f.att.id, ref: f.att.ref, rules: rules, groups: groups};

			return group;
		
		} else {

			var inputs : Array<Input> = [];

			var group: Group = {id: f.att.id, ref: f.att.ref, rules: rules, inputs: inputs};
			
			for (input in f.elements) {

				inputs.push(createInput(input, group));
			}

			return group;
		}
	}

	static function parsePartPerks(pd : PartData, perks : String, ? hash : Null<StringMap<Int>> = null) : PartData {

		var map = ParseUtils.parseHash(perks);
		
		for (perk in map.keys()) {

			if (hash == null) {

				hash = pd.perks;
			}
			hash.set(perk, Std.parseInt(map.get(perk)));
		}

		return pd;
	}

	static function parsePartHeader(pd : PartData, f : Fast) : PartData {

		if (f.has.name) { 

			pd.name = f.att.name;
		}
		if (f.has.file) { 

			pd.file = f.att.file;
		}
		if (f.has.display) { 

			pd.display = f.att.display;
		}
		if (f.has.next) { 

			pd.next = f.att.next;
		}
		if (f.has.bounty) { 

			pd = parsePartPerks(pd, f.att.bounty);
		}
		if (f.has.requires) { 

			pd = parsePartPerks(pd, f.att.requires, pd.requirements);
		}

		return pd;
	}

	static public function parsePartData(xml : Xml) : PartData {

		var f : Fast = new Fast(xml);

		var pd : PartData = {};

		pd.id = f.att.id;
		pd.nbSubPartTotal = 0;
		pd.elements = new Array();
		pd.tokens = new GenericStack();
		pd.buttons = new StringMap();
		pd.buttonTargets = new StringMap();
		pd.perks = new StringMap();
		pd.requirements = new StringMap();

		pd = parsePartHeader(pd, f);

		if (f.hasNode.Sound) {

#if (flash || openfl)
			pd.soundLoopSrc = f.node.Sound.att.content;
#else
			pd.soundLoop = f.node.Sound.att.content;
#end
		}
		if (f.hasNode.Part && pd.file != null) {

			for (partNode in xml.nodes.Part) {

				pd.nbSubPartTotal++;

				var sp : Part = parse(partNode, p);
				
				pd.elements.push(Part(sp));
			}
		}
		if (pd.display == null && pd.parent != null) {

			pd.display = pd.parent.display;
		}

		return pd;
	}
}