package grar.parser.part;

import grar.model.part.Pattern;
import grar.model.part.dialog.ChoicePattern;
import grar.model.part.video.VideoPattern;
import grar.model.part.strip.BoxPattern;

import haxe.xml.Fast;
import haxe.ds.StringMap;

class XmlToPattern {

	static public function parse(xml : Xml) : Pattern {

		var p : Pattern;
		var f : Fast = new Fast(xml);

		switch (f.att.type.toLowerCase()) {

			case "link":

				p = parsePattern(f);
			
			case "box":

				p = parseBoxPattern(f, f.has.background ? f.att.background: null);
			
			case "choice":

				p = parseChoicePattern(f);
			
			case "video":

				p = parseVideoPattern(f);
			
			default:

				throw "unexpected pattern type attribute value " + f.att.type;
		}
	}

	static function parsePatternData( f : Fast ) : PatternData {

		var pd : PatternData = { };

		pd.patternContent = [];
		pd.buttons = new StringMap();
		pd.tokens = new GenericStack<String>();
		pd.id = f.att.id;
		pd.nextPattern = f.att.next;
		pd.endScreen = false;
		pd.itemIndex = 0;

		for (itemNode in f.nodes.Text) {

			pd.patternContent.push(XmlToItem.parse(itemNode));
		}
		for (child in f.elements) {

			if (child.name.toLowerCase() == "button" || child.name.toLowerCase() == "choice") {

				if (child.has.content) {

					pd.buttons.set(child.att.ref, ParseUtils.parseHash(child.att.content));
				
				} else {

					pd.buttons.set(child.att.ref, new StringMap());
				}
			}
		}
		return pd;
	}

	static function parsePattern( f : Fast ) : Pattern {

		return new Pattern( parsePatternData(f) );
	}

	static function parseBoxPattern( f : Fast, b : Null<String> ) : BoxPattern {

		return new BoxPattern( parsePatternData(f), b );
	}

	static function parseChoicePattern( f : Fast ) : ChoicePattern {

		var pd : PatternData = parsePatternData(f);

		var tooltipRef : String;
		var choices : StringMap<Choice> = new StringMap();
		var numChoices : Int = 0;
		var minimumChoice : Int;
		var tooltipTransition : String;

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

	static function parseVideoPattern( f : Fast ) : VideoPattern {

		var pd : PatternData = parsePatternData(f);

		return new VideoPattern(pd);
	}
}