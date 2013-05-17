package com.knowledgeplayers.grar.display.style;

import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
import nme.display.Bitmap;

typedef StyleSheet = Hash<Style>

/**
 * Parser and manager of the styles
 */
class StyleParser {
	/**
    * Path to the current style sheet
    **/
	public static var currentStyleSheet:String;

	/**
	* Current locale of the app
	**/
	public static var currentLocale:String;

	private static var styles = new Hash<Hash<StyleSheet>>();

	/**
     * Parse the style file
     * @param	xmlContent : content of the style file
     */

	public static function parse(xmlContent:Xml):Void
	{
		var stylesheet = new StyleSheet();
		var xml:Fast = new Fast(xmlContent).node.stylesheet;
		var name = xml.att.name;
		for(styleNode in xml.nodes.style){
			var style:Style = new Style();
			style.name = styleNode.att.name;
			if(styleNode.has.inherit)
				style.inherit(stylesheet.get(styleNode.att.inherit));
			for(child in styleNode.elements){
				if(child.name.toLowerCase() == "icon"){
					if(child.att.value.indexOf(".") < 0){
						style.icon = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, child.att.value);
					}
					else
						style.icon = AssetsStorage.getBitmapData(child.att.value);
					style.iconPosition = child.att.position.toLowerCase();
					style.setIconMargin(child.att.margin);
				}
				else if(child.name.toLowerCase() == "background"){
					if(Std.parseInt(child.att.value) != null){
						style.background = new Bitmap();
						style.background.opaqueBackground = Std.parseInt(child.att.value);
					}
					else
						style.background = new Bitmap(AssetsStorage.getBitmapData(child.att.value));
				}
				else
					style.addRule(child.name, child.att.value);
			}
			stylesheet.set(styleNode.att.name, style);
		}
		if(styles.get(currentLocale) == null)
			styles.set(currentLocale, new Hash<StyleSheet>());
		if(Lambda.count(styles.get(currentLocale)) == 0)
			currentStyleSheet = name;
		styles.get(currentLocale).set(name, stylesheet);
	}

	/**
     * Get a style by its name. The style file must have been parsed first!
     * @param	name : Name of the style
     * @return the style, or null if it doesn't exist
     */

	public static function getStyle(?name:String):Null<Style>
	{
		if(Lambda.count(styles) == 0)
			throw "No style here. Have you parse a style file ?";
		if(name == null)
			return styles.get(currentLocale).get(currentStyleSheet).get("text");
		if(StringTools.endsWith(name, "-"))
			return styles.get(currentLocale).get(currentStyleSheet).get(name + "text");
		else
			return styles.get(currentLocale).get(currentStyleSheet).get(name);
	}

}
