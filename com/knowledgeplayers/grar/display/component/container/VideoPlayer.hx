package com.knowledgeplayers.grar.display.component.container;

import haxe.ds.GenericStack;
import aze.display.TileClip;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import haxe.xml.Fast;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.media.SoundTransform;
import nme.display.BitmapData;
import nme.geom.Rectangle;
import nme.display.Stage;
import nme.display.StageDisplayState;
import nme.display.DisplayObject;

import flash.events.NetStatusEvent;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

class VideoPlayer extends WidgetContainer{

	/*public var audioSliderBkg (default, default): TileSprite;
	public var audioSliderCursor (default, default): TileSprite;
	public var bufferBar (default, default): TileSprite;
	public var cursor (default, default): TileSprite;
	public var progressBar (default, default): TileSprite;
	public var scrubberLine (default, default): TileSprite;*/
	public var playButtons (default, default): GenericStack<DefaultButton>;
	public var fullscreenButton (default, default):DefaultButton;
	private var isPlaying: Bool = false;
	private var isFullscreen: Bool = false;
	private var displayHours: Bool = false;
	private var totalLength: Int = 0;

	private var connection : NetConnection;
	private var stream : NetStream;
	private var metaDataListener: Dynamic = new Dynamic();
	private var video : Video;
	private var loop : Bool;
	private var autoStart : Bool;
	private var autoSize : Bool = false;
	private var _timeToCapture : Float = 0;

	public function new (?xml: Fast, autoStart:Bool = true, loop:Bool = false){
		super(xml);
		video = new Video();
		this.loop = loop;
		this.autoStart = autoStart

		playButtons = new GenericStack<DefaultButton>();
		connection = new NetConnection();
		connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		addEventListener(Event.REMOVED_FROM_STAGE , unsetVideo, false, 0, true);
		connection.connect(null);
		nme.Lib.stage.fullScreenSourceRect = new Rectangle(x, y, maskWidth, maskHeight);
	}

	public function setVideo(url:String, autoSize:Bool = false, defaultVolume:Float = 1, capture:Float = 0):Void{
		_timeToCapture = capture
		this.autoSize = autoSize;
		stream = new NetStream(connection);
		soundTransform.volume = defaultVolume;
		stream.soundTransform = soundTransform;
		stream.client = metaDataListener;
		stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		// TODO bufferTime en fonction de la BP
		//stream.bufferTime = startBufferLength;
		metaDataListener.onMetaData = theMeta;
		stream.play(url);
		stream.seek(0);
		if(autoStart)
			playVideo();
		else{
			pauseVideo();
		}
		video.attachNetStream(stream);
		video.smoothing = true;
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}

	public function playVideo(?target: DefaultButton):Void
	{
		addEventListener(Event.ENTER_FRAME, enterFrame);
		setPlaying(true);
		stream.resume();
	}

	public function pauseVideo():Void
	{
		removeEventListener(Event.ENTER_FRAME, enterFrame);
		setPlaying(false);
		stream.pause();
	}

	private function playOrPause(?target: DefaultButton)
	{
		if(isPlaying)
			playVideo()
		else
			pauseVideo()
	}

	public function unsetVideo (?e:Event):Void
	{
		removeEventListener(Event.REMOVED_FROM_STAGE , unsetVideo);
		video.clear();
		stream.close();
	}

	public function toggleFullScreen(?target: DefaultButton)
	{
		if (isFullscreen) {
			nme.Lib.stage.displayState = StageDisplayState.NORMAL;
			fullscreenButton.setToggle(false);
		}
		else {
			nme.Lib.stage.displayState = StageDisplayState.FULL_SCREEN;
			fullscreenButton.setToggle(true);
		}
	}

	public function imageCapture():BitmapData {
		var bmp:BitmapData = new BitmapData(width, height);
		bmp.draw(this);
		return bmp;
	}

	private function onCaptureImage():Void{
		removeEventListener(Event.ENTER_FRAME, enterFrame);
		stream.pause();
		stream.seek(_timeToCapture);
		stream.resume();
		bCapture = true;
		_mc.barBg_mc._play.gotoAndStop(2);
		//dispatchEvent(new BitmapCaptureEvent(BitmapCaptureEvent.CAPTURE,imageCapture(),true));
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}

	/*private function resetControls():Void{
		_mc.barBg_mc.playStatus_mc.width = 0;
		_mc.barBg_mc.dlStatus_mc.width = 0;
		_mc.barBg_mc._cursor.x = _mc.barBg_mc.playStatus_mc.x;
	}

	private function initControls():Void{
		_mc.video_mc.useHandCursor = false;
		_mc.video_mc.buttonMode = false;
		_mc.barBg_mc._play.useHandCursor = true;
		_mc.barBg_mc._play.buttonMode = true;
		_mc.barBg_mc.pictoSon.useHandCursor = true;
		_mc.barBg_mc.pictoSon.buttonMode = true;
		_mc.barBg_mc._bgTimeLine.useHandCursor = true;
		_mc.barBg_mc._bgTimeLine.buttonMode = true;
		_mc.barBg_mc.fullscreen_btn.useHandCursor = true;
		_mc.barBg_mc.fullscreen_btn.buttonMode = true;
		_mc.barBg_mc.fullscreen_btn.gotoAndStop(1);

		_mc.barBg_mc._play.addEventListener(MouseEvent.MOUSE_DOWN, onPlayPause);
		_mc.barBg_mc.pictoSon.mcBar.addEventListener(MouseEvent.MOUSE_DOWN, onSonIsDown);
		_mc.barBg_mc._bgTimeLine.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownTimeline);



		_mc.barBg_mc.playStatus_mc.width = 0;
		_mc.barBg_mc.dlStatus_mc.width = 0;
		_mc.barBg_mc._cursor.x = _mc.barBg_mc.playStatus_mc.x;
	}


	private function onSonIsDown(e:MouseEvent):Void{
		var mc:MovieClip = (e.target) as MovieClip;
		soundTransform.volume = mc.mouseX / mc.width;
		stream.soundTransform = soundTransform;
		trace(mc.mouseX);
		_mc.barBg_mc.pictoSon.mcTrack.x = mc.mouseX;
	}*/

	private function enterFrame(e:Event):Void{


		var nowSecs:Float = Math.floor(stream.time);
		var totalSecs:Float = Math.floor(totalLength);

		if (bCapture2) {
			if (nowSecs >= (_timeToCapture)) {
				dispatchEvent(new BitmapCaptureEvent(BitmapCaptureEvent.CAPTURE,imageCapture(),true));
				bCapture2 = false;
			}
		}

		if(nowSecs > 0)	{
			_mc.barBg_mc.time_txt.text = videoTimeConvert(nowSecs) + "/" + videoTimeConvert(totalSecs);
			var amountPlayed:Float = nowSecs / totalSecs;
			var amountLoaded:Float = stream.bytesLoaded / stream.bytesTotal;
			_mc.barBg_mc.playStatus_mc.x = xMin;
			_mc.barBg_mc.playStatus_mc.width = timeLineWidth * amountPlayed - 1;
			_mc.barBg_mc.dlStatus_mc.x = xMin;
			_mc.barBg_mc.dlStatus_mc.width = timeLineWidth * amountLoaded;
			_mc.barBg_mc._cursor.x = _mc.barBg_mc.playStatus_mc.x + _mc.barBg_mc.playStatus_mc.width;

			if(stream.time>=totalLength){
				dispatchEvent(new Event(Event.COMPLETE));
				stream.seek(0);
				setNormalScreen();
				resetControls();
				if(loop==false){
					stream.pause();
					_mc.barBg_mc._play.gotoAndStop(1)
					this.removeEventListener(Event.ENTER_FRAME, enterFrame);
				}
			}
		}
	}

	private function onMouseDownTimeline(e:MouseEvent):Void{

		trace("touche a ca, poukave")

		var _percent:Float = (this.mouseX-xMin) * 100 / (xMax - xMin);
		var timeToGo:Float = totalLength*_percent/100;
		this.removeEventListener(Event.ENTER_FRAME, enterFrame);
		stream.pause()
		stream.seek(timeToGo);
		stream.resume();
		_mc.barBg_mc._play.gotoAndStop(2);
		this.addEventListener(Event.ENTER_FRAME, enterFrame);
	}

	private function netStatusHandler(event:NetStatusEvent):Void {
		switch (event.info.code) {
			case "NetStream.Buffer.Full":
				stream.bufferTime = xpandedBufferLength;
				if (_timeToCapture > 0 && !bCapture) {
					bCapture = true;
					onCaptureImage();
				}
				if (bCapture) {
					bCapture2 = true;
				}
				break;

			case "NetStream.Buffer.Empty":
				stream.bufferTime = startBufferLength;
				break;
		}
	}

	private function theMeta(data):Void{
		//visible = true;
		_mc.preloader_mc.visible = false;
		_mc.barBg_mc.visible = true;
		_mc.video_mc.visible = true;
		_mc.bg_mc.visible = true;
		totalLength = Math.round(data.duration*100)/100;
		if (autoSize) {
			setSize(data.width,data.height);
		}
	}

	// Refactor
	private function videoTimeConvert(pTime: Float):String {
		var tempNum = pTime;
		var minutes = Math.floor(tempNum / 60);
		var hours: Float = 0;
		if (displayHours) {
			hours = Math.floor(minutes / 60);
		}
		var seconds = Math.round(tempNum - (minutes * 60));
		if (seconds < 10) {
			seconds = "0" + seconds;
		}
		if (minutes < 10) {
			minutes = "0" + minutes;
		}
		if (displayHours) {
			if (hours < 10){
				hours = "0" + hours;
			}
		}
		var currentTimeConverted =  minutes + ":" + seconds;
		return currentTimeConverted;
	}

	private function setPlaying(isPlaying: Bool){
		for(button in playButtons)
			button.setToggle = isPlaying;
		this.isPlaying = isPlaying;
	}

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		if(action == "play"){
			playButtons.add(button);
			button.buttonAction = playOrPause;
		}
		else if(action == "fullscreen"){
			fullscreenButton = button;
			button.buttonAction = toggleFullScreen;
		}
	}

}
