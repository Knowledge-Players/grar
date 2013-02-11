package com.knowledgeplayers.grar.display.activity.quizz;

import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.quizz.QuizzItem;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.Lib;

/**
 * Display for quizz propositions
 * @author jbrichardet
 */

class QuizzItemDisplay extends Sprite {
    /**
     * Icon for the item
     */
    public var checkIcon (default, null): Bitmap;

    /**
     * Icon to show good answers
     */
    public var correction (default, null): Bitmap;

    /**
    * Text of the answer
**/
    public var text (default, null): ScrollPanel;

    private var model: QuizzItem;

    /**
     * Construcor
     * @param	item : Model to display
     */

    public function new(item: QuizzItem)
    {
        super();

        model = item;

        buttonMode = true;

        var content = Localiser.getInstance().getItemContent(model.content);
        var contentParsed = KpTextDownParser.parse(content);

        text = new ScrollPanel(contentParsed.width, 50);

        text.content = contentParsed;

        correction = new Bitmap();

        checkIcon = new Bitmap(QuizzDisplay.instance.items.get("uncheck"));

        addEventListener(MouseEvent.CLICK, onClick);

        addChild(checkIcon);
        addChild(text);
        addChild(correction);
    }

    /**
     * Change the icon to iconCheckRight if the answer is correct
     */

    public function validate(): Void
    {
        if(model.isChecked){
            if(model.isAnswer)
                checkIcon.bitmapData = QuizzDisplay.instance.items.get("checkright");
            else
                checkIcon.bitmapData = QuizzDisplay.instance.items.get("checkwrong");
        }
    }

    /**
     * Display the correction icon if the item is a right answer
     */

    public function displayCorrection(): Void
    {
        if(model.isAnswer)
            correction.bitmapData = QuizzDisplay.instance.items.get("good");
    }

    // Handlers

    private function onClick(event: MouseEvent): Void
    {
        // Quizz is locked, no input accepted
        if(QuizzDisplay.instance.locked)
            return;

        if(model.isChecked){
            checkIcon.bitmapData = QuizzDisplay.instance.items.get("uncheck");
            model.isChecked = false;
        }
        else{
            checkIcon.bitmapData = QuizzDisplay.instance.items.get("check");
            model.isChecked = true;
        }
    }
}