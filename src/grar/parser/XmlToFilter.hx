package grar.parser;

import grar.model.FilterData;

import haxe.xml.Fast;

import haxe.ds.StringMap;

class XmlToFilter {

	static inline var NODE_NAME_DROPSHADOW : String = "dropshadow";
	static inline var NODE_NAME_BLUR : String = "blur";
	static inline var NODE_NAME_GLOW : String = "glow";
	static inline var NODE_NAME_COLOR : String = "color";

	static inline var ATT_VALUE_LOW_Q : String = "LOW";
	static inline var ATT_VALUE_MED_Q : String = "MEDIUM";
	static inline var ATT_VALUE_HIG_Q : String = "HIGH";

    static public function parse( xml : Xml ) : StringMap<FilterData> {

		var root : Fast = new Fast(xml).node.Filters;
		var filters : StringMap<FilterData> = new StringMap();

		for (child in root.elements) {

			var filter : Null<FilterData>;
#if flash
			switch(child.name.toLowerCase()) {

				case NODE_NAME_DROPSHADOW:
					var distance = child.has.distance ? Std.parseFloat(child.att.distance) : 0;
					var angle = child.has.angle ? Std.parseFloat(child.att.angle) : 0;
					var color = child.has.color ? Std.parseInt(child.att.color) : 0;
					var alpha = child.has.alpha ? Std.parseFloat(child.att.alpha) : 1;
					var blurX = child.has.blurX ? Std.parseFloat(child.att.blurX) : 0;
					var blurY = child.has.blurY ? Std.parseFloat(child.att.blurY) : 0;
					var strength = child.has.strength ? Std.parseFloat(child.att.strength) : 1;
					var quality =  xmlToQuality(child);
					var inner = child.has.inner ? child.att.inner == "true" : false;
					var knockout = child.has.knockout ? child.att.knockout == "true" : false;
					var hideObject = child.has.hideObject ? child.att.hideObject == "true" : false;
					filter = DropShadow(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);

				case NODE_NAME_BLUR:
					var blurX = child.has.blurX ? Std.parseFloat(child.att.blurX) : 0;
					var blurY = child.has.blurY ? Std.parseFloat(child.att.blurY) : 0;
					var quality =  xmlToQuality(child);
					filter = Blur(blurX, blurY, quality);

				case NODE_NAME_GLOW:
					var color = child.has.color ? Std.parseInt(child.att.color) : 0;
					var alpha = child.has.alpha ? Std.parseFloat(child.att.alpha) : 1;
					var blurX = child.has.blurX ? Std.parseFloat(child.att.blurX) : 0;
					var blurY = child.has.blurY ? Std.parseFloat(child.att.blurY) : 0;
					var strength = child.has.strength ? Std.parseFloat(child.att.strength) : 1;
					var quality =  xmlToQuality(child);
					var inner = child.has.inner ? child.att.inner == "true" : false;
					var knockout = child.has.knockout ? child.att.knockout == "true" : false;
					filter = Glow(color, alpha, blurX, blurY, strength, quality, inner, knockout);

				case NODE_NAME_COLOR:
					var matrix = new Array();
					for(v in child.att.matrix.split(","))
						matrix.push(Std.parseFloat(v));
					filter = ColorMatrix(matrix);

				default:
					throw "unexpected node " + child.name;
			}
#else
			filter = null;
#end
			filters.set(child.att.ref, filter);
		}
        return filters;
    }

    function xmlToQuality(n : Fast) : Int {

    	var q : FilterQuality = Medium;

    	if (n.has.quality) {

	    	switch(n.att.quality.toUpperCase()) {

	    		case ATT_VALUE_LOW_Q:
	    			q = Low;

				case ATT_VALUE_MED_Q:
					q = Medium;

				case ATT_VALUE_HIG_Q:
					q = High;

				default:
					throw "unexpected quality value "+n.att.quality;
	    	}    		
    	}
    	return q;
    }
}