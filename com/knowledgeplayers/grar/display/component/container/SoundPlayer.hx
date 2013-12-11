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

	public var autoPlay (default, default):Bool;

    private var isPlaying: Bool = false;
    private var sound:Sound;
    private var soundChannel:SoundChannel;
    private var pausePosition:Float=0;
    private var chrono:ChronoCircle;
	private var loaded:Bool;

    public function new(?xml: Fast, ?tilesheet: TilesheetEx)
    {
	    playButtons = new GenericStack<DefaultButton>();

        super(xml, tilesheet);

        soundChannel = new SoundChannel();
	    autoPlay = false;
    }

    public function setSound(url:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 0, capture:Float = 0,?autoFullscreen:Bool): Void{

        if(url == null || url == "")
            throw '[SoundPlayer] Invalid url "$url" for audio stream.';

	    loaded = false;
	    var req:URLRequest = new URLRequest(url);
	    sound = new Sound();
	    sound.addEventListener(Event.COMPLETE, function(e){
	        loaded = true;
		    if(autoPlay)
			    playSound();
	    });
	    sound.load(req);
    }

    override public function createElement(elemNode:Fast):Widget
    {
        var widget = super.createElement(elemNode);
		if(Std.is(widget, ChronoCircle))
			chrono = cast(widget, ChronoCircle);
        return widget;
    }

    override private function setButtonAction(button:DefaultButton, action:String):Void
    {
        if(action == "play"){
            playButtons.add(button);
            button.buttonAction = playOrPause;
        }
    }

    private function playOrPause(?target: DefaultButton)
    {
        if(!isPlaying)
            playSound();
        else
            pauseSound();
    }

    private function onSoundComplete(e:Event):Void
    {
        pausePosition = 0;
	    setPlaying(false);
    }

    private function playSound():Void
    {
        if(loaded){
	        setPlaying(true);
	        soundChannel = sound.play(pausePosition);
		    soundChannel.addEventListener(Event.SOUND_COMPLETE,onSoundComplete);
        }
	    else{
			autoPlay = true;
        }
    }

    private function pauseSound():Void
    {
        pausePosition = soundChannel.position;
        setPlaying(false);
        soundChannel.stop();
    }

    private function setPlaying(isPlaying: Bool)
    {
        if(isPlaying)
	        addEventListener(Event.ENTER_FRAME, onEnterFrame);
	    else
	        removeEventListener(Event.ENTER_FRAME, onEnterFrame);

        for(button in playButtons)
            button.toggle(!isPlaying);
        this.isPlaying = isPlaying;
    }

	private function onEnterFrame(e:Event):Void
	{
		chrono.updatePicture((sound.length - soundChannel.position)/sound.length);
	}
}