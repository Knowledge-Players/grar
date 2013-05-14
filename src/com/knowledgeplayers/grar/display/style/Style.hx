package com.knowledgeplayers.grar.display.style;

import Array;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.text.Font;
#if flash
import nme.text.TextFormatAlign;
#end

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
    * Margin around the icon
    **/
	public var iconMargin (default, null):Array<Float>;

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

	public function setIconMargin(string:String):Void
	{
		iconMargin = new Array<Float>();
		if(string != null && string != ""){
			for(margin in string.split(" ")){
				iconMargin.push(Std.parseFloat(margin));
			}
			switch(iconMargin.length){
				case 1:
					while(iconMargin.length < 4)
						iconMargin.push(iconMargin[0]);
				case 2:
					iconMargin.push(iconMargin[0]);
					iconMargin.push(iconMargin[1]);
			}
		}
		else{
			iconMargin = [0, 0, 0, 0];
		}
	}

	// Getters

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

	public function getCase():Null<String>
	{
		return get("case");
	}

	/**
    * @return an array with line leading in 0 and paragraph leading in 1
    **/
	#if js
	public function getLeading():Array<Int>{
		var array = new Array<Int>();
	#else

	public function getLeading():Array<Float>
	{
		var array = new Array<Float>();
		#end
		if(exists("leading")){
			for(lead in get("leading").split(" ")){
				#if js
                    array.push(Std.parseInt(lead));
                #else
				array.push(Std.parseFloat(lead));
				#end
			}
			if(array.length == 1)
				array.push(array[0] * 2);
		}
		else{
			array = [0, 0];
		}
		return array;
	}

	/**
    * @return the alignment of the text
    **/

	public function getAlignment():Dynamic
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
		else{
			#if flash
                alignment = TextFormatAlign.LEFT;
            #else
			alignment = "LEFT";
			#end
		}
		return alignment;
	}

	public function getPadding():Array<Float>
	{
		var array = new Array<Float>();
		if(exists("padding")){
			for(pad in get("padding").split(" ")){
				array.push(Std.parseFloat(pad));
			}
			switch(array.length){
				case 1:
					while(array.length < 4)
						array.push(array[0]);
				case 2:
					array.push(array[0]);
					array.push(array[1]);
			}
		}
		else{
			array = [0, 0, 0, 0];
		}
		return array;
	}
}