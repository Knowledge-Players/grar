package com.knowledgeplayers.grar.structure.activity.cards;

import haxe.xml.Fast;

/**
* Folder activity
**/
class Cards extends Activity {
/**
    * Elements of the activity
    **/
    public var elements (default, null):Array<CardsElement>;

/**
    * Constructor
    * @param content : Content of the activity
    **/

	public function new(content:String)
	{
        elements = new Array<CardsElement>();
		super(content);
	}

	// Private

	override private function parseContent(xml:Xml):Void
	{
		super.parseContent(xml);
        var fast = new Fast(xml.firstElement());
        for(element in fast.nodes.Element){

			var elem = new CardsElement(element.att.content,element.att.ref);
            elements.push(elem);
		}
	}
}
