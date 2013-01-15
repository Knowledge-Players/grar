package com.knowledgeplayers.grar.display.style;

import haxe.xml.Fast;
import nme.Assets;
import nme.display.Bitmap;
import nme.Lib;

/**
 * Parser and manager of the styles
 */
class StyleParser 
{
	/**
	 * Hash of the styles parsed
	 */
	public static var styles = new Hash<Style>();
	
	/**
	 * Instance of the parser
	 */
	public static var instance (getInstance, null): StyleParser;
	
	private function new() { }

	/**
	 * @return the instance of the parser
	 */
	public static function getInstance() : StyleParser
	{
		if (instance == null)
			return new StyleParser();
		else
			return instance;
	}

	/**
	 * Parse the style file
	 * @param	xmlContent : content of the style file
	 */
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

	/**
	 * Get a style by its name. The style file must have been parsed first!
	 * @param	name : Name of the style
	 * @return the style, or null if it doesn't exist
	 */
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