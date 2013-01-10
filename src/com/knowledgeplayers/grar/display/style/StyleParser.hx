package com.knowledgeplayers.grar.display.style;

import haxe.xml.Fast;
import nme.Assets;
import nme.display.Bitmap;
import nme.Lib;

class StyleParser 
{
	public static var styles = new Hash<Style>();
	
	public static var instance (getInstance, null): StyleParser;
	
	private function new() { }

	public static function getInstance()
	{
		if (instance == null)
			return new StyleParser();
		else
			return instance;
	}

	public function parse(xmlContent : String) : Void
	{
		var xml: Xml = Xml.parse(xmlContent);
		for (styleNode in xml.elements()) {
			var style: Style = new Style();
			style.name = styleNode.get("name");
			for (child in styleNode.elements()) {
				if (child.nodeName.toLowerCase() == "icon"){
					style.icon = Assets.getBitmapData("items/" + child.get("value"));
					style.iconPosition = child.get("position").toLowerCase();
				}
				else if (child.nodeName.toLowerCase() == "background") {
					if (Std.parseInt(child.get("value")) != null){
						style.background = new Bitmap();
						style.background.opaqueBackground = Std.parseInt(child.get("value"));
					}
					else
						style.background = new Bitmap(Assets.getBitmapData("items/" + child.get("value")));
				}
				else if(child.get("value") != null)
					style.addRule(child.nodeName, child.get("value"));
			}
			styles.set(styleNode.get("name"), style);
		}
	}

	public function getStyle(name: String) : Null<Style>
	{
		if(Lambda.count(styles) == 0)
			Lib.trace("No style here. Have you parse a style file ?");
		if (StringTools.endsWith(name, "-"))
			return styles.get(name + "text");
		else
			return styles.get(name);
	}


}