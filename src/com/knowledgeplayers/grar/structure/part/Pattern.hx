package com.knowledgeplayers.grar.structure.part;

import nme.Lib;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.factory.ItemFactory;
import com.knowledgeplayers.grar.structure.part.TextItem;
import haxe.xml.Fast;

class Pattern implements PartElement {
    /**
     * Array of item composing the pattern
     */
    public var patternContent (default, default): Array<TextItem>;

    /**
     * Name of the pattern
     */
    public var name (default, default): String;

    /**
    * Current item index
**/
    public var itemIndex (default, default): Int;

    /**
    * Id of the next pattern
**/
    public var nextPattern (default, default): String;

    /**
    * Buttons for this pattern
**/
    public var buttons (default, null): Hash<String>;

    /**
    * Constructor
    * @param name : Name of the pattern
**/

    public function new(name: String)
    {
        this.name = name;
        patternContent = new Array<TextItem>();
        buttons = new Hash<String>();
        restart();
    }

    /**
     * Init the pattern with an XML node
     * @param	xml : fast xml node with structure infos
     */

    public function init(xml: Fast): Void
    {
        for(itemNode in xml.nodes.Text){
            var item: TextItem = ItemFactory.createItemFromXml(itemNode);
            patternContent.push(item);

        }
        for(child in xml.elements){
            if(child.name.toLowerCase() == "button" || child.name.toLowerCase() == "choice")
                buttons.set(child.att.ref, child.att.content);
        }
        nextPattern = xml.att.next;
    }

    /**
     * @return the next item in the pattern, or null if the pattern reachs its end
     */

    public function getNextItem(): Null<TextItem>
    {
        if(itemIndex < patternContent.length){
            itemIndex++;
            return patternContent[itemIndex - 1];
        }
        else
            return null;
    }

    /**
    * Restart a pattern
**/

    public function restart(): Void
    {
        itemIndex = 0;
    }

    /**
    * @return whether this pattern has choice or not
**/

    public function hasChoices(): Bool
    {
        return false;
    }

    // PartElement implementation

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

    public function isText(): Bool
    {
        return false;
    }

    /**
    * @return true
**/

    public function isPattern(): Bool
    {
        return true;
    }

    /**
    * @return false
**/

    public function isPart(): Bool
    {
        return false;
    }

}