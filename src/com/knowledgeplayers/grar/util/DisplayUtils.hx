package com.knowledgeplayers.grar.util;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;

/**
 * Utility class for display
 */
class DisplayUtils {
    private function new()
    {}

    /**
     * Get the pressed ID of a button
     * @param	buttonId : ID of the button
     * @return the pressed ID for this button
     */

    public static function getPressedId(buttonId: String): String
    {
        var strings: Array<String> = buttonId.split(".");
        return strings[0] + "_pressed." + strings[1];
    }

    /**
    * Set the background of a sprite
    * @param bkg : String with an Int representing the color of the background or an ID of the BitmapData
    * @param container : Sprite where the background will be set
    * @param width : Force width of the background. If 0, the width will be the width of the container
    * @param height : Force height of the background. If 0, the height will be the height of the container
    * @return the bitmap of the background if there was any
**/

    public static function setBackground(bkg: String, container: Sprite, width: Float = 0, height: Float = 0): Null<Bitmap>
    {
        /*if(width == 0)
            width = container.width;
        if(height == 0)
            height = container.height;*/
        if(Std.parseInt(bkg) != null){
            container.graphics.beginFill(Std.parseInt(bkg));
            container.graphics.drawRect(0, 0, width, height);
            container.graphics.endFill();
            return null;
        }
        else{
            var bitmap = new Bitmap(Assets.getBitmapData(bkg));
            if(width != 0)
                bitmap.width = width;
            if(height != 0)
                bitmap.height = height;
            container.addChildAt(bitmap, 0);
            return bitmap;
        }
    }
}