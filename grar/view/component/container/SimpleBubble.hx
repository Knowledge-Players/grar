package grar.view.component.container;

import grar.view.component.container.WidgetContainer;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.CapsStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;

class SimpleBubble extends WidgetContainer {

    public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : aze.display.TilesheetEx, ? width : Float, 
                            ? height : Float, ? colors : Array<Int>, ? arrowX : Float = 0, ? arrowY : Float = 0, 
                            ? radius : Array<Float>, ? line : Float = 0, ? colorLine : Int = 0xFFFFFF, 
                            ? shadow : Float = 0, ? gap : Float = 5, ? alphas : Array<Float>, ? bubbleX : Float = 0, 
                            ? bubbleY : Float = 0) {

        super(callbacks, applicationTilesheet);

        var bubble : Sprite = new Sprite();
        x = bubbleX;
        y = bubbleY;

	    // Fill bubble
	    if(line !=0)
            bubble.graphics.lineStyle(line,colorLine,1,true,LineScaleMode.NONE,CapsStyle.SQUARE,JointStyle.ROUND);
        if (colors.length == 1){
            bubble.graphics.beginFill(colors[0], alphas[0]);
        }
        else{
            var ratios:Array<Int> = [0x00, 0xFF];
            var matr:Matrix = new Matrix();
            matr.createGradientBox(width, height, Math.PI/2, 0, 0);
            bubble.graphics.beginGradientFill(GradientType.LINEAR,[colors[0], colors[1]],alphas,ratios,matr);
        }

	    // Draw arrow
	    var point;
	    if(arrowX == 0 || arrowY == 0)
	        point = new Point(width/2,height/2);
		else
	        point = new Point(arrowX, arrowY);
        drawSpeechBubble(bubble, radius, width, height, point,gap);

        bubble.graphics.endFill();
        
        if (shadow != 0) {

            bubble.filters = onFiltersRequest(["bubbleShadow"]); // FilterManager.getFilter("bubbleShadow");
	        
            if (bubble.filters.length == 0) {

	            throw "[SimpleBubble] No filter are specified for bubble. You must use the ref 'bubbleShadow' for it.";
            }
        }

	    content.addChild(bubble);
    }

    private function drawSpeechBubble(bubble: Sprite, cornerRadius:Array<Float>, width: Float, height: Float, point:Point, gap:Float = 10): Void
    {
        var g:Graphics = bubble.graphics;

	    var x = 0;
	    var y = 0;
        var px:Float = point.x;
        var py:Float = point.y;
        var hgap:Float = Math.min(width - cornerRadius[0] - cornerRadius[0], gap);
        var left:Float = px <= x + width / 2 ? (Math.max(x+cornerRadius[0], px)) : (Math.min(x + width - cornerRadius[0] - hgap, px - hgap));
        var right:Float = px <= x + width / 2 ? (Math.max(x + cornerRadius[1] + hgap, px+hgap)) : (Math.min(x + width - cornerRadius[1], px));
        var vgap:Float = Math.min(height - cornerRadius[2] - cornerRadius[2],gap);
        var top:Float = py < y + height / 2 ? Math.max(y + cornerRadius[0], py) : Math.min(y + height - cornerRadius[0] - vgap, py-vgap);
        var bottom:Float = py < y + height / 2 ? Math.max(y + cornerRadius[2] + vgap, py+vgap) : Math.min(y + height - cornerRadius[2], py);


	    //bottom right corner
	    var a:Float = cornerRadius[2] - (cornerRadius[2]*0.707106781186547); // cos45
	    var s:Float = cornerRadius[2] - (cornerRadius[2]*0.414213562373095); // tan PI/8
        g.moveTo ( x+width,y+height-cornerRadius[2]);
        if(cornerRadius[2] > 0){
            if (px > x+width-cornerRadius[2] && py > y+height-cornerRadius[2] && Math.abs((px - x - width) - (py - y - height)) <= cornerRadius[2]){
                g.lineTo(px, py);
                g.lineTo(x + width - cornerRadius[2], y + height);
            }
            else{
                g.curveTo( x + width, y + height - s, x + width - a, y + height - a);
                g.curveTo( x + width - s, y + height, x + width - cornerRadius[2], y + height);
            }
        }

	    // bottom edge
        if (py > y + height && (px - x - width) < (py - y -height - cornerRadius[2]) && (py - y - height - cornerRadius[2]) > (x - px)){
            g.lineTo(right, y + height);
            g.lineTo(px, py);
            g.lineTo(left, y + height);
        }

        g.lineTo ( x+cornerRadius[3],y+height );

		//bottom left corner
	    a = cornerRadius[3] - (cornerRadius[3]*0.707106781186547); // cos45
	    s = cornerRadius[3] - (cornerRadius[3]*0.414213562373095); // tan PI/8
        if (cornerRadius[3] > 0){
            if (px < x + cornerRadius[3] && py > y + height - cornerRadius[3] && Math.abs((px-x)+(py-y-height)) <= cornerRadius[3]){
                g.lineTo(px, py);
                g.lineTo(x, y + height - cornerRadius[3]);
            }
            else{
                g.curveTo( x+s,y+height,x+a,y+height-a);
                g.curveTo( x, y + height - s, x, y + height - cornerRadius[3]);
            }
        }

	    // left edge
        if (px < x && (py - y - height + cornerRadius[3]) < (x - px) && (px - x) < (py - y - cornerRadius[3]) ){
            g.lineTo(x, bottom);
            g.lineTo(px, py);
            g.lineTo(x, top);
        }

        g.lineTo ( x,y+cornerRadius[0] );

		//top left corner
	    a = cornerRadius[0] - (cornerRadius[0]*0.707106781186547); // cos45
	    s = cornerRadius[0] - (cornerRadius[0]*0.414213562373095); // tan PI/8
        if (cornerRadius[0] > 0){
            if (px < x + cornerRadius[0] && py < y + cornerRadius[0] && Math.abs((px - x) - (py - y)) <= cornerRadius[0]){
                g.lineTo(px, py);
                g.lineTo(x + cornerRadius[0], y);
            }
            else{
                g.curveTo( x,y+s,x+a,y+a);
                g.curveTo( x + s, y, x + cornerRadius[0], y);
            }
        }

	    //top edge
        if (py < y && (px - x) > (py - y + cornerRadius[0]) && (py - y + cornerRadius[0]) < (x - px + width)){
            g.lineTo(left, y);
            g.lineTo(px, py);
            g.lineTo(right, y);
        }

        g.lineTo ( x + width - cornerRadius[1], y );

		//top right corner
	    a = cornerRadius[1] - (cornerRadius[1]*0.707106781186547); // cos45
	    s = cornerRadius[1] - (cornerRadius[1]*0.414213562373095); // tan PI/8
        if (cornerRadius[1] > 0){
            if (px > x + width - cornerRadius[1] && py < y + cornerRadius[1] && Math.abs((px - x - width) + (py - y)) <= cornerRadius[1]){
                g.lineTo(px, py);
                g.lineTo(x + width, y + cornerRadius[1]);
            }
            else{
                g.curveTo( x+width-s,y,x+width-a,y+a);
                g.curveTo( x + width, y + s, x + width, y + cornerRadius[1]);
            }
        }

	    // right edge
        if (px > x + width && (py - y - cornerRadius[1]) > (x - px + width) && (px - x - width) > (py - y - height + cornerRadius[1]) ){
            g.lineTo(x + width, top);
            g.lineTo(px, py);
            g.lineTo(x + width, bottom);
        }
        g.lineTo ( x+width,y+height-cornerRadius[2] );
    }
}

