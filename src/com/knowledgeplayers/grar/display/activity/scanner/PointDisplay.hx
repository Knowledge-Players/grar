package com.knowledgeplayers.grar.display.activity.scanner;

import com.knowledgeplayers.grar.structure.activity.scanner.ScannerPoint;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import nme.events.MouseEvent;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;
class PointDisplay extends Sprite {
    private var graphic: Hash<String>;
    private var bitmap: Bitmap;
    private var point: ScannerPoint;

    public function new(graphic: Hash<String>, radius: Float = 0, point: ScannerPoint)
    {
        super();
        this.graphic = graphic;
        this.point = point;
        if(Std.parseInt(graphic.get("unseen")) != null){
            graphics.beginFill(Std.parseInt(graphic.get("unseen")));
            graphics.drawCircle(radius / 2, radius / 2, radius);
            graphics.endFill();
        }
        else{
            bitmap = new Bitmap(Assets.getBitmapData(graphic.get("unseen")));
            addChild(bitmap);
        }

        addEventListener(MouseEvent.MOUSE_OVER, onOver);
        addEventListener(MouseEvent.MOUSE_OUT, onOut);
    }

    public function init(): Void
    {

    }

    // Handler

    private function onOver(e: MouseEvent): Void
    {
        alpha = 1;
        if(graphic.exists("over"))
            bitmap.bitmapData = Assets.getBitmapData(graphic.get("over"));
        var text = Localiser.instance.getItemContent(point.content);
        cast(parent, ScannerDisplay).textAreas.get(point.content).setContent(KpTextDownParser.parse(text));
    }

    private function onOut(e: MouseEvent): Void
    {
        if(graphic.exists("seen"))
            bitmap.bitmapData = Assets.getBitmapData(graphic.get("seen"));
    }
}
