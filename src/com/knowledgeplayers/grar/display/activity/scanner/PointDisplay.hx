package com.knowledgeplayers.grar.display.activity.scanner;

import String;
import nme.Lib;
import com.knowledgeplayers.grar.structure.activity.scanner.ScannerPoint;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import nme.events.MouseEvent;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;

class PointDisplay extends Sprite {

    private var style: PointStyle;
    private var bitmap: Bitmap;
    private var point: ScannerPoint;

    /**
    * Constructor
    * @param graphic : Set of the graphics for the different states of the point
    * @param radius : Radius of the point in pixel
    * @param point : Model of the display
**/

    public function new(style: PointStyle, point: ScannerPoint)
    {
        super();
        this.style = style;
        this.point = point;
        bitmap = new Bitmap();
        setGraphic("unseen");
        addChild(bitmap);

        addEventListener(MouseEvent.MOUSE_OVER, onOver);
        addEventListener(MouseEvent.MOUSE_OUT, onOut);
    }

    // Handler

    private function setGraphic(state: String): Void
    {
        if(!style.graphics.exists(state))
            return;

        if(Std.parseInt(style.graphics.get(state)) != null){
            graphics.beginFill(Std.parseInt(style.graphics.get(state)));
            graphics.drawCircle(style.radius / 2, style.radius / 2, style.radius);
            graphics.endFill();
        }
        else{
            bitmap.bitmapData = Assets.getBitmapData(style.graphics.get(state));
        }
    }

    private function onOver(e: MouseEvent): Void
    {
        alpha = 1;
        setGraphic("over");
        var text = Localiser.instance.getItemContent(point.content);
        cast(parent, ScannerDisplay).setText(point.textRef, KpTextDownParser.parse(text));
    }

    private function onOut(e: MouseEvent): Void
    {
        setGraphic("seen");
    }
}

class PointStyle {
    /**
    * Radius of the point. If 0, the size of the image will be unchanged
**/
    public var radius (default, default): Float = 0;

    /**
    * Graphics for the different states of the point
    **/
    public var graphics (default, default): Hash<String>;

    public function new()
    {
        graphics = new Hash<String>();
    }

    public function addGraphic(key: String, graph: String): Void
    {
        graphics.set(key, graph);
    }
}
