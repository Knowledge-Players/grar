package com.knowledgeplayers.grar.structure.part.dialog;

import Std;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.dialog.item.ChoiceItem;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.CollectPattern;
import haxe.xml.Fast;
import nme.Lib;

import com.knowledgeplayers.grar.structure.part.StructurePart;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.factory.PatternFactory;

/**
 * ...
 * @author jbrichardet
 */



class DialogPart extends StructurePart {

    public var arrayTexts:Array<Fast>;
    public var arrayElements:Array<Fast>;

    public function new()
    {
        super();
        arrayTexts = new Array<Fast>();
        arrayElements = new Array<Fast>();
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
        var collect: CollectPattern = null;
        if(Std.is(elements[elemIndex], CollectPattern))
            collect = cast(elements[elemIndex], CollectPattern);
        else
            return null;

        var item: ChoiceItem = null;
        item = collect.progressVertically();

        if(item != null && item.hasToken()){
            var event = new TokenEvent(TokenEvent.ADD, item.tokenId, item.tokenType, item.target);
            dispatchEvent(event);
        }

        return item;
    }

    override public function restart(): Void
    {
        super.restart();
        if(elements[elemIndex].isPattern())
            cast(elements[elemIndex], Pattern).restart();
    }

    // Private

    override private function parseContent(content: Xml): Void
    {
        super.parseContent(content);


        var partFast: Fast = new Fast(content).node.Part;

        for (elment in partFast.elements)
            {
                arrayElements.push(elment);

                if (elment.name == "Pattern"){
                    var pattern: Pattern = PatternFactory.createPatternFromXml(elment);
                    pattern.init(elment);
                    elements.push(pattern);
                }
                if (elment.name == "Text"){

                    arrayTexts.push(elment);
                    }
            }


    }

}