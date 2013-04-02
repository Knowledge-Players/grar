package com.knowledgeplayers.grar.display.activity.quizz;

import Std;
import Std;
import haxe.xml.Fast;
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
import com.knowledgeplayers.grar.util.DisplayUtils;

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

    public function new(item:QuizzItem, ?xmlTemplate:Fast, ?width:Float, ?height:Float, ?style:String)
    {
        super();

        model = item;
        buttonMode = true;
        correction = new Bitmap();
        checkIcon = new Bitmap();
        if(width != null && height != null){
            text = new ScrollPanel(width, height, style != null ? style : (xmlTemplate.has.style ? xmlTemplate.att.style : null));
        }
        else{
            text = new ScrollPanel(Std.parseFloat(xmlTemplate.att.width), Std.parseFloat(xmlTemplate.att.height), style != null ? style : (xmlTemplate.has.style ? xmlTemplate.att.style : null));
        }

        if(xmlTemplate != null){
            if(xmlTemplate.has.spritesheet)
                setIcon(xmlTemplate.att.id, xmlTemplate.att.spritesheet);
            else if(xmlTemplate.has.id)
                setIcon(xmlTemplate.att.id);
            text.x = Std.parseFloat(xmlTemplate.att.contentX);
            correction.x = Std.parseFloat(xmlTemplate.att.correctionX);
            checkIcon.x = Std.parseFloat(xmlTemplate.att.checkX);

            if(xmlTemplate.has.background){
                DisplayUtils.setBackground(xmlTemplate.att.background, this);
            }
        }

        var content = Localiser.getInstance().getItemContent(model.content);

        text.setContent(content);

        addEventListener(MouseEvent.CLICK, onClick);

        addChild(text);
        addChild(correction);

        checkIcon.y = this.height / 2 - checkIcon.height / 2;
        addChild(checkIcon);
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
        checkIcon.bitmapData = DisplayUtils.getBitmapDataFromLayer(layer, id);
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