package grar.parser.part;

import grar.model.part.ButtonData;
import grar.model.part.Pattern;
import grar.model.part.dialog.ChoicePattern;

import grar.util.ParseUtils;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

import haxe.xml.Fast;

class XmlToPattern {

	static public function parse(xml : Xml) : Pattern {

		var p : Pattern;
		var f : Fast = new Fast(xml);

		switch (f.att.type.toLowerCase()) {

			case "link":

				p = parsePattern(f);

			case "choice":

				p = parseChoicePattern(f);

			default:

				throw "unexpected pattern type attribute value " + f.att.type;
		}

		return p;
	}

	static function parsePatternData( f : Fast ) : PatternData {

		var pd : PatternData = cast { };

		pd.patternContent = [];

		pd.buttons = new List<ButtonData>();
		pd.tokens = new GenericStack<String>();
        pd.ref = f.att.ref;
		pd.id = f.att.id;
		pd.nextPattern = f.att.next;
		pd.endScreen = false;
		pd.itemIndex = 0;


		for (itemNode in f.nodes.Text) {

			pd.patternContent.push(XmlToItem.parse(itemNode.x));
		}
		for (child in f.elements) {

			if (child.name.toLowerCase() == "button" || child.name.toLowerCase() == "choice") {

				if (child.has.content) {

					pd.buttons.add({ref: child.att.ref, content: ParseUtils.parseHash(child.att.content), action: child.att.action});

				} else {

					pd.buttons.add({ref: child.att.ref, content: new StringMap(), action: child.att.action});
				}
			}
		}
		return pd;
	}

	static function parsePattern( f : Fast ) : Pattern {

		return new Pattern( parsePatternData(f) );
	}

	static function parseChoicePattern( f : Fast ) : ChoicePattern {

		var pd : PatternData = parsePatternData(f);

		var tooltipRef : Null<String> = null;
		var choices : StringMap<Choice> = new StringMap();
		var numChoices : Int = 0;
		var minimumChoice : Null<Int> = null;
		var tooltipTransition : Null<String> = null;

		if (f.has.toolTip && f.att.toolTip != "") {

			tooltipRef = f.att.toolTip;
		}
		if (f.has.toolTipTransition && f.att.toolTipTransition != "") {

			tooltipTransition = f.att.toolTipTransition;
		}
		minimumChoice = f.has.minChoice ? Std.parseInt(f.att.minChoice) : -1;

		for (choiceNode in f.nodes.Choice) {

			var tooltip = null;

			if (choiceNode.has.toolTip && choiceNode.att.toolTip != "") {

				tooltip = choiceNode.att.toolTip;
			}
			var choice = { ref: choiceNode.att.ref, toolTip: tooltip, goTo: choiceNode.att.goTo, viewed: false };

			choices.set(choiceNode.att.ref, choice);
		}
		return new ChoicePattern(pd, tooltipRef, choices, numChoices, minimumChoice, tooltipTransition);
	}
}