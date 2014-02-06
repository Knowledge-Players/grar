package grar.parser;

import haxe.Json;
import haxe.xml.Fast;

import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import flash.display.Bitmap;

typedef StyleSheet = {
	name : String,
	styles : Map<String, Style>
}

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

	private static var styles = new Map<String, Map<String, StyleSheet>>();

	/**
     * Parse the style file
     * @param	xmlContent : content of the style file
     */

	public static function parse(content:String, type: String):Void
	{
		var stylesheet: StyleSheet;
		if(type == "json"){
			stylesheet = parseJson(content);
		}
		else{
			stylesheet = parseXml(Xml.parse(content));
		}

		if(styles.get(currentLocale) == null)
			styles.set(currentLocale, new Map<String, StyleSheet>());
		if(Lambda.count(styles.get(currentLocale)) == 0)
			currentStyleSheet = stylesheet.name;
		styles.get(currentLocale).set(stylesheet.name, stylesheet);
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
			return styles.get(currentLocale).get(currentStyleSheet).styles.get("text");
		if(StringTools.endsWith(name, "-"))
			return styles.get(currentLocale).get(currentStyleSheet).styles.get(name + "text");
		else
			return styles.get(currentLocale).get(currentStyleSheet).styles.get(name);
	}

	private static function parseJson(jsonContent:String):StyleSheet
	{
		var jsonStylesheet = Json.parse(jsonContent);
		var styleSheet: StyleSheet = {name: jsonStylesheet.name, styles: new Map<String, Style>()};
		var waitingList = new Array<{style: Style, infos: Dynamic}>();
		for (key in Reflect.fields(jsonStylesheet.styles)) {
			var styleInfos = Reflect.field(jsonStylesheet.styles, key);
			var style:Style = new Style();
			style.name = key;
			if(Reflect.hasField(styleInfos, "inherit")){
				if(styleSheet.styles.exists(styleInfos.inherit)){
					style.inherit(styleSheet.styles.get(styleInfos.inherit));
					parseRules(styleInfos, Reflect.fields(styleInfos), style);
					styleSheet.styles.set(style.name, style);
				}
				else
					waitingList.push({style: style, infos: styleInfos});
			}
			else{
				parseRules(styleInfos, Reflect.fields(styleInfos), style);
				styleSheet.styles.set(style.name, style);
			}
		}
		var i = 0;
		while(waitingList.length > 0){
			var style = waitingList.shift();
			if(styleSheet.styles.exists(style.infos.inherit)){
				style.style.inherit(styleSheet.styles.get(style.infos.inherit));
				parseRules(style.infos, Reflect.fields(style.infos), style.style);
				styleSheet.styles.set(style.style.name, style.style);
			}
			else
				waitingList.push(style);
		}
		return styleSheet;
	}

	private static function parseRules(styleInfos: Dynamic, fields: Iterable<Dynamic>, style: Style):Void
	{
		for(field in fields){
			if(field == "icon"){
				// Icon bmp
				if(Reflect.field(styleInfos, field).graphic.indexOf(".") < 0)
					style.icon = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, styleInfos.icon.graphic);
				else
					style.icon = AssetsStorage.getBitmapData(styleInfos.icon.graphic);
				// Icon margin
				if(Reflect.hasField(styleInfos.icon, "margin"))
					style.setIconMargin(Reflect.field(styleInfos.icon, "margin"));
				else
					style.setIconMargin("");
				// Icon position
				style.iconPosition = Reflect.field(styleInfos.icon, "position");

			}
			else if(field == "background"){
				#if !html
					if(Std.parseInt(Reflect.field(styleInfos, field)) != null){
					style.background = new Bitmap();
					style.background.opaqueBackground = Std.parseInt(Reflect.field(styleInfos, field));
				}
				else
					#end
					style.background = new Bitmap(AssetsStorage.getBitmapData(Reflect.field(styleInfos, field)));
			}
			else if(field != "inherit")
				style.addRule(field, Reflect.field(styleInfos, field));
		}
	}

	private static function parseXml(xmlContent:Xml):StyleSheet
	{
		var xml:Fast = new Fast(xmlContent).node.stylesheet;
		var stylesheet: StyleSheet = {name:  xml.att.name, styles: new Map<String, Style>()};
		for(styleNode in xml.nodes.style){
			var style:Style = new Style();
			style.name = styleNode.att.name;
			if(styleNode.has.inherit)
				style.inherit(stylesheet.styles.get(styleNode.att.inherit));
			for(child in styleNode.elements){
				if(child.name.toLowerCase() == "icon"){
					if(child.att.value.indexOf(".") < 0){
						style.icon = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, child.att.value);
					}
					else
						style.icon = AssetsStorage.getBitmapData(child.att.value);
					style.iconPosition = child.att.position.toLowerCase();
					if(child.has.margin)
						style.setIconMargin(child.att.margin);
					else
						style.setIconMargin("");
				}
				else if(child.name.toLowerCase() == "background"){
					if(Std.parseInt(child.att.value) != null){
						style.background = new Bitmap();
						#if !html
						style.background.opaqueBackground = Std.parseInt(child.att.value);
						#end
					}
					else
						style.background = new Bitmap(AssetsStorage.getBitmapData(child.att.value));
				}
				else
					style.addRule(child.name, child.att.value);
			}
			stylesheet.styles.set(styleNode.att.name, style);
		}
		return stylesheet;
	}
}
