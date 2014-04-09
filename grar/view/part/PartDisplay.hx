package grar.view.part;

import grar.view.component.SoundPlayer;
import grar.view.component.VideoPlayer;

import js.html.Document;
import js.html.Element;


using StringTools;

/**
 * Display of a part
 */
class PartDisplay{

	/**
     * Constructor
     * @param	part : Part to display
     */
	public function new(callbacks : grar.view.DisplayCallbacks) {

		this.onActivateTokenRequest = function(tokenId : String){ callbacks.onActivateTokenRequest(tokenId); }

	}

	public var introScreenOn (default, null) : Bool = false;

	public var ref (default, set):String;

	var root:Element;
	var document:Document;
	var videoPlayer: VideoPlayer;
	var soundPlayer: SoundPlayer;


	///
	// CALLBACKS
	//

	public dynamic function onExit() : Void { }

	//public dynamic function onEnterSubPart(sp : Part) : Void { }

	public dynamic function onPartLoaded() : Void { }

	public dynamic function onGameOver() : Void { }

	public dynamic function onActivateTokenRequest(token : String) : Void { }

	public dynamic function onNextRequest(?startIndex : Int = -1): Void { }

	public dynamic function onExitPart(?completed : Bool = true): Void { }

	public dynamic function onIntroEnd():Void { }

	///
	// GETTER / SETTER
	//

	public function set_ref(ref:String):String
	{
		root = js.Browser.document.getElementById(ref);
		root.style.display = "block";
		return this.ref = ref;
	}


	///
	// API
	//

	public function showBackground(background : String) : Void {
		if(background != null)
			root.classList.add(background);
	}

	public function hideBackground(oldBackground:String):Void
	{
		if(oldBackground != null)
			root.classList.remove(oldBackground);
	}

	public function showSpeaker(speaker : String) : Void {
		if(speaker != null){
			var char = getChildById("speaker");
			char.classList.add(speaker);
			show(char);
		}
	}

	public function hideSpeaker(speaker : String) : Void {
		if(speaker != null){
			var char = getChildById("speaker");
			char.classList.remove(speaker);
			hide(char);
		}
	}

	public function setText(itemRef: String, content: String):Void
	{
		if (itemRef != null) {
			var text = getChildById(itemRef);
			text.innerHTML = content;
			show(text);
		}
	}

	public function setIntroText(fieldRef: String, content: String):Void
	{
		getChildById(fieldRef).innerHTML = content;
	}

	public function setVideo(videoRef:String, uri: String, autoStart: Bool = false, loop: Bool = false, defaultVolume: Float = 1, capture: Float = 0, fullscreen : Bool = false, ?onVideoPlay: Void -> Void, ?onVideoEnd: Void -> Void):Void
	{
		if(videoPlayer == null)
			videoPlayer = new VideoPlayer();
		videoPlayer.init(cast getChildById(videoRef));
		show(videoPlayer.root);
		videoPlayer.setVideo(uri, autoStart, loop, defaultVolume, capture, fullscreen, onVideoPlay, onVideoEnd);
	}

	public function setSound(soundRef:String, uri:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 1):Void
	{
		if(soundPlayer == null)
			soundPlayer = new SoundPlayer();
		soundPlayer.init(cast getChildById(soundRef));
		soundPlayer.setSound(uri, autoStart, loop, defaultVolume);
	}

	public function displayElements(elements:List<String>):Void
	{
		for(elem in elements)
			show(getChildById(elem));
	}

	public function reset():Void
	{
		for(child in root.childNodes)
			if(child.nodeType == 1)
				hide(cast child);
	}

	public function setButtonAction(buttonId: String, action : Void -> Void) : Void {

		getChildById(buttonId).onclick = function(_) action();
	}

	///
	// INTERNALS
	//

	/**
     * Unload the display from the scene
     */

	private function unLoad():Void
	{
		root.style.display = "none";
	}

	private inline function hide(elem: Element) {
		elem.classList.remove("visible");
		elem.classList.add("hidden");
		if(videoPlayer != null && elem == videoPlayer.root)
			videoPlayer.stop();
		else if(soundPlayer != null && elem == soundPlayer.root)
			soundPlayer.pause();
	}

	private inline function show(elem: Element) {
		elem.classList.remove("hidden");
		elem.classList.add("visible");
	}

	private function getChildById(id:String):Element
	{
		var child = root.querySelector('#'+id);
		if(child == null)
			throw "Unable to find a child of "+root.id+" with id '"+id+"'.";
		return child;
	}
}
