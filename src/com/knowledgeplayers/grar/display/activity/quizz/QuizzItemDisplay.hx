package com.knowledgeplayers.grar.display.activity.quizz;

import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.quizz.QuizzItem;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * Display for quizz propositions
 * @author jbrichardet
 */

class QuizzItemDisplay extends Sprite {
    /**
     * Icon for the item
     */
    public var checkIcon (default, null):Bitmap;

    /**
     * Icon to show good answers
     */
    public var correction (default, null):Bitmap;

    /**
    * Text of the answer
    **/
    public var text (default, null):ScrollPanel;

    private var model:QuizzItem;
    private var checkIconRef:String;
    private var spritesheetRef:String;

    /**
     * Construcor
     * @param	item : Model to display
     */

    public function new(item:QuizzItem)
    {
        super();

        model = item;

        buttonMode = true;

        var content = Localiser.getInstance().getItemContent(model.content);
        var contentParsed = KpTextDownParser.parse(content);

        text = new ScrollPanel(contentParsed.width, 50);

        text.content = contentParsed;

        correction = new Bitmap();

        checkIcon = new Bitmap();

        addEventListener(MouseEvent.CLICK, onClick);

        addChild(checkIcon);
        addChild(text);
        addChild(correction);
    }

    /**
     * Change the icon to iconCheckRight if the answer is correct
     */

    public function validate():Void
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

    public function displayCorrection():Void
    {
        if(model.isAnswer)
            correction.bitmapData = QuizzDisplay.instance.items.get("good");
    }

    /**
    * Set the icon for the item
    * @param    id : Id of the tile used for the icon
    **/

    public function setIcon(id:String, ?spritesheet:String):Void
    {
        if(checkIconRef == null)
            checkIconRef = id;
        spritesheetRef = spritesheet;
        var layer:TileLayer;
        if(spritesheetRef != null)
            layer = new TileLayer(QuizzDisplay.instance.spritesheets.get(spritesheetRef));
        else
            layer = new TileLayer(UiFactory.tilesheet);
        var icon = new TileSprite(id);
        layer.addChild(icon);
        layer.render();
        checkIcon.bitmapData = icon.bmp.bitmapData;
    }

    // Handlers

    private function onClick(event:MouseEvent):Void
    {
        // Quizz is locked, no input accepted
        if(QuizzDisplay.instance.locked)
            return;

        if(model.isChecked){
            setIcon(checkIconRef, spritesheetRef);
            model.isChecked = false;
        }
        else{
            setIcon(checkIconRef + "_active", spritesheetRef);
            model.isChecked = true;
        }
    }
}