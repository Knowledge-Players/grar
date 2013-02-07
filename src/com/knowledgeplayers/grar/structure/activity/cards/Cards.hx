package com.knowledgeplayers.grar.structure.activity.cards;

import nme.events.Event;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.util.XmlLoader;

/**
* Folder activity
**/
class Cards extends Activity {
    /**
    * Elements of the activity
**/
    public var elements (default, null): Hash<CardsElement>;

    /**
    * Constructor
    * @param content : Content of the activity
**/

    public function new(content: String)
    {
        super(content);
        elements = new Hash<CardsElement>();
        XmlLoader.load(content, onLoadComplete, parseContent);
    }

    // Private

    override private function parseContent(content: Xml): Void
    {
        var fast = new Fast(content).node.Cards;
        for(element in fast.nodes.Element){
            var elem = new CardsElement(element.att.Ref);
            elements.set(elem.content, elem);
        }
    }
}
