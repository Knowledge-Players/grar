package com.knowledgeplayers.grar.display;
/**
 * Manage the most frequently used filters
 */
import nme.filters.DropShadowFilter;
import nme.filters.BitmapFilter;
class FilterManager {

    /**
    * Create a bitmap filter from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a bitmap filter
    **/
    public static function applyFilter(_filter:String):BitmapFilter{
        var filterNode =_filter.split(":");

        var filter:BitmapFilter =
        switch(Std.string(filterNode[0]).toLowerCase()){
            case "dropshadow":
                setDropShadowFilter(filterNode[1]);

        }
        return filter;
    }

     private static function setDropShadowFilter(_params:String):DropShadowFilter{

        var params = _params.split(",");
        var filter:DropShadowFilter = new DropShadowFilter(Std.parseFloat(params[0]), Std.parseFloat(params[1]), Std.parseInt(params[2]), Std.parseFloat(params[3]), Std.parseFloat(params[4]), Std.parseFloat(params[5]));
        return filter;
     }

}