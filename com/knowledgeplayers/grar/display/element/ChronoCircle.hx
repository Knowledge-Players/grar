package com.knowledgeplayers.grar.display.element;

import flash.display.Sprite;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import haxe.xml.Fast;
import flash.events.Event;
import flash.display.Shape;
import flash.display.Sprite;

class ChronoCircle extends WidgetContainer
{
    public var shFill:Shape;
    public var degree:Float;
    public var deltaAngle:Float;

    private var colorCircle:Color;
    private var minRadius:Int;
    private var maxRadius:Int;
	private var step:Float;

    public function new(_node:Fast):Void
    {
        super(_node);

        if(_node.att.type == "circle"){

            colorCircle = ParseUtils.parseColor(_node.att.color);
            minRadius = Std.parseInt(_node.att.minRadius);
            maxRadius = Std.parseInt(_node.att.maxRadius);

            degree = 0; // Initial angle

            shFill = new Shape();
            shFill.x = maxRadius;
            shFill.y = maxRadius;
            updatePicture(360);
	        addChild(shFill);

	        if(_node.has.colorBackground){
		        var bkgCircle = drawDoubleCircle(ParseUtils.parseColor(_node.att.colorBackground), maxRadius, maxRadius, minRadius, maxRadius);
		        addChild(bkgCircle);
	        }
			if(_node.has.colorCenter){
				var centerCircle = drawDoubleCircle(ParseUtils.parseColor(_node.att.colorCenter), maxRadius, maxRadius, minRadius);
				addChild(centerCircle);
			}

	        var progressCircle = drawDoubleCircle(colorCircle, maxRadius, maxRadius, minRadius, maxRadius);
	        progressCircle.mask = shFill;
            addChild(progressCircle);
        }
    }

	public function updatePicture(ratio: Float):Void
	{
		shFill.graphics.clear();
		shFill.graphics.lineStyle(1,0x000000);
		shFill.graphics.moveTo(0,0);
		shFill.graphics.beginFill(0xFF00FF,1);

		// Minimize this to get more precise drawing
		var step = 0.5;
		var i = 0.0;
		while(i < ratio*360){
			shFill.graphics.lineTo(maxRadius*Math.cos(i*Math.PI/180), -maxRadius*Math.sin(i*Math.PI/180));
			i += step;
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