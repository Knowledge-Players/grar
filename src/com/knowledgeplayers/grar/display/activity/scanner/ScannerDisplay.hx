package com.knowledgeplayers.grar.display.activity.scanner;

import IntHash;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import Lambda;
import nme.display.DisplayObject;
import nme.Lib;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.Assets;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.event.PartEvent;
import nme.events.Event;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.scanner.Scanner;

class ScannerDisplay extends ActivityDisplay {

    /**
* Instance
**/
    public static var instance (getInstance, null): ScannerDisplay;

    /**
* The scanner text area
**/
    public var textAreas (default, null): Hash<ScrollPanel>;

    private var pointRadius: Float = 0;
    private var pointGraphics: Hash<String>;
    private var textZone: ScrollPanel;
    private var lineHeight: Float;

    /**
* @return the instance
**/

    public static function getInstance(): ScannerDisplay
    {
        if(instance == null)
            instance = new ScannerDisplay();
        return instance;
    }

    // Private

    override private function onModelComplete(e: LocaleEvent): Void
    {
        var yOffset: Float = 0;
        var textSprite = new Sprite();
        for(point in cast(model, Scanner).pointsMap){
            var text = new ScrollPanel(textZone.width, lineHeight);
            text.y = yOffset;
            yOffset += lineHeight;
            textAreas.set(point.content, text);
            textSprite.addChild(text);
            var pointDisplay = new PointDisplay(pointGraphics, pointRadius, point);
            pointDisplay.x = point.x;
            pointDisplay.y = point.y;
            pointDisplay.alpha = cast(model, Scanner).pointVisible ? 1 : 0;
            addChild(pointDisplay);
        }
        textZone.content = textSprite;

        super.onModelComplete(e);
    }

    override private function parseContent(content: Fast): Void
    {
        for(child in content.elements){
            if(child.name.toLowerCase() == "background"){
                var background = new Bitmap(Assets.getBitmapData(child.att.id));
                ResizeManager.instance.addDisplayObjects(background, child);
                addChild(background);
            }
            if(child.name.toLowerCase() == "text"){
                textZone = new ScrollPanel(Std.parseFloat(child.att.width), Std.parseFloat(child.att.height));
                textZone.x = Std.parseFloat(child.att.x);
                textZone.y = Std.parseFloat(child.att.y);
                textZone.setBackground(child.att.background);
                lineHeight = Std.parseFloat(child.att.lineHeight);
                addChild(textZone);
            }
        }

        pointGraphics = new Hash<String>();
        for(point in content.nodes.Point){
            if(point.has.color){
                pointRadius = Std.parseInt(point.att.radius);
                pointGraphics.set(point.att.state, point.att.color);
            }
            else
                pointGraphics.set(point.att.state, point.att.img);
        }
    }

    private function new()
    {
        super();
        textAreas = new Hash<ScrollPanel>();
    }
}