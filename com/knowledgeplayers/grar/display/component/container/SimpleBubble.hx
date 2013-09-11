package com.knowledgeplayers.grar.display.component.container;


import nme.geom.Matrix;
import nme.display.GradientType;
import nme.display.Graphics;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.filters.DropShadowFilter;
import nme.display.JointStyle;
import nme.display.CapsStyle;
import nme.display.LineScaleMode;
import nme.display.Sprite;

class SimpleBubble extends Sprite{

    public function new(?width:Float,?height:Float,?color:Array<String>,?arrowX:Float=0,?arrowY:Float=0,?radius:Float=0,?line:Float=0,?colorLine:Int=0xFFFFFF,?shadow:Float=0){

        super();
        var bubble:Sprite = new Sprite();


        if(line !=0)
        {
            bubble.graphics.lineStyle(line,colorLine,1,true,LineScaleMode.NONE,CapsStyle.SQUARE,JointStyle.ROUND);

        }
        if (color.length ==1)
            bubble.graphics.beginFill(Std.parseInt(color[0]));
        else
        {
            var alphas:Array<Int> = [1, 1];
            var ratios:Array<Int> = [0x00, 0xFF];
            var matr:Matrix = new Matrix();
            matr.createGradientBox(width, height, Math.PI/2, 0, 0);
            bubble.graphics.beginGradientFill(GradientType.LINEAR,[Std.parseInt(color[0]),Std.parseInt(color[1])],alphas,ratios,matr);
        }
        drawSpeechBubble(bubble, new Rectangle(0,0,width,height), radius, new Point(arrowX,arrowY));

        bubble.graphics.endFill();
        if (shadow !=0){
            var filterShadow:DropShadowFilter = new DropShadowFilter(shadow,45,0x000000,1,10,10);
            bubble.filters = [filterShadow];
        }

        addChild(bubble);
    }

    public  function drawSpeechBubble(target:Sprite, rect:Rectangle, cornerRadius:Float, point:Point):Void
    {
        var g:Graphics = target.graphics;
        var r:Float = cornerRadius;

        var x:Float = rect.x;
        var y:Float = rect.y;
        var w:Float = rect.width;
        var h:Float = rect.height;
        var px:Float = point.x;
        var py:Float = point.y;
        var min_gap:Float = 20;
        var hgap:Float = Math.min(w - r - r, Math.max(min_gap, w / 5));
        var left:Float = px <= x + w / 2 ?
        (Math.max(x+r, px))
        :(Math.min(x + w - r - hgap, px - hgap));
        var right:Float = px <= x + w / 2?
        (Math.max(x + r + hgap, px+hgap))
        :(Math.min(x + w - r, px));
        var vgap:Float = Math.min(h - r - r, Math.max(min_gap, h / 5));
        var top:Float = py < y + h / 2 ?
        Math.max(y + r, py)
        :Math.min(y + h - r - vgap, py-vgap);
        var bottom:Float = py < y + h / 2 ?
        Math.max(y + r + vgap, py+vgap)
        :Math.min(y + h - r, py);

//bottom right corner
        var a:Float = r - (r*0.707106781186547);
        var s:Float = r - (r*0.414213562373095);

        g.moveTo ( x+w,y+h-r);
        if (r > 0)
        {
            if (px > x+w-r && py > y+h-r && Math.abs((px - x - w) - (py - y - h)) <= r)
            {
                g.lineTo(px, py);
                g.lineTo(x + w - r, y + h);
            }
            else
            {
                g.curveTo( x + w, y + h - s, x + w - a, y + h - a);
                g.curveTo( x + w - s, y + h, x + w - r, y + h);
            }
        }

        if (py > y + h && (px - x - w) < (py - y -h - r) && (py - y - h - r) > (x - px))
        {
// bottom edge
            g.lineTo(right, y + h);
            g.lineTo(px, py);
            g.lineTo(left, y + h);
        }

        g.lineTo ( x+r,y+h );

//bottom left corner
        if (r > 0)
        {
            if (px < x + r && py > y + h - r && Math.abs((px-x)+(py-y-h)) <= r)
            {
                g.lineTo(px, py);
                g.lineTo(x, y + h - r);
            }
            else
            {
                g.curveTo( x+s,y+h,x+a,y+h-a);
                g.curveTo( x, y + h - s, x, y + h - r);
            }
        }

        if (px < x && (py - y - h + r) < (x - px) && (px - x) < (py - y - r) )
        {
// left edge
            g.lineTo(x, bottom);
            g.lineTo(px, py);
            g.lineTo(x, top);
        }

        g.lineTo ( x,y+r );

//top left corner
        if (r > 0)
        {
            if (px < x + r && py < y + r && Math.abs((px - x) - (py - y)) <= r)
            {
                g.lineTo(px, py);
                g.lineTo(x + r, y);
            }
            else
            {
                g.curveTo( x,y+s,x+a,y+a);
                g.curveTo( x + s, y, x + r, y);
            }
        }

        if (py < y && (px - x) > (py - y + r) && (py - y + r) < (x - px + w))
        {
//top edge
            g.lineTo(left, y);
            g.lineTo(px, py);
            g.lineTo(right, y);
        }

        g.lineTo ( x + w - r, y );

//top right corner
        if (r > 0)
        {
            if (px > x + w - r && py < y + r && Math.abs((px - x - w) + (py - y)) <= r)
            {
                g.lineTo(px, py);
                g.lineTo(x + w, y + r);
            }
            else
            {
                g.curveTo( x+w-s,y,x+w-a,y+a);
                g.curveTo( x + w, y + s, x + w, y + r);
            }
        }

        if (px > x + w && (py - y - r) > (x - px + w) && (px - x - w) > (py - y - h + r) )
        {
// right edge
            g.lineTo(x + w, top);
            g.lineTo(px, py);
            g.lineTo(x + w, bottom);
        }
        g.lineTo ( x+w,y+h-r );

    }

}

