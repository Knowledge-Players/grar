package grar.parser.part;

import grar.model.part.GroupItem;
import grar.model.part.Part;
import grar.model.part.PartElement;
import grar.model.part.dialog.DialogPart;
import grar.model.part.strip.StripPart;
import grar.model.part.Pattern;
import grar.model.part.item.Item;

import grar.parser.part.XmlToPattern;
import grar.parser.part.XmlToItem;

import grar.util.ParseUtils;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

import haxe.xml.Fast;

using StringTools;

class XmlToPart {

	///
	// API
	//

	/**
	 * @param Xml describing the part
	 */
	static public function parse(xml : Xml) : PartialPart {

		var f : Fast = new Fast(xml);

		var pp : PartialPart = cast { };

		var t : String = f.has.type ? f.att.type.toLowerCase() : "";

		switch (t) {

			case "dialog":

				pp.type = Dialog;
				pp.pd = parsePartData(f);

			case "strip" :

				pp.type = Strip;
				pp.pd = parsePartData(f);

			case "activity":
				pp.type = Activity;
				pp.pd = parsePartData(f);

			case "" :

				pp.type = Part;
				pp.pd = parsePartData(f);

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
				var apd = parseActivityPartContent(pp.pd, xml);
				pps = apd.pd.partialSubParts;
				p = new Part(apd.pd);
				p.activityData = apd.ad;
				//p = new ActivityPart(apd.pd, apd.g, apd.r, apd.gi, apd.nra);

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

		pd = parsePartHeader(pd, f); // not sure we need it here too...

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

				default: //nothing
			}
		}

		return pd;
	}

	static function parsePartElement(pd : PartData, node : Fast) : PartData {

		var n : String = node.name.toLowerCase();

		switch (n) {

			case "text":

				pd.elements.push( Item(XmlToItem.parse(node.x)) );

			case "part":

				pd.nbSubPartTotal++;

				pd.partialSubParts.push( parse(node.x) );

			case "sound":
				pd.soundLoop = node.att.content;

			case "button":

				var content = null;

				if (node.has.content)
					content = ParseUtils.parseHash(node.att.content);
				else
					content = new StringMap();
				pd.buttons.add({ref: node.att.ref, content: content, action: node.att.action});

				if (node.has.goTo) {

					if (node.att.goTo == "") {

						pd.buttonTargets.set(node.att.ref, null);

					} else {

						for (elt in pd.elements) {

							switch (elt) {

								case Item(i) if (i.content == node.att.goTo):

									pd.buttonTargets.set(node.att.ref, elt);

								default: // nothing
							}
						}
					}
				}

			case "pattern": // should happen only for DialogParts and StripParts

				pd.elements.push(Pattern(XmlToPattern.parse(node.x)));

			case "group":
				pd.elements.push(GroupItem(XmlToGroup.parse(node.x)));

			default:

				if (n != "group" && n != "rule" && n != "image" && n != "inputs") {

					throw "unexpected "+node.name;
				}
		}

		return pd;
	}

	static function parseActivityPartContent(pd : PartData, xml : Xml) : { pd : PartData, ad: ActivityData} {

		var f : Fast = (xml.nodeType == Xml.Element && xml.nodeName == "Part") ? new Fast(xml) : new Fast(xml).node.Part;

		var groups : Array<Inputs> = new Array();
		var rules : StringMap<Rule> = new StringMap();
		var groupIndex : Int = -1;
		var numRightAnswers : Int = 0;

		for (child in f.elements) {

			switch (child.name.toLowerCase()) {

				case "inputs":

					var group : Inputs = createInputGroup(child);
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
		var activityData: ActivityData = {groups: groups, rules: rules, groupIndex: 0, numRightAnswers: 0};
		return { pd: pd, ad: activityData };
	}

	static function createInput(f : Fast, ? group : Inputs) : Input {

		var values;
		var icons;

		if (f.has.values)
			values = ParseUtils.parseListOfValues(f.att.values);
		else
			values = new Array<String>();

		if(f.has.icon)
			icons = ParseUtils.parseHash(f.att.icon);
		else
			icons = new Map<String, String>();
		return {id: f.att.id, ref: f.att.ref, content: ParseUtils.parseHash(f.att.content), values: values, selected: false, icon: icons,group: group};
	}

	static inline function createInputGroup(f : Fast) : Inputs {

		var rules : Array<String> = null;

		if (f.has.rules) {

			rules = ParseUtils.parseListOfValues(f.att.rules);
		}

		if (f.hasNode.Inputs) {

			var groups : Array<Inputs> = [];

			for (group in f.nodes.Inputs) {

				groups.push(createInputGroup(group));
			}
			var group : Inputs = {id: f.att.id, ref: f.att.ref, rules: rules, groups: groups};

			return group;

		} else {

			var inputs : Array<Input> = [];

			var group: Inputs = {id: f.att.id, ref: f.att.ref, rules: rules, inputs: inputs};

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

		if(f.has.ref)
			pd.ref = f.att.ref;

		if (f.has.name) {

			pd.name = f.att.name;
		}
		if (f.has.file) {

			pd.file = f.att.file;
		}
		pd.next = f.has.next && f.att.next.trim() != "" ? ParseUtils.parseListOfValues(f.att.next) : pd.next;

		if (f.has.bounty) {

			pd = parsePartPerks(pd, f.att.bounty);
		}
		if (f.has.requires) {

			pd = parsePartPerks(pd, f.att.requires, pd.requirements);
		}

		return pd;
	}

	static public function parsePartData(f : Fast) : PartData {

		var pd : PartData = cast {};

		pd.id = f.att.id;
		pd.nbSubPartTotal = 0;
		pd.elements = new Array();
		pd.tokens = new GenericStack<String>();
		pd.buttons = new List();
		pd.buttonTargets = new StringMap();
		pd.perks = new StringMap();
		pd.requirements = new StringMap();
		pd.partialSubParts = [];

		pd = parsePartHeader(pd, f);
		pd.xml = f.x;

		return pd;
	}
}