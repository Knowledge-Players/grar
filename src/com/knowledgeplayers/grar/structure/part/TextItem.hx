package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.display.element.TokenDisplay;
import haxe.FastList;
import haxe.xml.Fast;
import nme.Lib;

class TextItem implements PartElement {
    /**
     * Text of the item
     */
    public var content (default, default):String;

    /**
     * Character who says this text
     */
    public var author (default, default):String;

    /**
     * Transition between this item and the one before
     */
    public var transition (default, default):String;

    /**
    * Background when the item is displayed
**/
    public var background (default, default):String;

    /**
    * ID of the button that will appear with this item
**/
    public var button (default, default):{ref:String, content:String};

    /**
    * Unique ref that will match the display
**/
    public var ref (default, default):String;

    /**
    * Items associated with this item
    **/
    public var items (default, default):FastList<String>;

    public var token:Token;

    /**
     * Constructor
     * @param	xml : fast xml node with structure info
     * @param	content : text of the item
     */

    public function new(?xml:Fast, content:String = "")
    {
        items = new FastList<String>();
        if(xml != null){
            if(xml.has.content)
                this.content = xml.att.content;
            if(xml.has.author)
                author = xml.att.author;
            if(xml.has.transition)
                transition = xml.att.transition;
            if(xml.has.ref)
                ref = xml.att.ref;
            if(xml.has.background)
                background = xml.att.background;
            if(xml.hasNode.Token)
               token = new Token(xml.node.Token);

            for(item in xml.nodes.Item){
                items.add(item.att.ref);
            }
        }
        else{
            this.content = content;
        }

    }

    /**
     * @return true if the item starts a vertical flow
     */

    public function hasVerticalFlow():Bool
    {
        return false;
    }

    /**
     * @return true if the item starts an activity
     */

    public function hasActivity():Bool
    {
        return false;
    }
    /**
     * @return true if the item starts an activity
     */
    public function hasToken():Bool
    {

        return token != null;
    }

    /**
    * @return true
**/

    public function isText():Bool
    {
        return true;
    }

    /**
    * @return false
**/

    public function isActivity():Bool
    {
        return false;
    }

    /**
    * @return false
**/

    public function isPattern():Bool
    {
        return false;
    }

    /**
    * @return false
**/

    public function isPart():Bool
    {
        return false;
    }

}