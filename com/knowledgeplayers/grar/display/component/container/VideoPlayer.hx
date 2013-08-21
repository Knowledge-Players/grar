package com.knowledgeplayers.grar.display.component.container;

import nme.display.Bitmap;
import com.knowledgeplayers.grar.util.DisplayUtils;
import nme.geom.Point;
import nme.display.Sprite;
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

#if flash
import flash.events.NetStatusEvent;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

class VideoPlayer extends WidgetContainer
{
	public var playButtons (default, default): GenericStack<DefaultButton>;
	public var fullscreenButton (default, default):DefaultButton;
	private var isPlaying: Bool = false;
	private var isFullscreen: Bool = false;
	private var displayHours: Bool = false;
	private var totalLength: Int = 0;

	private var connection : NetConnection;
	private var stream : NetStream;
	private var video : Video;

	private var loop : Bool;
	private var autoStart : Bool;
	private var progressBar: Image;
	private var controls: GenericStack<Widget>;
	private var timeArea: ScrollPanel;
	private var controlsHidden: Bool = false;
	private var cursor: Bitmap;
		//private var _timeToCapture : Float = 0;

	public function new (?xml: Fast)
	{
		playButtons = new GenericStack<DefaultButton>();
		controls = new GenericStack<Widget>();

		super(xml);
		//video = new Video();

		//connection = new NetConnection();
		connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		addEventListener(Event.REMOVED_FROM_STAGE , unsetVideo, false, 0, true);
		connection.connect(null);

		var coordinate = new Point(x, y);
		var globalCoordinate = localToGlobal(coordinate);
		stage.fullScreenSourceRect = new Rectangle(globalCoordinate.x, globalCoordinate.y, maskWidth, maskHeight);

		for(i in 0...numChildren){
			if(Std.is(getChildAt(i), Widget))
				controls.add(cast(getChildAt(i), Widget));
		}
		timeArea = cast(displays.get("time"), ScrollPanel);
		controls.add(timeArea);


		addEventListener(MouseEvent.ROLL_OUT, hideControls);

		addEventListener(MouseEvent.ROLL_OVER, showControls);

		init();
	}

	public function setVideo(url:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 0, capture:Float = 0): Void
	{
		//_timeToCapture = capture
		//stream = new NetStream(connection);
		this.loop = loop;
		this.autoStart = autoStart;
		soundTransform.volume = defaultVolume;
		stream.soundTransform = soundTransform;
		stream.client = {onMetaData: function(data){ totalLength = Math.round(data.duration*100/100); }};
		stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		// TODO bufferTime en fonction de la BP
		//stream.bufferTime = startBufferLength;
		stream.play(url);
		stream.seek(0);
		if(autoStart)
			playVideo();
		else{
			pauseVideo();
		}
		video.attachNetStream(stream);
		video.smoothing = true;
		video.width = maskWidth;
		video.height = maskHeight;
		addChildAt(video, 0);
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
		if(!isPlaying)
			playVideo();
		else
			pauseVideo();
	}

	public function unsetVideo (?e:Event):Void
	{
		removeEventListener(Event.REMOVED_FROM_STAGE , unsetVideo);
		video.clear();
		stream.close();
	}

	public function toggleFullScreen(?target: DefaultButton)
	{
		setFullScreen(!isFullscreen);
	}

	public function setFullScreen(fullscreen:Bool):Void
	{
		var coordinate = new Point(x, y);
		var globalCoordinate = localToGlobal(coordinate);
		stage.fullScreenSourceRect = new Rectangle(x, y, video.width, video.height);
		isFullscreen = fullscreen;
		if (isFullscreen) {
			stage.displayState = StageDisplayState.FULL_SCREEN;
			fullscreenButton.setToggle(true);
		}
		else {
			stage.displayState = StageDisplayState.NORMAL;
			fullscreenButton.setToggle(false);
		}
	}

	public function imageCapture():BitmapData {
		var bmp:BitmapData = new BitmapData(Math.round(width), Math.round(height));
		bmp.draw(this);
		return bmp;
	}

	override public function createElement(elemNode:Fast):Void
	{
		super.createElement(elemNode);
		if(elemNode.name.toLowerCase() == "progressbar"){
			progressBar = new Image();
			progressBar.x = Std.parseFloat(elemNode.att.x);
			progressBar.y = Std.parseFloat(elemNode.att.y);
			var mask = null;
			for(child in elemNode.elements){
				if(child.name.toLowerCase() == "mask"){
					var tile = new TileImage(child, layer);
					tile.set_x(progressBar.x + tile.tileSprite.width/2);
					tile.set_y(progressBar.y + tile.tileSprite.height/2);
					mask = tile.getMask();
				}
				if(child.name.toLowerCase() == "bar"){
					var bar = new Sprite();
					var color = child.has.color ? Std.parseInt(child.att.color) : 0;
					var alpha = child.has.alpha ? Std.parseFloat(child.att.alpha) : 1;
					var x = child.has.x ? Std.parseFloat(child.att.x) : 0;
					var y = child.has.y ? Std.parseFloat(child.att.y) : 0;
					DisplayUtils.initSprite(bar, mask.width, mask.height, color, alpha, x, y);
					bar.scaleX = 0;
					progressBar.addChild(bar);
				}
				if(child.name.toLowerCase() == "cursor"){
					var tile = new TileImage(child, layer);
					tile.set_visible(false);
					cursor = new Bitmap(DisplayUtils.getBitmapDataFromLayer(tile.tileSprite.layer.tilesheet, tile.tileSprite.tile));
					cursor.x = child.has.x ? Std.parseFloat(child.att.x) : 0;
					cursor.y = child.has.y ? Std.parseFloat(child.att.y) : 0;
					progressBar.addChild(cursor);
				}
			}

			progressBar.mask = mask;
			progressBar.buttonMode = progressBar.useHandCursor = true;
			progressBar.mouseChildren = false;
			progressBar.addEventListener(MouseEvent.CLICK, onClickTimeline);
			addChild(mask);
			controls.add(progressBar);
		}
	}

	// Privates

	private function init():Void
	{
		addChild(progressBar);
		timeArea.style = "small-text";
		timeArea.setContent(videoTimeConvert(0) + "/" + videoTimeConvert(0));
	}

	private function onCaptureImage():Void{
		/*removeEventListener(Event.ENTER_FRAME, enterFrame);
		stream.pause();
		stream.seek(_timeToCapture);
		stream.resume();
		bCapture = true;
		_mc.barBg_mc._play.gotoAndStop(2);
		//dispatchEvent(new BitmapCaptureEvent(BitmapCaptureEvent.CAPTURE,imageCapture(),true));
		addEventListener(Event.ENTER_FRAME, enterFrame);*/
	}


	/*private function onSonIsDown(e:MouseEvent):Void{
		var mc:MovieClip = (e.target) as MovieClip;
		soundTransform.volume = mc.mouseX / mc.width;
		stream.soundTransform = soundTransform;
		trace(mc.mouseX);
		_mc.barBg_mc.pictoSon.mcTrack.x = mc.mouseX;
	}*/

	private function enterFrame(?e:Event):Void
	{
		var nowSecs:Float = Math.floor(stream.time);
		var totalSecs:Float = Math.floor(totalLength);

		/*if (bCapture2) {
			if (nowSecs >= (_timeToCapture)) {
				dispatchEvent(new BitmapCaptureEvent(BitmapCaptureEvent.CAPTURE,imageCapture(),true));
				bCapture2 = false;
			}
		}*/

		if(nowSecs > 0)	{
			timeArea.setContent("-"+videoTimeConvert(nowSecs) + "/" + videoTimeConvert(totalSecs));
			var amountPlayed:Float = nowSecs / totalSecs;
			var amountLoaded:Float = stream.bytesLoaded / stream.bytesTotal;
			var oldWidth = progressBar.getChildAt(1).width;
			progressBar.getChildAt(1).scaleX = amountPlayed;
			progressBar.getChildAt(0).scaleX = amountLoaded;
			cursor.x += progressBar.getChildAt(1).width - oldWidth;

			if(stream.time>=totalLength){
				dispatchEvent(new Event(Event.COMPLETE));
				stream.seek(0);
				setFullScreen(false);
				if(!loop)
					pauseVideo();
			}
		}
	}

	private function onClickTimeline(e:MouseEvent):Void
	{
		trace("clic");
		var _percent:Float = (e.localX-progressBar.x) * 100 / progressBar.width;
		var timeToGo:Float = totalLength*_percent/100;
		setPlaying(false);
		stream.seek(timeToGo);
		stream.resume();
		setPlaying(true);
	}

	private function netStatusHandler(event:NetStatusEvent):Void {
		/*switch (event.info.code) {
			case "NetStream.Buffer.Full":
				stream.bufferTime = xpandedBufferLength;
				if (_timeToCapture > 0 && !bCapture) {
					bCapture = true;
					onCaptureImage();
				}
				if (bCapture) {
					bCapture2 = true;
				}

			case "NetStream.Buffer.Empty":
				stream.bufferTime = startBufferLength;
		}*/
	}

	// Refactor
	private function videoTimeConvert(pTime: Float):String {
		var tempNum = pTime;
		var minutes = Math.floor(tempNum / 60);
		var hours: Float = 0;
		var currentTimeConverted: String;
		if (displayHours && minutes/60 >= 1) {
			hours = Math.floor(minutes / 60);
			currentTimeConverted = hours+":";
		}
		else
			currentTimeConverted = "";
		var seconds = Math.round(tempNum - (minutes * 60));

		return currentTimeConverted + minutes + ":" + seconds;
	}

	private function setPlaying(isPlaying: Bool){
		for(button in playButtons)
			button.setToggle(!isPlaying);
		this.isPlaying = isPlaying;
	}

	private function showControls(e:MouseEvent):Void
	{
		if(controlsHidden){
			for(control in controls){
				TweenManager.applyTransition(control, transitionIn);
			}
			TweenManager.applyTransition(layer.view, transitionIn);
			controlsHidden = false;
		}
	}

	private function hideControls(e:MouseEvent):Void
	{
		if(!controlsHidden){
			for(control in controls){
				TweenManager.applyTransition(control, transitionOut);
			}
			TweenManager.applyTransition(layer.view, transitionOut);
			controlsHidden = true;
		}
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
		controls.add(button);
	}

}
#else
typedef VideoPlayer = Dynamic;
#end
