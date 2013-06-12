package com.knowledgeplayers.grar.display;
/**
 * Manage the most frequently used filters
 */
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
import nme.filters.BitmapFilter;
import nme.filters.BitmapFilterQuality;
import nme.filters.DropShadowFilter;

class FilterManager {

	private static var filters:Map<String, BitmapFilter> = new Map<String, BitmapFilter>();

	/**
	* @return a filter from the template
	**/

	public static function getFilter(id:String):BitmapFilter
	{
		return filters.get(id);
	}

	/**
    * Create a bitmap filter from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a bitmap filter
    **/

	public static function createFilter(filter:String): BitmapFilter
	{
		var filterNode = filter.split(":");

		var filter:BitmapFilter =
		switch(Std.string(filterNode[0]).toLowerCase()){
			case "dropshadow":
				setDropShadowFilter(filterNode[1]);
			case _ : throw '[FilterManager] Unsupported filter $filterNode[0]';

		}

		return filter;
	}

	private static function setDropShadowFilter(_params:String):DropShadowFilter
	{

		var params = _params.split(",");
		var filter:DropShadowFilter = new DropShadowFilter(Std.parseFloat(params[0]), Std.parseFloat(params[1]), Std.parseInt(params[2]), Std.parseFloat(params[3]), Std.parseFloat(params[4]), Std.parseFloat(params[5]));
		return filter;
	}

	public static function loadTemplate(file:String):Void
	{
		var root = new Fast(AssetsStorage.getXml(file)).node.Filters;
		for(child in root.elements){
			var filter:BitmapFilter =
				switch(child.name.toLowerCase()){
					case "dropshadow":
						var distance = child.has.distance ? Std.parseFloat(child.att.distance) : 0;
						var angle = child.has.angle ? Std.parseFloat(child.att.angle) : 0;
						var color = child.has.color ? Std.parseInt(child.att.color) : 0;
						var alpha = child.has.alpha ? Std.parseFloat(child.att.alpha) : 1;
						var blurX = child.has.blurX ? Std.parseFloat(child.att.blurX) : 0;
						var blurY = child.has.blurY ? Std.parseFloat(child.att.blurY) : 0;
						var strength = child.has.strength ? Std.parseFloat(child.att.strength) : 127;
						var quality = child.has.quality ? Reflect.getProperty(BitmapFilterQuality, child.att.quality.toUpperCase()) : BitmapFilterQuality.MEDIUM;
						var inner = child.has.inner ? child.att.inner == "true" : false;
						var knockout = child.has.knockout ? child.att.knockout == "true" : false;
						var hideObject = child.has.hideObject ? child.att.hideObject == "true" : false;
						new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
					default:
						throw "[FilterManager] Filter \"" + child.name + "\" is not supported.";
				}
			filters.set(child.att.ref, filter);
		}
	}

}