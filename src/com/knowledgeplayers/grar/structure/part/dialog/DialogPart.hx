package com.knowledgeplayers.grar.structure.part.dialog;

import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.dialog.item.ChoiceItem;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.CollectPattern;
import haxe.xml.Fast;
import nme.Lib;

import com.knowledgeplayers.grar.structure.part.StructurePart;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.Pattern;
import com.knowledgeplayers.grar.factory.PatternFactory;

/**
 * ...
 * @author jbrichardet
 */

class DialogPart extends StructurePart {

    public function new()
    {
        super();
        characters = new Hash<Character>();
        patterns = new Array<Pattern>();
    }

    override public function getNextElement(): Null<Dynamic>
    {
        var item: TextItem = null;
        if(elemIndex < patterns.length){
            item = patterns[elemIndex].getNextItem();
            if(item == null){
                elemIndex++;
                return getNextElement();
            }
        }
        if(item == null){
            isDone = true;
        }

        return item;
    }

    override public function isDialog(): Bool
    {
        return true;

    }

    /**
     * @return the next item in a vertical flow, or null if the flow reach its end
     */

    public function getNextVerticalIndex(): Null<ChoiceItem>
    {
        var item: ChoiceItem = null;
        if(Std.is(patterns[elemIndex], CollectPattern)){
            var collect: CollectPattern = cast(patterns[elemIndex], CollectPattern);
            item = collect.progressVertically();

            if(item != null && item.hasToken()){
                var event = new TokenEvent(TokenEvent.ADD, item.tokenId, item.tokenType, item.target);
                dispatchEvent(event);
            }
        }

        return item;
    }

    // Private

    override private function parseContent(content: Xml): Void
    {

        super.parseContent(content);
    }

}