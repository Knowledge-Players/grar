package grar.view.element;

import grar.util.ParseUtils;
import grar.view.component.container.WidgetContainer;

import flash.events.Event;
import flash.display.Sprite;
import flash.display.Shape;
import flash.display.Sprite;

class ChronoCircle extends WidgetContainer {

    //public function new(_node:Fast):Void
    public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : aze.display.TilesheetEx, ccd : WidgetContainerData) : Void {

        super(callbacks, applicationTilesheet, ccd);

        switch(ccd.type) {

        	case ChronoCircle(cc, minR, maxR, cb, ctc):

        		if (colorCircle != null) {

		            this.colorCircle = cc;
		            this.minRadius = minR;
		            this.maxRadius = maxR;

		            this.degree = 0; // Initial angle

		            shFill = new Shape();
		            shFill.x = maxRadius;
		            shFill.y = maxRadius;
		            updatePicture(360);
			        addChild(shFill);

			        if (cb != null) {

				        var bkgCircle = drawDoubleCircle(cb, maxRadius, maxRadius, minRadius, maxRadius);
				        addChild(bkgCircle);
			        }
					if (ctc != null) {

						var centerCircle = drawDoubleCircle(ctc, maxRadius, maxRadius, minRadius);
						addChild(centerCircle);
					}

			        var progressCircle = drawDoubleCircle(colorCircle, maxRadius, maxRadius, minRadius, maxRadius);
			        progressCircle.mask = shFill;
		            addChild(progressCircle);
        		}

        	default: // nothing
        }
    }

    public var shFill:Shape;
    public var degree:Float;
    public var deltaAngle:Float;

    private var colorCircle:Color;
    private var minRadius:Int;
    private var maxRadius:Int;

	public function updatePicture(ratio: Float):Void
	{
		shFill.graphics.clear();
		shFill.graphics.lineStyle(1,0x000000);
		shFill.graphics.moveTo(0,0);
		shFill.graphics.beginFill(0xFF00FF,1);

		for (i in 0...Math.floor(ratio*360)) {
			shFill.graphics.lineTo(maxRadius*Math.cos(i*Math.PI/180), -maxRadius*Math.sin(i*Math.PI/180));
		}
		shFill.graphics.lineTo(0,0);
		shFill.graphics.endFill();
	}

	private function drawDoubleCircle(color: Color, x: Float, y: Float, minRadius: Float, maxRadius: Float = 0):Shape
	{
		var circle = new Shape();
		circle.graphics.beginFill(color.color, color.alpha);
		circle.graphics.drawCircle(x, y, minRadius);
		if(maxRadius > 0)
			circle.graphics.drawCircle(x, y, maxRadius);
		circle.graphics.endFill();
		return circle;
	}
}