package com.knowledgeplayers.grar.structure.part;

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

    public function new(name: String)
    {
        this.name = name;
        patternContent = new Array<TextItem>();
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

}