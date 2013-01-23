package com.knowledgeplayers.grar.structure.part.dialog.pattern;

import com.knowledgeplayers.grar.structure.part.dialog.item.ChoiceItem;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import com.knowledgeplayers.grar.factory.ItemFactory;
import haxe.xml.Fast;

class CollectPattern extends Pattern {
/**
 * Vertical flow of the pattern
 */
    public var verticalFlow: Array<ChoiceItem>;

    private var firstChoiceItem: Bool = true;
    private var verticalIndex: Int = 0;

    public function new(name: String)
    {
        super(name);
        verticalFlow = new Array<ChoiceItem>();
    }

    override public function init(xml: Fast): Void
    {
        for(itemNode in xml.nodes.Item){
            var item: Item = ItemFactory.createItemFromXml(itemNode);
            item.content = itemNode.att.Content;
            if(item.hasVerticalFlow())
            if(firstChoiceItem){
                patternContent.push(item);
                firstChoiceItem = false;
            }
            else
                verticalFlow.push(cast(item, ChoiceItem));
            else
                patternContent.push(item);
        }
    }

/**
 * @return the next item in the vertical flow, or null if the flow reachs its end
 */

    public function progressVertically(): Null<ChoiceItem>
    {
        var choice: ChoiceItem = null;
        if(verticalIndex < verticalFlow.length){
            choice = verticalFlow[verticalIndex];
            verticalIndex++;
        }
        return choice;
    }
}