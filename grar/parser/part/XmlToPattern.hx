package grar.parser.part;

import grar.util.ParseUtils;
import grar.model.part.ButtonData;
import grar.model.part.item.Pattern;

import grar.util.ParseUtils;

import haxe.ds.GenericStack;

import haxe.xml.Fast;

class XmlToPattern {

	static public function parse(xml : Xml) : Pattern {

		var f = new Fast(xml);
		var pd : PatternData = cast { };

		pd.patternContent = [];

		pd.buttons = new List<ButtonData>();
		pd.tokens = new GenericStack<String>();
		pd.ref = f.att.ref;
		pd.id = f.att.id;
		pd.nextPattern = f.has.next ? f.att.next : null;
		pd.endScreen = false;
		pd.itemIndex = 0;

		for (child in f.elements) {
			switch(child.name.toLowerCase()){
				case "button":
					if (child.has.content)
						pd.buttons.add({ref: child.att.ref, content: ParseUtils.parseHash(child.att.content), action: child.att.action});
					else
						pd.buttons.add({ref: child.att.ref, content: new Map(), action: child.att.action});
				case "text": pd.patternContent.push(XmlToItem.parse(child.x));
				case "choices": pd.choicesData = parseChoices(child);
			}
		}

		return new Pattern(pd);
	}

	static function parseChoices( f : Fast ) : ChoicesData {

		var tooltipRef : Null<String> = null;
		var choices : Map<String, Choice> = new Map();
		var minimumChoice : Null<Int> = null;
		var content: Map<String, String>;
		var icon: Map<String, String>;

		if (f.has.toolTip && f.att.toolTip != "")
			tooltipRef = f.att.toolTip;
		if(f.has.icon && f.att.icon != "")
			icon = ParseUtils.parseHash(f.att.icon);
		else
			icon = new Map();

		minimumChoice = f.has.minChoice ? Std.parseInt(f.att.minChoice) : -1;

		for (choiceNode in f.nodes.Choice) {
			var tooltip = null;
			if (choiceNode.has.toolTip && choiceNode.att.toolTip != "")
				tooltip = choiceNode.att.toolTip;
			if(choiceNode.has.content)
				content = ParseUtils.parseHash(choiceNode.att.content);
			else
				content = new Map();
			var choice: Choice = { ref: choiceNode.att.ref, toolTip: tooltip, goTo: choiceNode.att.goTo, viewed: false, content: content, id: choiceNode.att.id, icon: icon};

			choices.set(choiceNode.att.id, choice);
		}
		return {tooltipRef: tooltipRef, choices: choices, numChoices: 0, minimumChoice: minimumChoice, ref: f.att.ref};
	}
}