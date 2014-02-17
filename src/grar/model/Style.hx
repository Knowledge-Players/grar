package grar.model;

import haxe.ds.StringMap;

import grar.util.ParseUtils;

#if (flash || openfl)
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.text.Font;
#end
#if flash
import flash.text.TextFormatAlign;
#end

/**
 * Style of a text
 */
class Style extends StringMap<String> {

	/**
     * Name of the style
     */
	public var name : String;

	/**
     * Icon in the style
     */
#if (flash || openfl)
	public var icon : BitmapData;
#else
	public var icon : String;
#end

	/**
     * Position of the icon
     */
	public var iconPosition : String;

	/**
    * Wheter or not the icon must be resized
    **/
	public var iconResize (default, default) : Bool;

	/**
     * Background property
     */
#if (flash || openfl)
	public var background : Bitmap;
#else
	public var background : String;
#end

	/**
    * Margin around the icon
    **/
	public var iconMargin (default, null) : Array<Float>;

	/**
     * Add a rule to the style
     * @param	name : Name of the rule
     * @param	value : Value of the rule;
     */
	public function addRule(name : String, value : String) : Void {

		set(name, value);
	}

	/**
     * Make this style inherit from the parent style
     * @param	parentName : Name of the parent style
     */
	public function inherit(parent : Style) : Void {

		if (parent == null) {

			throw "Can't inherit style for " + name + ", the parent doesn't exist.";
		}
		for (rule in parent.keys()) {

			set(rule, parent.get(rule));
		}
	}

	public function setIconMargin(string : String) : Void {

		iconMargin = new Array<Float>();

		if (string != null && string != "") {

			for (margin in string.split(" ")) {

				iconMargin.push(Std.parseFloat(margin));
			}
			ParseUtils.formatToFour(iconMargin);
		
		} else {

			iconMargin = [0, 0, 0, 0];
		}
	}

	// Getters

	/**
     * @return the font of the style
     */
#if (flash || openfl)
	public function getFont() : Null<Font> {

		return Assets.getFont(get("font"));
#else
	public function getFont() : Null<String> {
#end

		return get("font");
	}

	/**
     * @return the size of the style
     */
	public function getSize() : Null<Int> {

		return Std.parseInt(get("size"));
	}

	/**
     * @return the color of the style
     */
	public function getColor() : Null<Int> {

		return Std.parseInt(get("color"));
	}

	/**
     * @return whether or not the style is bold
     */
	public function getBold() : Null<Bool> {

		return get("bold") == "true";
	}

	/**
     * @return whether or not the style is italic
     */
	public function getItalic() : Null<Bool> {

		return get("italic") == "true";
	}

	/**
     * @return whether or not the style is underline
     */
	public function getUnderline() : Null<Bool> {

		return get("underline") == "true";
	}

	public function getCase() : Null<String> {

		return get("case");
	}

	/**
    * @return an array with line leading in 0 and paragraph leading in 1
    **/
#if js
	public function getLeading() : Array<Int> {

		var array = new Array<Int>();
#else
	public function getLeading() : Array<Float> {

		var array = new Array<Float>();
#end
		if (exists("leading")) {

			for (lead in get("leading").split(" ")) {
#if js
                array.push(Std.parseInt(lead));
#else
				array.push(Std.parseFloat(lead));
#end
			}
			if (array.length == 1) {

				array.push(array[0] * 2);
			}
		
		} else {

			array = [0, 0];
		}
		return array;
	}

	/**
    * @return the alignment of the text
    **/

	public function getAlignment() : Dynamic {

		// Type Conflict between Flash and native for TextFormatAlign
		var alignment : Dynamic = null;
		
		if (exists("alignment")) {
#if flash
            alignment = Type.createEnum(TextFormatAlign, get("alignment").toUpperCase());
#else
			alignment = get("alignment").toUpperCase();
#end
		
		} else {
#if flash
            alignment = TextFormatAlign.LEFT;
#else
			alignment = "LEFT";
#end
		}
		return alignment;
	}

	public function getPadding() : Array<Float> {

		var array : Array<Float> = new Array();
		
		if (exists("padding")) {

			for (pad in get("padding").split(" ")) {

				array.push(Std.parseFloat(pad));
			}
			switch (array.length) {

				case 1:
					while (array.length < 4) {

						array.push(array[0]);
					}
				
				case 2:
					array.push(array[0]);
					array.push(array[1]);
			}
		
		} else {

			array = [0, 0, 0, 0];
		}
		return array;
	}
}