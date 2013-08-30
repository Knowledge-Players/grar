package com.knowledgeplayers.grar.display.component.container;

import flash.display.Bitmap;
import aze.display.TileLayer;
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
	private var cursor: Sprite;
	private var lockCursor: Bool;
	private var soundSlider: Image;
	private var soundCursor: Sprite;
		//private var _timeToCapture : Float = 0;

	public function new (?xml: Fast)
	{
		playButtons = new GenericStack<DefaultButton>();
		controls = new GenericStack<Widget>();

		super(xml);
		video = new Video();

		connection = new NetConnection();
		connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		addEventListener(Event.REMOVED_FROM_STAGE , unsetVideo, false, 0, true);
		connection.connect(null);

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
		stream = new NetStream(connection);
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
		isFullscreen = fullscreen;
		if (isFullscreen) {
			//width = video.videoWidth;
			//height = video.videoHeight;
			stage.fullScreenSourceRect = new Rectangle(x, y,video.videoWidth, video.videoHeight);
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
		// TODO widgetContainer
		if(elemNode.name.toLowerCase() == "progressbar"){
			progressBar = new Image();
			progressBar.x = Std.parseFloat(elemNode.att.x);
			progressBar.y = Std.parseFloat(elemNode.att.y);
			var mask: Sprite = null;
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
					var tile = new TileImage(child, new TileLayer(layer.tilesheet));
					//tile.set_visible(false);
					cursor = new Sprite();
					cursor.addChild(new Bitmap(DisplayUtils.getBitmapDataFromLayer(tile.tileSprite.layer.tilesheet, tile.tileSprite.tile)));
					cursor.x = (child.has.x ? Std.parseFloat(child.att.x) : 0) + progressBar.x;
					cursor.y = (child.has.y ? Std.parseFloat(child.att.y) : 0) + progressBar.y;
				}
			}

			progressBar.mask = mask;
			mask.mouseEnabled = false;
			content.addChild(mask);
			controls.add(progressBar);
		}
		else if(elemNode.name.toLowerCase() == "slider"){
			soundSlider = new Image();
			soundSlider.x = Std.parseFloat(elemNode.att.x);
			soundSlider.y = Std.parseFloat(elemNode.att.y);
			for(child in elemNode.elements){
				if(child.name.toLowerCase() == "bar"){
					var tile = new TileImage(child, new TileLayer(layer.tilesheet));
					var cur = new Bitmap(DisplayUtils.getBitmapDataFromLayer(tile.tileSprite.layer.tilesheet, tile.tileSprite.tile));
					cur.x = child.has.x ? Std.parseFloat(child.att.x) : 0;
					cur.y = child.has.y ? Std.parseFloat(child.att.y) : 0;
					soundSlider.addChild(cur);
				}
				if(child.name.toLowerCase() == "cursor"){
					var tile = new TileImage(child, new TileLayer(layer.tilesheet));
					soundCursor = new Sprite();
					soundCursor.addChild(new Bitmap(DisplayUtils.getBitmapDataFromLayer(tile.tileSprite.layer.tilesheet, tile.tileSprite.tile)));
					soundCursor.x = (child.has.x ? Std.parseFloat(child.att.x) : 0) + soundSlider.x + (child.has.vol ? Std.parseFloat(child.att.vol)/100 : 1)*soundSlider.width - soundCursor.width/2;
					soundCursor.y = (child.has.y ? Std.parseFloat(child.att.y) : 0) + soundSlider.y;

				}
			}
			soundSlider.mouseEnabled = false;
			controls.add(soundSlider);
		}
	}

	// Privates

	private function init():Void
	{
		content.addChild(progressBar);
		content.addChild(soundSlider);
		content.addEventListener(MouseEvent.CLICK, onClickTimeline);
		content.addChild(cursor);
		content.addChild(soundCursor);
		cursor.buttonMode = true;
		cursor.addEventListener(MouseEvent.MOUSE_DOWN, dragCursor);
		soundCursor.buttonMode = true;
		soundCursor.addEventListener(MouseEvent.MOUSE_DOWN, dragSoundCursor);
		timeArea.style = "small-text";
		timeArea.setContent(videoTimeConvert(0) + "/" + videoTimeConvert(0));
	}

	private function dragCursor(e:MouseEvent):Void
	{
		cursor.startDrag(false, new Rectangle(progressBar.x-cursor.width/2,progressBar.y-cursor.height/3,progressBar.width, 0));
		addEventListener(MouseEvent.MOUSE_UP, dropCursor);
	}

	private function dragSoundCursor(e:MouseEvent):Void
	{
		soundCursor.startDrag(false, new Rectangle(soundSlider.x-soundCursor.width/2,soundSlider.y,soundSlider.width, 0));
		addEventListener(MouseEvent.MOUSE_UP, dropSoundCursor);
	}

	private function dropCursor(e:MouseEvent):Void
	{
		cursor.stopDrag();
		removeEventListener(MouseEvent.MOUSE_UP, dropCursor);
		var ratio = (cursor.x + cursor.width/2 - progressBar.x) / progressBar.width;
		fastForward(ratio);
	}

	private function dropSoundCursor(e:MouseEvent):Void
	{
		soundCursor.stopDrag();
		removeEventListener(MouseEvent.MOUSE_UP, dropSoundCursor);
		var ratio = (soundCursor.x + soundCursor.width/2 - soundSlider.x) / soundSlider.width;
		changeVolume(ratio);
	}

	private function fastForward(ratio: Float):Void
	{
		var position = Math.floor(totalLength)*ratio;
		stream.seek(position);
		lockCursor = true;
	}

	private function changeVolume(ratio:Float):Void
	{
		stream.soundTransform = new SoundTransform(ratio);
	}

	private function onClickTimeline(e:MouseEvent):Void
	{
		if(progressBar.getRect(this).contains(e.localX, e.localY)){
			var ratio = (e.localX - progressBar.x) / progressBar.width;
			fastForward(ratio);
		}
		else{
			var bounds: Rectangle = soundSlider.getRect(this);
			// Hack: increase slider height
			bounds.height +=5;
			if(bounds.contains(e.localX, e.localY)){
				soundCursor.x = e.localX - soundCursor.width/2;
				var ratio = (e.localX - soundSlider.x) / soundSlider.width;
				changeVolume(ratio);
			}
		}
	}

	private function onCaptureImage():Void{
		/*removeEventListener(Event.ENTER_FRAME, enterFrame);
		stream.pause();
		stream.seek(_timeToCapture);
		stream.resume();
		bCapture = true;
		_mc.barBg_mc._play.gotoAndStop(2);
		dispatchEvent(new BitmapCaptureEvent(BitmapCaptureEvent.CAPTURE,imageCapture(),true));
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
			if(!lockCursor){
				cursor.x += progressBar.getChildAt(1).width - oldWidth;
			}
			else{
				cursor.x = progressBar.getChildAt(1).width + progressBar.x - cursor.width/2;
				lockCursor = false;
			}
			if(stream.time>=totalLength){
				dispatchEvent(new Event(Event.COMPLETE));
				stream.seek(0);
				setFullScreen(false);
				if(!loop)
					pauseVideo();
			}
		}
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

	// TODO Refactor
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

		return currentTimeConverted + (minutes < 10 ? "0":"")+ minutes + ":" +(seconds < 10 ? "0":"")+seconds;
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
