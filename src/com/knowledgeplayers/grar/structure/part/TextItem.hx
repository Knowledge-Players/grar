package com.knowledgeplayers.grar.structure.part;

import haxe.FastList;
import haxe.xml.Fast;

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
    * Graphicals items associated with this item
    **/
    public var items (default, default):Array<{ref:String,transition:String}>;

    /**
    * Reference to the token in this item
    **/
    public var token(default, null):String;

    /**
    * Sound to play during this item
    **/
    public var sound (default, default):String;

    /**
     * Constructor
     * @param	xml : fast xml node with structure info
     * @param	content : text of the item
     */

    public function new(?xml:Fast, content:String = "")
    {
        items = new Array<{ref:String,transition:String}>();
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
                token = xml.node.Token.att.ref;
            if(xml.hasNode.Button)
                button = {ref: xml.node.Button.att.ref, content: xml.node.Button.has.content ? xml.node.Button.att.content : null};
            if(xml.hasNode.Sound)
                sound = xml.node.Sound.att.src;

            for(item in xml.nodes.Item){
                var transition:String=null;

                if(item.has.transition){
                    transition = item.att.transition;
                }

                items.push({ref:item.att.ref,transition:transition});
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