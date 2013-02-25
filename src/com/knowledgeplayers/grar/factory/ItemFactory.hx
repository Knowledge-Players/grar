package com.knowledgeplayers.grar.factory;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import com.knowledgeplayers.grar.structure.part.TextItem;
import haxe.xml.Fast;
import nme.Lib;

/**
 * Factory to create dialog items
 * @author jbrichardet
 */

class ItemFactory {

    private function new()
    {

    }

    /**
     * Create an item
     * @param	itemType : Type of the item
     * @param	xml : Fast xml node with infos
     * @return an item, or null if the type is not supported
     */

    public static function createItem(itemType: String, ?xml: Fast): Null<TextItem>
    {
        var creation: TextItem = null;
        switch(itemType.toLowerCase()) {
            case "": creation = new TextItem(xml);
            case "activity": creation = new RemarkableEvent(xml);
            default: Lib.trace("[ItemFactory] " + itemType + ": Unsupported item type");
        }

        return creation;
    }

    /**
     * Create an item from XML infos
     * @param	xml : Fast xml node with infos
     * @return an item, or null if the type is not supported
     */

    public static function createItemFromXml(xml: Fast): Null<TextItem>
    {
        return createItem(xml.att.type, xml);
    }
}