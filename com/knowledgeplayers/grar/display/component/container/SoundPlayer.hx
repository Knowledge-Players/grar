package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.display.element.ChronoCircle;
import flash.events.Event;
import flash.net.URLRequest;
import flash.media.SoundChannel;
import flash.media.Sound;
import haxe.ds.GenericStack;
import flash.display.Sprite;
import haxe.xml.Fast;
import aze.display.TilesheetEx;

class SoundPlayer extends WidgetContainer
{
    public var playButtons (default, default): GenericStack<DefaultButton>;
    private var containerControls:Sprite;
    private var backgroundControls:Widget;
    private var isPlaying: Bool = false;
    private var loop : Bool;
    private var autoStart : Bool;
    private var volumeEnCours:Float = 0;
    private var controls: GenericStack<Widget>;
    private var mySound:Sound;
    private var mySoundChannel:SoundChannel;
    private var pausePosition:Float=0;
    private var chrono:ChronoCircle;
    private var timeSound:Float;

    public function new(?xml: Fast, ?tilesheet: TilesheetEx)
    {

        playButtons = new GenericStack<DefaultButton>();
        containerControls = new Sprite();
        controls = new GenericStack<Widget>();

        mySoundChannel = new SoundChannel();
        mySoundChannel.addEventListener(Event.SOUND_COMPLETE,onSoundComplete);
        addChild(containerControls);

        super(xml, tilesheet);

        for(i in 0...numChildren){
            if(Std.is(getChildAt(i), Widget))
                controls.add(cast(getChildAt(i), Widget));
        }

        init();
    }

    public function setSound(url:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 0, capture:Float = 0,?autoFullscreen:Bool): Void{

        if(url == null || url == "")
            throw '[SoundPlayer] Invalid url "$url" for video stream.';

            trace("url : "+url);

            var req:URLRequest = new URLRequest();
            req.url = url;
            mySound = new Sound();
            mySound.addEventListener(Event.COMPLETE,onLoadComplete);
            mySound.load(req);

    }

    private function onLoadComplete(e:Event):Void{
        timeSound = Math.floor(cast(e.currentTarget,Sound).length/1000);

    }

    override public function createElement(elemNode:Fast):Widget
    {
        var widget = super.createElement(elemNode);

        if(elemNode.name.toLowerCase() == "backgroundcontrols"){

            backgroundControls = new Widget();

            var color = elemNode.has.color ? Std.parseInt(elemNode.att.color) : 0;
            var alpha = elemNode.has.alpha ? Std.parseFloat(elemNode.att.alpha) : 1;
            var x = elemNode.has.x ? Std.parseFloat(elemNode.att.x) : 0;
            var y = elemNode.has.y ? Std.parseFloat(elemNode.att.y) : 0;
            var w = elemNode.has.width ? Std.parseFloat(elemNode.att.width) : 0;
            var h = elemNode.has.height ? Std.parseFloat(elemNode.att.height) : 0;

            backgroundControls.graphics.beginFill(color,alpha);
            backgroundControls.graphics.drawRect(x,y,w,h);
            backgroundControls.graphics.endFill();

            controls.add(backgroundControls);
            addElement(backgroundControls);
        }

        return widget;
    }

    private function init():Void
    {

        content.setChildIndex(layer.view,1);
        containerControls.addChild(content);

        for(i in 0...content.numChildren){
            if(Std.is(content.getChildAt(i), ChronoCircle))
                chrono = cast(content.getChildAt(i),ChronoCircle);

        }


    }

    override private function setButtonAction(button:DefaultButton, action:String):Void
    {
        if(action == "play"){
            playButtons.add(button);

            button.buttonAction = playOrPause;

        }
        controls.add(button);
    }

    private function playOrPause(?target: DefaultButton)
    {


        if(!isPlaying)

            playSound();
        else
            pauseSound();

    }
    private function onSoundComplete(e:Event):Void{
        pausePosition = 0;
    }
    private function playSound():Void{
        if (pausePosition ==0)
        chrono.activChrono(timeSound);
        else
        chrono.pauseChrono(false);
        setPlaying(true);
        mySoundChannel = mySound.play(pausePosition);
    }

    private function pauseSound():Void{

        chrono.pauseChrono(true);
        pausePosition = mySoundChannel.position;
        setPlaying(false);
        mySoundChannel.stop();
    }

    private function setPlaying(isPlaying: Bool){
        for(button in playButtons)
            button.toggle(!isPlaying);
        this.isPlaying = isPlaying;
    }
}