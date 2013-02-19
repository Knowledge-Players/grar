package com.knowledgeplayers.grar.structure.part;

import haxe.xml.Fast;
import nme.Lib;

class TextItem implements PartElement {
    /**
     * Text of the item
     */
    public var content (default, default): String;

    /**
     * Character who says this text
     */
    public var author (default, default): String;

    /**
     * Position of the author
     */
    public var direction (default, default): String;

    /**
    * Background when the item is displayed
**/
    public var background (default, default): String;

    /**
    * ID of the button that will appear with this item
**/
    public var button (default, default): String;

    /**
    * Unique ref that will match the display
**/
    public var ref (default, default): String;
    /**
     * Constructor
     * @param	xml : fast xml node with structure info
     * @param	content : text of the item
     */

    public function new(?xml: Fast, content: String = "")
    {
        if(xml != null){
            if(xml.has.content)
                this.content = xml.att.content;
            if(xml.has.author)
                author = xml.att.author;
            if(xml.has.direction)
                direction = xml.att.direction;
            if(xml.has.ref)
                ref = xml.att.ref;
            if(xml.has.background)
                background = xml.att.background;
        }
        else{
            this.content = content;
        }
    }

    /**
     * @return true if the item starts a vertical flow
     */

    public function hasVerticalFlow(): Bool
    {
        return false;
    }

    /**
     * @return true if the item starts an activity
     */

    public function hasActivity(): Bool
    {
        return false;
    }

    /**
    * @return true
**/

    public function isText(): Bool
    {
        return true;
    }

    /**
    * @return false
**/

    public function isActivity(): Bool
    {
        return false;
    }

    /**
    * @return false
**/

    public function isPattern(): Bool
    {
        return false;
    }

    /**
    * @return false
**/

    public function isPart(): Bool
    {
        return false;
    }

}