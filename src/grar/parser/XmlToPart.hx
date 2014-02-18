package grar.parser;

import grar.model.part.Part;
import grar.model.part.PartElement;

import haxe.xml.Fast;

class XmlToPart {

	/**
	 * @param Xml describing the part
	 * @param parent Part if any
	 */
	static public function parse(xml : Xml, ? parent : Null<Part>) : Part {

		var f : Fast = new Fast(xml);
		var p : Part;

		var t : String = f.has.type ? f.att.type.toLowerCase() : "";

		switch (t) {

			case "dialog":

				// TODO creation = new DialogPart();

			case "strip" :

				// TODO creation = new StripPart();

			case "activity":

				// TODO creation = new ActivityPart();

			case "" :

				p = parsePart( xml, parent );

			default: 

				throw "unexpected type attribute value $t";
		}

		return p;
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

	static public function parsePart(xml : Xml, ? parent : Null<Part>) : Part {

		var f : Fast = new Fast(xml);

		var p : Part = new Part();
		var pd : PartData = {};

		pd.id = f.att.id;
		pd.nbSubPartTotal = 0;
		pd.elements = new Array();
		pd.tokens = new GenericStack();
		pd.buttons = new StringMap();
		pd.buttonTargets = new StringMap();
		pd.perks = new StringMap();
		pd.requirements = new StringMap();
		pd.parent = parent;

		pd = parsePartHeader(pd, f);

		if (f.hasNode.Sound) {

			pd.soundLoop = AssetsStorage.getSound(f.node.Sound.att.content); // FIXME
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
		if (pd.file != null) {

			parseContent(AssetsStorage.getXml(pd.file)); // FIXME
		
		} else if (xml.elements.hasNext()) {
		//if (pd.file == null && xml.elements.hasNext()) {

			parseContent(xml);
			
			if (pd.parent != null) {

				pd.file = pd.parent.file;
			}
		}

		p.data = pd;

		return p;
	}

	static public function parsePartContent(p : Part, xml : Xml) : Part {

		var f : Fast = (xml.nodeType == Xml.Element && xml.nodeName == "Part") ? new Fast(xml) : new Fast(xml).node.Part;

		var pd : PartData = p.data;

		pd = parsePartHeader(pd, f);

		for (child in f.elements) {

			pd = parsePartElement(p, pd, child);
		}
		for (elem in pd.elements) {

			if (elem.isText() || elem.isVideo()|| elem.isSound()) {

				var text = cast(elem, Item);
				
				if (text.button == null || Lambda.empty(text.button)) {

					text.button = pd.buttons;
				}
			}
			if (elem.isPattern()) {

				for (item in cast(elem, Pattern).patternContent) {

					for (image in item.tokens) {

						pd.tokens.add(image);
					}
				}
			}
			for (image in elem.tokens) {

				pd.tokens.add(image);
			}
		}
		pd.loaded = true;

		p.data = pd;

		return p;
		
		// FIXME
		//if (nbSubPartLoaded == nbSubPartTotal) {

		//	fireLoaded();
		//}
	}

	static function parsePartElement(p : Part, pd : PartData, node : Fast) : PartData {

		switch (node.name.toLowerCase()) {

			case "text":

				pd.elements.push( Item(XmlToItem.parse(node)) );
			
			case "part":

				pd.nbSubPartTotal++;

				pd.elements.push( Part(parse(partNode, p)) );
			
			case "sound":

				//pd.soundLoop = AssetsStorage.getSound(node.att.content); FIXME
			
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

						var i = 0;
						
						// FIXME
						while ((!pd.elements[i].isText() || 
								cast(pd.elements[i], TextItem).content != node.att.goTo) && i < pd.elements.length) {

							i++;
						}
						if (i != pd.elements.length) {

							pd.buttonTargets.set(node.att.ref, elements[i]);
						}
					}
				}
		}

		return pd;
	}
}