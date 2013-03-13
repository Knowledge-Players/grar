package com.knowledgeplayers.grar.structure.activity.folder;

import Math;
import nme.events.Event;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.util.XmlLoader;

/**
* Folder activity
**/
class Folder extends Activity {
    /**
    * Elements of the activity
    **/
    public var elements (default, null):Hash<FolderElement>;

    /**
    * Targets where to drop elements
    **/
    public var targets (default, default):Array<String>;

    /**
    * Mode of control.
    * If auto, the control is done when the elemnt is drop.
    * If end, the control is done when the activity is validated.
    **/
    public var controlMode (default, default):String;

    /**
    * Constructor
    * @param content : Content of the activity
    **/

    public function new(content:String)
    {
        super(content);
        elements = new Hash<FolderElement>();
        targets = new Array<String>();
        XmlLoader.load(content, onLoadComplete, parseContent);
    }

    public function validate():Void
    {
        for(key in elements.keys()){
            var element = elements.get(key);
            if(element.currentTarget == element.target)
                score++;
        }
        score = Math.floor(score * 100 / Lambda.count(elements));
    }

    // Private

    override private function parseContent(xml:Xml):Void
    {
        super.parseContent(xml);
        var fast = new Fast(xml.firstElement());
        controlMode = fast.att.controlMode.toLowerCase();
        for(element in fast.nodes.Element){
            var elem = new FolderElement(element.att.content, element.att.ref);
            if(element.has.target){
                elem.target = element.att.target;
                targets.push(element.att.target);
            }
            elements.set(elem.ref, elem);
        }
    }
}
