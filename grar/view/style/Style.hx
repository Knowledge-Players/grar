package grar.view.style;

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

typedef StyleData = {

	var name : String;
	var values : StringMap<String>;
#if (flash || openfl)
	var icon : BitmapData;
#end
	var iconSrc : Null<String>;
	var iconPosition : Null<String>;
	var iconMargin : Null<Array<Float>>;
#if (flash || openfl)
	var background : Bitmap;
#end
	var backgroundSrc : Null<String>;
}

/**
 * Style of a text
 */
class Style {

	public function new(sd : StyleData) {

		this.name = sd.name;
		this.values = sd.values;
#if (flash || openfl)
		this.icon = sd.icon;
#end
		this.iconSrc = sd.iconSrc;
		this.iconPosition = sd.iconPosition;
		this.iconMargin = sd.iconMargin;
#if (flash || openfl)
		this.background = sd.background;
#end
		this.backgroundSrc = sd.backgroundSrc;
	}

	/**
     * Name of the style
     */
	public var name : String;

	/**
     * Icon in the style
     */
#if (flash || openfl)
	public var icon : BitmapData;
#end
	public var iconSrc : String;

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
#end
	public var backgroundSrc : String;

	/**
    * Margin around the icon
    **/
	public var iconMargin (default, null) : Array<Float>;

	/**
    * Style values
    **/
	public var values (default, null) : StringMap<String>;


	///
	// GETTER / SETTER
	//

	/**
     * @return the font of the style
     */
// FIXME #if (flash || openfl)
// FIXME 	public function getFont() : Null<Font> {

// FIXME 		return Assets.getFont(get("font"));
// FIXME #else
	public function getFont() : Null<String> {
// FIXME #end

		return values.get("font"); // FIXME
	}

	/**
     * @return the size of the style
     */
	public function getSize() : Null<Int> {

		return Std.parseInt(values.get("size"));
	}

	/**
     * @return the color of the style
     */
	public function getColor() : Null<Int> {

		return Std.parseInt(values.get("color"));
	}

	/**
     * @return whether or not the style is bold
     */
	public function getBold() : Null<Bool> {

		return values.get("bold") == "true";
	}

	/**
     * @return whether or not the style is italic
     */
	public function getItalic() : Null<Bool> {

		return values.get("italic") == "true";
	}

	/**
     * @return whether or not the style is underline
     */
	public function getUnderline() : Null<Bool> {

		return values.get("underline") == "true";
	}

	public function getCase() : Null<String> {

		return values.get("case");
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
		if (values.exists("leading")) {

			for (lead in values.get("leading").split(" ")) {
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
		
		if (values.exists("alignment")) {
#if flash
            alignment = Type.createEnum(TextFormatAlign, values.get("alignment").toUpperCase());
#else
			alignment = values.get("alignment").toUpperCase();
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
		
		if (values.exists("padding")) {

			for (pad in values.get("padding").split(" ")) {

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