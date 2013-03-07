package com.knowledgeplayers.grar.structure.activity.folder;

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

    public var targets (default, default):Array<String>;

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

    // Private

    override private function parseContent(content:Xml):Void
    {
        var fast = new Fast(content).node.Folder;
        background = fast.att.background;
        for(element in fast.nodes.Element){
            var elem = new FolderElement(element.att.content, element.att.ref);
            if(element.has.target){
                elem.target = element.att.target;
                targets.push(element.att.target);
            }
            elements.set(elem.content, elem);
        }
    }
}
