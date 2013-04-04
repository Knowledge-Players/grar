package com.knowledgeplayers.grar.display.style;

import nme.text.TextFormatAlign;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.text.Font;
import nme.Assets;

/**
 * Style of a text
 */
class Style extends Hash<String> {
    /**
     * Name of the style
     */
    public var name:String;

    /**
     * Icon in the style
     */
    public var icon:BitmapData;

    /**
     * Position of the icon
     */
    public var iconPosition:String;

    /**
    * Wheter or not the icon must be resized
    **/
    public var iconResize (default, default):Bool;

    /**
     * Background propertie
     */
    public var background:Bitmap;

    /**
     * Add a rule to the style
     * @param	name : Name of the rule
     * @param	value : Value of the rule;
     */

    public function addRule(name:String, value:String):Void
    {
        set(name, value);
    }

    /**
     * Make this style inherit from the parent style
     * @param	parentName : Name of the parent style
     */

    public function inherit(parent:Style):Void
    {
        if(parent == null)
            throw "Can't inherit style for " + name + ", the parent doesn't exist";
        for(rule in parent.keys()){
            set(rule, parent.get(rule));
        }
    }

    /**
     * @return the font of the style
     */

    public function getFont():Null<Font>
    {
        return Assets.getFont(get("font"));
    }

    /**
     * @return the size of the style
     */

    public function getSize():Null<Int>
    {
        return Std.parseInt(get("size"));
    }

    /**
     * @return the color of the style
     */

    public function getColor():Null<Int>
    {
        return Std.parseInt(get("color"));
    }

    /**
     * @return whether or not the style is bold
     */

    public function getBold():Null<Bool>
    {
        return get("bold") == "true";
    }

    /**
     * @return whether or not the style is italic
     */

    public function getItalic():Null<Bool>
    {
        return get("italic") == "true";
    }

    /**
     * @return whether or not the style is underline
     */

    public function getUnderline():Null<Bool>
    {
        return get("underline") == "true";
    }

    /**
    * @return the alignment of the text
    **/

    public function getAlignment():Null<Dynamic>
    {
        // Type Conflict between Flash and native for TextFormatAlign
        var alignment:Dynamic = null;
        if(exists("alignment")){
            #if flash
                alignment = Type.createEnum(TextFormatAlign, get("alignment").toUpperCase());
            #else
            alignment = get("alignment").toUpperCase();
            #end
        }
        return alignment;
    }

    public function getPadding():Array<Float>
    {
        var array = new Array<Float>();
        if(get("padding") != null){
            for(pad in get("padding").split(" ")){
                array.push(Std.parseFloat(pad));
            }
            switch(array.length){
                case 0:
                    array = [0,0,0,0];
                case 1:
                    while(array.length < 4)
                        array.push(array[0]);
                case 2:
                    array.push(array[0]);
                    array.push(array[1]);
            }
        }
        return array;
    }
}