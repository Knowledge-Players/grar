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
    public var elements (default, null): Hash<FolderElement>;

    /**
    * Constructor
    * @param content : Content of the activity
**/

    public function new(content: String)
    {
        super(content);
        elements = new Hash<FolderElement>();
        var xml = XmlLoader.load(content, onLoadComplete);
        #if !flash
			parseContent(xml);
        #end
    }

    // Private

    override private function parseContent(content: Xml): Void
    {
        var fast = new Fast(content).node.Folder;
        for(element in fast.nodes.Element){
            var elem = new FolderElement(element.att.Ref);
            if(element.has.isAnswer && element.att.isAnswer == "true")
                elem.isAnswer = true;
            elements.set(elem.content, elem);
        }
    }
}
