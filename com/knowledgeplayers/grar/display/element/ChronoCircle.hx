package com.knowledgeplayers.grar.display.element;

import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import haxe.xml.Fast;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.display.Shape;
import flash.display.Sprite;
class ChronoCircle extends WidgetContainer {

    public var count:Int=5;
    private var timeQuestion:Float;
    public var shFill:Shape;
    public var degree:Float; // Initial angle
    public var degChange:Float; // Amount angle will change on each click

    public var circleR:Int; // Circle radius (in pixels)
    public var circleX:Int; // Screen coordinates of center of circle
    public var circleY:Int;

    public var myTimer:Timer;

    private var colorCircle:Int;
    private var alphaCircle:Int;
    private var minRadius:Int;
    private var maxRadius:Int;
    private var time:Int;



    public function new(_node:Fast):Void{

        super();

        var sprite:Sprite = new Sprite();
        sprite.x =  Std.parseFloat(_node.att.x);
        sprite.y =  Std.parseFloat(_node.att.y);
        time = Std.parseInt(_node.att.time);

        if(_node.att.type=="circle"){

            colorCircle = Std.parseInt(_node.att.color);
            alphaCircle= Std.parseInt(_node.att.alpha);
            minRadius=Std.parseInt(_node.att.minRadius);
            maxRadius =Std.parseInt(_node.att.maxRadius);


            var am:Int = 360;
            degree = 0; // Initial angle

            degChange = (am/time)/30; // Amount angle will change on each click

            circleR =maxRadius; // Circle radius (in pixels)
            circleX = 0; // Screen coordinates of center of circle
            circleY = 0;

            shFill = new Shape();
            shFill.graphics.lineStyle(1,0x000000);
            shFill.graphics.moveTo(0,0);
            shFill.graphics.lineTo(0,0);
            shFill.x = circleX;
            shFill.y = circleY;
            shFill.graphics.beginFill(0xFF00FF,1);
            updatePicture(360);


            var bigcircle = new Shape();
            bigcircle.graphics.beginFill(colorCircle,alphaCircle);
            bigcircle.graphics.drawCircle(0,0,minRadius);
            bigcircle.graphics.drawCircle(0,0,maxRadius);
            bigcircle.graphics.endFill();

           bigcircle.mask = shFill;
            sprite.addChild(shFill);

            sprite.addChild(bigcircle);

        };

        myTimer = new Timer(1000);

        shFill.addEventListener(Event.ENTER_FRAME,decreaseAngle);
        myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, completeTimer);
        //myTimer.addEventListener(TimerEvent.TIMER, countdown);

        addChild(sprite);


        activChrono();
    }
    public function updatePicture(t:Int):Void {



        shFill.graphics.clear();


        shFill.graphics.lineStyle(1,0x000000);


        shFill.graphics.moveTo(0,0);

        shFill.graphics.beginFill(0xFF00FF,1);


        for (i in 0...t) {
            shFill.graphics.lineTo(circleR*Math.cos(i*Math.PI/180), -circleR*Math.sin(i*Math.PI/180));
        }

        shFill.graphics.lineTo(0,0);

        shFill.graphics.endFill();

    }
    public function decreaseAngle(evt:Event):Void {
        degree = (degree - degChange);
        trace('degree : '+degree);
        if (degree < 0) {

            degree = 360 + degree;


        }else if (degree ==0){
                //stopChrono()
        }


        updatePicture(Math.round(degree));
    }

    public function completeTimer(e:Event):Void
    {
        stopChrono();

    }

    public function stopChrono():Void{
        shFill.removeEventListener(Event.ENTER_FRAME,decreaseAngle);
        degree = 360;
        updatePicture(Math.round(degree));
        //myTimer.removeEventListener(TimerEvent.TIMER, countdown);
        myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, completeTimer);
        myTimer.stop();

    }

    public function activChrono():Void{

       // shFill.addEventListener(Event.ENTER_FRAME,decreaseAngle);

        myTimer.start();

    }

    public function reInitChrono():Void{
        degree = 360;
        updatePicture(Math.round(degree));

        myTimer = new Timer(1000,count);

        myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, completeTimer);
        //myTimer.addEventListener(TimerEvent.TIMER, countdown);
    }
}