package com.knowledgeplayers.grar.display.activity.scanner;

import com.knowledgeplayers.grar.util.LoadData;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.display.activity.scanner.PointDisplay.PointStyle;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
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

    private var textAreas: Hash<ScrollPanel>;
    private var pointStyles: Hash<PointStyle>;
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

    public function setText(textId: String, content: Sprite): Void
    {
        textAreas.get(textId).content = content;
        addChild(textAreas.get(textId));
    }

    // Private

    override private function onModelComplete(e: LocaleEvent): Void
    {
        for(point in cast(model, Scanner).pointsMap){
            var pointDisplay = new PointDisplay(pointStyles.get(point.ref), point);
            pointDisplay.x = point.x;
            pointDisplay.y = point.y;
            pointDisplay.alpha = cast(model, Scanner).pointVisible ? 1 : 0;
            addChild(pointDisplay);
        }
        super.onModelComplete(e);
    }

    override private function parseContent(content: Fast): Void
    {
        for(child in content.elements){
            if(child.name.toLowerCase() == "background"){

                var bmp = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(child.att.src),Bitmap).bitmapData);
                var background = bmp;
                ResizeManager.instance.addDisplayObjects(background, child);
                addChild(background);
            }
            if(child.name.toLowerCase() == "text"){
                var textZone = new ScrollPanel(Std.parseFloat(child.att.width), Std.parseFloat(child.att.height));
                textZone.x = Std.parseFloat(child.att.x);
                textZone.y = Std.parseFloat(child.att.y);
                textZone.setBackground(child.att.background);
                textAreas.set(child.att.ref, textZone);
            }
        }

        for(point in content.nodes.Point){
            if(!pointStyles.exists(point.att.ref)){
                pointStyles.set(point.att.ref, new PointStyle());
            }
            if(point.has.radius)
                pointStyles.get(point.att.ref).radius = Std.parseInt(point.att.radius);
            pointStyles.get(point.att.ref).addGraphic(point.att.state, point.att.src);
        }
    }

    private function new()
    {
        super();
        textAreas = new Hash<ScrollPanel>();
        pointStyles = new Hash<PointStyle>();
    }
}