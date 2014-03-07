package grar.view.component.container;

import aze.display.TilesheetEx;

import grar.view.element.ChronoCircle;
import grar.view.component.container.WidgetContainer;

import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLRequest;
import flash.media.SoundChannel;
import flash.media.Sound;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

class SoundPlayer extends WidgetContainer {

    //public function new(?xml: Fast, ?tilesheet: TilesheetEx)
    public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : TilesheetEx, 
                            transitions : StringMap<TransitionTemplate>, spd : WidgetContainerData, 
                            ? tilesheet : TilesheetEx) {

        playButtons = new GenericStack<DefaultButton>();

        //super(xml, tilesheet);
        super(callbacks, applicationTilesheet, transitions, spd, tilesheet);

        soundChannel = new SoundChannel();
    }

    public var playButtons (default, default): GenericStack<DefaultButton>;

	public var autoPlay (default, default):Bool;

    private var isPlaying: Bool = false;
    private var sound:Sound;
    private var soundChannel:SoundChannel;
    private var pausePosition:Float=0;
    private var chrono:ChronoCircle;
	private var loaded:Bool;

    public function setSound(url:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 0, capture:Float = 0,?autoFullscreen:Bool): Void{

        if(url == null || url == "")
            throw '[SoundPlayer] Invalid url "$url" for audio stream.';

	    autoPlay = autoStart;
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

	public function playSound():Void
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

	public function pauseSound():Void
	{
		pausePosition = soundChannel.position;
		setPlaying(false);
		soundChannel.stop();
	}


	///
    // INTERNALS
    //

    override private function createTimer(d : WidgetContainerData) : ChronoCircle {

        var t : ChronoCircle = super.createTimer(d);
        chrono = t;
        return t;
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