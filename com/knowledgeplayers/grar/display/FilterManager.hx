package com.knowledgeplayers.grar.display;

#if flash
import flash.filters.GlowFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilterQuality;
import flash.display.Bitmap;
#end
import com.knowledgeplayers.grar.util.ParseUtils;
import flash.filters.BitmapFilter;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;

/**
 * Manage the most frequently used filters
 */
class FilterManager {

	private static var filters:Map<String, BitmapFilter> = new Map<String, BitmapFilter>();

	/**
	* @return a filter from the template
	**/

	public static function getFilter(id:String):Array<BitmapFilter>
	{
		var result = new Array<BitmapFilter>();
		var filtersId = ParseUtils.parseListOfValues(id);
		for(filter in filtersId){
			if(!filters.exists(filter))
				throw "[FilterManager] There is no filter with id '"+filter+"'.";
			result.push(filters.get(filter));
		}
		return result;
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
			case "blur":
				setBlurFilter(filterNode[1]);
			case "glow":
				setGlowFilter(filterNode[1]);
			case _ : throw '[FilterManager] Unsupported filter $filterNode[0]';

		}

		return filter;
	}

	private static function setDropShadowFilter(_params:String):BitmapFilter
	{
		var params = _params.split(",");
		#if flash
		var filter:DropShadowFilter = new DropShadowFilter(Std.parseFloat(params[0]), Std.parseFloat(params[1]), Std.parseInt(params[2]), Std.parseFloat(params[3]), Std.parseFloat(params[4]), Std.parseFloat(params[5]));
		#else
		var filter = null;
		#end
		return filter;
	}

	private static function setBlurFilter(paramsString: String): BitmapFilter
	{
		var params = paramsString.split(",");
		#if flash
		return new BlurFilter(Std.parseFloat(params[0]), Std.parseFloat(params[1]), Std.parseInt(params[2]));
		#else
		return null;
		#end
	}

	private static function setGlowFilter(paramsString:String):BitmapFilter
	{
		var params = paramsString.split(",");
		#if flash
		return new GlowFilter(Std.parseInt(params[0]), Std.parseFloat(params[1]), Std.parseInt(params[2]), Std.parseFloat(params[3]), Std.parseFloat(params[4]), Std.parseInt(params[5]));
		#else
		return null;
		#end
	}

	public static function loadTemplate(file:String):Void
	{
		var root = new Fast(AssetsStorage.getXml(file)).node.Filters;
		for(child in root.elements){
			#if flash
			var filter:BitmapFilter =
				switch(child.name.toLowerCase()){
					case "dropshadow":
						var distance = child.has.distance ? Std.parseFloat(child.att.distance) : 0;
						var angle = child.has.angle ? Std.parseFloat(child.att.angle) : 0;
						var color = child.has.color ? Std.parseInt(child.att.color) : 0;
						var alpha = child.has.alpha ? Std.parseFloat(child.att.alpha) : 1;
						var blurX = child.has.blurX ? Std.parseFloat(child.att.blurX) : 0;
						var blurY = child.has.blurY ? Std.parseFloat(child.att.blurY) : 0;
						var strength = child.has.strength ? Std.parseFloat(child.att.strength) : 1;
						var quality = child.has.quality ? Reflect.getProperty(BitmapFilterQuality, child.att.quality.toUpperCase()) : BitmapFilterQuality.MEDIUM;
						var inner = child.has.inner ? child.att.inner == "true" : false;
						var knockout = child.has.knockout ? child.att.knockout == "true" : false;
						var hideObject = child.has.hideObject ? child.att.hideObject == "true" : false;
						new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
					case "blur":
						var blurX = child.has.blurX ? Std.parseFloat(child.att.blurX) : 0;
						var blurY = child.has.blurY ? Std.parseFloat(child.att.blurY) : 0;
						var quality = child.has.quality ? Std.parseInt(child.att.quality) : BitmapFilterQuality.MEDIUM;
						new BlurFilter(blurX, blurY, quality);
					case "glow":
						var color = child.has.color ? Std.parseInt(child.att.color) : 0;
						var alpha = child.has.alpha ? Std.parseFloat(child.att.alpha) : 1;
						var blurX = child.has.blurX ? Std.parseFloat(child.att.blurX) : 0;
						var blurY = child.has.blurY ? Std.parseFloat(child.att.blurY) : 0;
						var strength = child.has.strength ? Std.parseFloat(child.att.strength) : 1;
						var quality = child.has.quality ? Reflect.getProperty(BitmapFilterQuality, child.att.quality.toUpperCase()) : BitmapFilterQuality.MEDIUM;
						var inner = child.has.inner ? child.att.inner == "true" : false;
						var knockout = child.has.knockout ? child.att.knockout == "true" : false;
						new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
					case "color":
						var matrix = new Array();
						for(v in child.att.matrix.split(","))
							matrix.push(Std.parseFloat(v));
						new ColorMatrixFilter(matrix);
					default:
						throw "[FilterManager] Filter \"" + child.name + "\" is not supported.";
				}
			#else
			var filter = null;
			#end
			filters.set(child.att.ref, filter);
		}
	}
}