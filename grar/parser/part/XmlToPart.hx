package grar.parser.part;

import grar.util.Point;
import grar.model.part.item.GroupItem;
import grar.model.part.item.Pattern;
import grar.model.part.Part;
import grar.model.part.PartElement;
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

		var f : Fast = new Fast(xml.nodeType == Xml.Document ? xml.firstElement() : xml);

		var pp : PartialPart = cast { };
		pp.pd = parsePartData(f);

		if(f.name.toLowerCase() == "activity")
			pp.type = Activity;
		else
			pp.type = Part;

		return pp;
	}

	/**
	* Create parts from parts data. If sub-parts are present, their data will be returned
	* @param    pp: Partial part with the part data
	* @param    xml: Xml datas
	* @return the new part and an array of its sub-parts as PartialPart
	**/
	static public function parseContent(pp : PartialPart, xml : Xml) : { p : Part, pps : Array<PartialPart> } {

		var f : Fast = new Fast(xml.nodeType == Xml.Document ? xml.firstElement() : xml);

		var p : Part;
		var pps : Array<PartialPart>;
		var pd : PartData = parsePartContentData(pp.pd, xml);

		pps = pd.partialSubParts;
		p = new Part(pd);

		if(pp.type == Activity)
			p.activityData = parseActivityPartContent(f);

		return { p: p, pps: pps };
	}


	///
	// INTERNALS
	//

	static function parsePartContentData(pd : PartData, xml : Xml) : PartData
	{
		var f : Fast = null;

		// No Document node
		if(xml.nodeType == Xml.Element)
			f = new Fast(xml);
		else
			f = new Fast(xml.firstElement());

		pd = parsePartHeader(pd, f);

		for (child in f.elements)
			pd = parsePartElement(pd, child);

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

			case "text" | "sound" | "video":
				pd.elements.push( Item(XmlToItem.parse(node.x)) );
			case "part" | "activity":
				pd.partialSubParts.push( parse(node.x) );
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

			case "pattern":
				pd.elements.push(Pattern(XmlToPattern.parse(node.x)));
			case "group":
				pd.elements.push(GroupItem(XmlToGroup.parse(node.x)));
            case "image":
                pd.images.add({ref:node.att.ref,src:node.att.src});
			default:
				if (n != "group" && n != "rule" && n != "image" && n != "inputs")
					throw "unexpected "+node.name;
		}

		for(elem in pd.elements){
			switch(elem){
				case Item(i): if(i.button.isEmpty()) i.button = pd.buttons;
				case GroupItem(g): for(i in g.elements) if(i.button.isEmpty()) i.button = pd.buttons;
				default:
			}
		}

		return pd;
	}

	static function parseActivityPartContent(f : Fast) : ActivityData {

		var groups : Array<Inputs> = new Array();
		var rules : StringMap<Rule> = new StringMap();
		var numRightAnswers : Int = 0;

		for (child in f.elements) {

			switch (child.name.toLowerCase()) {

				case "inputs":

					var group : Inputs = createInputGroup(child);
					groups.push(group);

				case "rule" :

					var rule : Rule = { id: child.att.id, type: child.att.type.toLowerCase(), value: child.att.value};
					rules.set(rule.id, rule);
			}
		}
		// If no rules has been set on a group, all applies
		for (group in groups) {

			if (group.rules == null) {
				group.rules = new Array();
				for (rule in rules)
					group.rules.push(rule.id);
			}
		}

		return {groups: groups, rules: rules, groupIndex: 0, numRightAnswers: 0, score: 0, inputsEnabled: true};
	}

	static function createInput(f : Fast) : Input {

		var values;
		var images;
		var points = 0;
		var selected = false;
		var content = new Map<String, Item>();

		if(f.has.content){
			var c = ParseUtils.parseHash(f.att.content);
			for(key in c.keys()){
				var data: ItemData = {content: c[key], ref: key, author: null, background: null, button: null, tokens: null, images: null, endScreen: false, videoData: null, soundData: null, voiceOverUrl: null};
				content[key] = new Item(data);
			}
		}

		if (f.has.values)
			values = ParseUtils.parseListOfValues(f.att.values);
		else
			values = new Array<String>();

		if(f.has.img)
			images = ParseUtils.parseHash(f.att.img);
		else
			images = new Map<String, String>();

		if(f.has.points)
			points = Std.parseInt(f.att.points);

		if(f.has.selected)
			selected = f.att.selected == "true";

		for(child in f.elements){
			switch(child.name.toLowerCase()){
				case "text" | "sound" | "video": content[child.att.ref] = XmlToItem.parse(child.x);
				case "image": images[child.att.ref] = child.att.src;
			}
		}

		return {id: f.att.id, ref: f.att.ref, items: content, values: values, selected: selected, images: images, points: points};
	}

	static function createInputGroup(f : Fast) : Inputs {

		var rules : Array<String> = null;

		if(f.has.rules)
			rules = ParseUtils.parseListOfValues(f.att.rules);

        var inputs : Array<Input> = [];
        var items : Array<Item> = [];
        var groups : Array<Inputs> = [];

        var group: Inputs = {id: f.att.id, ref: f.att.ref, rules: rules, inputs: inputs, items: items, groups: groups};
		if(f.has.position){
			group.position = ParseUtils.parseListOfValues(f.att.position).map(function(val: String){
				var coord = val.split(";");
				return new Point(Std.parseFloat(coord[0]), Std.parseFloat(coord[1]));
			});
		}

        for (input in f.elements) {
            switch (input.name.toLowerCase()) {
                case "input" :
                    inputs.push(createInput(input));
                case "text" :
                    items.push(XmlToItem.parse(input.x));
                case "image" :
                //TODO ADD IMAGE
                case "inputs" :
                    groups.push(createInputGroup(input));
            }
        }

        return group;

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
		pd.elements = new Array();
		pd.tokens = new GenericStack<String>();
		pd.buttons = new List();
        pd.images = new List();
		pd.buttonTargets = new StringMap();
		pd.perks = new StringMap();
		pd.requirements = new StringMap();
		pd.partialSubParts = [];

		pd = parsePartHeader(pd, f);
		pd.xml = f.x;

		return pd;
	}
}