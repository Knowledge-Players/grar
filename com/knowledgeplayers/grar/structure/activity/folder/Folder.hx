package com.knowledgeplayers.grar.structure.activity.folder;

import haxe.xml.Fast;

/**
* Folder activity
**/
class Folder extends Activity {
	/**
    * Elements of the activity
    **/
	public var elements (default, null):Map<String, FolderElement>;

	/**
    * Targets where to drop elements
    **/
	public var targets (default, default):Array<String>;

	/**
    * Constructor
    * @param content : Content of the activity
    **/

	public function new(content:String)
	{
		elements = new Map<String, FolderElement>();
		targets = new Array<String>();
		super(content);
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
