package grar.parser;

import grar.view.element.Timeline;

import haxe.xml.Fast;

class XmlToTimeline {
	
	///
	// API
	//

	typedef TimelineData = {

		var name : String;
		var elements : Array<{ ref : String, transition : String, delay : Float, dynamicValue : Null<String> }>;
		var nbCompleteTransitions : Float = 0;
	}

	static public function parseTimelineData(f : Fast) : TimelineData {

		var td : TimelineData = { };

		td.name = f.att.ref;
		td.elements = [];

		for (elem in f.elements) {

			td.elements.push({  ref: elem.att.ref,
								transition: elem.att.transition,
								elem.has.delay ? Std.parseFloat(elem.att.delay) : 0,
								dynamicValue: elem.att.ref.startsWith("$") ? elem.att.ref : null });

			// Creating mock widget for dynamic timeline
			/*
FIXME do in second step
			if (elem.att.ref.startsWith("$")) {

				var mock = new Image();
				mock.ref = elem.att.ref;
				timeline.addElement(mock, elem.att.transition, delay);
			
			} else if(!displays.exists(elem.att.ref)) {

				throw "[KpDisplay] Can't add unexistant widget '"+elem.att.ref+"' in timeline '"+f.att.ref+"'.";
			
			} else {

				timeline.addElement(displays.get(elem.att.ref),elem.att.transition,delay);
			}
			*/
		}
		return td;
	}


	///
	// INTERNALS
	//

	
}