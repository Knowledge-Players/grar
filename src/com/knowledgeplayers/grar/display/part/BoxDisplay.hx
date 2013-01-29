package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.structure.part.strip.box.Box;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.event.ButtonActionEvent;

import haxe.xml.Fast;
import nme.Lib;
import nme.Assets;
import nme.display.Graphics;
import nme.display.BitmapData;

class BoxDisplay extends Sprite {
    private var resizeD: ResizeManager;
    private var contentDisplay: Fast;
    private var boxBack: Sprite;
    private var box: Box;
    private var maskW: Float;
    private var maskH: Float;
    private var maskX: Float;
    private var maskY: Float;
    private var displayObjects: Hash<DisplayObject>;

    public function new(box: Box, content: Xml): Void
    {
        super();
        this.contentDisplay = new Fast(content).node.Display;
        this.box = box;

        resizeD = ResizeManager.getInstance();

        parseBox();
    }

    private function parseBox(): Void
    {
        backOfTheBox(box.ref);

        for(element in box.items){
            if(element.name == "Background"){
                backgroundOfTheBox(element.att.Ref);
            }
            if(element.name == "Image"){
                imageOfTheBox(element.att.Ref);
            }
            if(element.name == "Text"){
                textOfTheBox(element.att.Ref);
            }
            if(element.name == "Button"){
                buttonOfTheBox(element.att.Ref);
            }
        }

        addMaskToBox();

    }

    private function addMaskToBox(): Void
    {

        var maskBG = new Sprite();
        maskBG.graphics.beginFill(0xCCCCCC);
        maskBG.graphics.drawRect(maskX, maskY, maskW, maskH);
        maskBG.graphics.endFill();

        this.mask = maskBG;
    }

    private function constructBox(): Void
    {

    }

    private function backOfTheBox(?ref: String): Void
    {

        for(node in contentDisplay.elements){

            if(node.att.Ref == ref){
                var back = new Sprite();

                var w = Std.parseFloat(node.att.Width);
                var h = Std.parseFloat(node.att.Height);
                var x = Std.parseFloat(node.att.X);
                var y = Std.parseFloat(node.att.Y);
                maskW = w;
                maskH = h;
                maskX = x;
                maskY = y;

                this.x = x;
                this.y = y;

                back.graphics.beginFill(0xCCCCCC);
                back.graphics.lineStyle(1, 0x000000);
                back.graphics.drawRect(0, 0, w, h);
                back.graphics.endFill();
                addChild(back);

            }

        }

    }

    private function backgroundOfTheBox(?ref: String): Void
    {

        for(node in contentDisplay.elements){

            if(node.att.Ref == ref){

                var url = node.att.Id;

                var bg: Bitmap = new Bitmap( Assets.getBitmapData(url));

                var w = Std.parseFloat(node.att.Width);
                var h = Std.parseFloat(node.att.Height);
                var x = Std.parseFloat(node.att.X);
                var y = Std.parseFloat(node.att.Y);
                var z = node.att.z;
                bg.x = x;
                bg.y = y;
                bg.width = w;
                bg.height = h;

                addChild(bg);
            }
        }
        // displayObjects.set(z, bgContainer);

    }

    private function imageOfTheBox(?ref: String): Void
    {

        for(node in contentDisplay.elements){
            if(node.att.Ref == ref){

                var url = node.att.Id;
                var img: Bitmap = new Bitmap(Assets.getBitmapData(url));
                var w = Std.parseFloat(node.att.Width);
                var h = Std.parseFloat(node.att.Height);
                var x = Std.parseFloat(node.att.X);
                var y = Std.parseFloat(node.att.Y);
                var z = node.att.z;
                img.x = x;
                img.y = y;
                img.width = w;
                img.height = h;

                addChild(img);
            }
        }

    }

    private function textOfTheBox(?ref: String): Void
    {

        for(node in contentDisplay.elements){
            if(node.att.Ref == ref){

                var w = Std.parseFloat(node.att.Width);
                var h = Std.parseFloat(node.att.Height);
                var x = Std.parseFloat(node.att.X);
                var y = Std.parseFloat(node.att.Y);

                var text = new ScrollPanel(w, h);
                var txt = Localiser.getInstance().getItemContent(node.att.Content);

                text.content = KpTextDownParser.parse(txt);
                text.background = node.att.Background;

                var textContainer = new Sprite();
                textContainer.x = x;
                textContainer.y = y;
                textContainer.addChild(text);

                addChild(textContainer);
            }
        }

    }

    private function buttonOfTheBox(?ref: String): Void
    {

        for(node in contentDisplay.elements){
            if(node.att.Ref == ref){
                //Lib.trace("----------- : " + node.att.Type);

                var button: DefaultButton = UiFactory.createButtonFromXml(node);

                var x = Std.parseFloat(node.att.X);
                var y = Std.parseFloat(node.att.Y);

                if(node.has.Content)
                    cast(button, TextButton).setText(Localiser.instance.getItemContent(node.att.Content));
                if(node.has.Action)
                    setButtonAction(cast(button, CustomEventButton), node.att.Action);
                else
                    button.addEventListener(ButtonActionEvent.NEXT, next);

                var buttonContainer = new Sprite();
                buttonContainer.x = x;
                buttonContainer.y = y;
                buttonContainer.addChild(button);
                addChild(buttonContainer);

                //initDisplayObject(button, buttonNode);
                /* displayObjects.set(buttonNode.att.z, button);

                resizeD.addDisplayObjects(button, buttonNode);*/
            }
        }

    }

    private function setButtonAction(button: CustomEventButton, action: String): Void
    {
        if(action.toLowerCase() == ButtonActionEvent.NEXT){
            button.addEventListener(action, next);
        }
        else{
            Lib.trace(action + ": this action is not supported for this part");
        }
    }

    private function next(event: ButtonActionEvent): Void
    {
        // Lib.trace("event : "+event);
        dispatchEvent(new ButtonActionEvent(ButtonActionEvent.NEXT, true));
    }

}