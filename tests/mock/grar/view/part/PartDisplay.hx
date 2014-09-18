package grar.view.part;

import grar.model.InventoryToken.TokenTrigger;
import grar.controller.PartController.InputCallback;
import grar.util.TextDownParser;
import grar.model.part.item.Item;
import grar.util.Point;

using StringTools;
using Lambda;

typedef InputData = {
	ref: String,
	id: String,
	content: Map<String, String>,
	icon: Map<String, String>,
	selected: Bool
}

typedef Element = String;

/**
 * Display of a part
 */
class PartDisplay{

/**
     * Constructor
     * @param	part : Part to display
     */
    public function new() {
    }

    public var introScreenOn (default, null) : Bool = false;

	public var markupParser (default, default):TextDownParser;

    public static var CLICK = "click";
    public static var MOUSE_DOWN = "mouseDown";
    public static var MOUSE_UP = "mouseUp";
    public static var MOUSE_OVER = "mouseOver";
    public static var MOUSE_OUT = "mouseOut";

///
// CALLBACKS
//

	public dynamic function onActivateTokenRequest(token : String) : Void { }
	public dynamic function onIntroEnd():Void { }
	public dynamic function onValidationRequest(inputId: String, ?value: String, ?dragging: Bool = false): Void {}
	public dynamic function onChangePatternRequest(patternId: String): Void {}
	public dynamic function onSubtitleRequest(uri: String, callback: SubtitleData -> Void): Void {}
	public dynamic function onTokenActivation(tokenId: String): Void {}


///
// GETTER / SETTER
//

    public function init(ref:String, ?next: Bool = true, ?noReload = false):Void
    {
    }


///
// API
//

	public function unloadPart(partRef:String):Void {}

    public function showBackground(background : String) : Void {

    }

    public function hideBackground(oldBackground:String):Void
    {

    }

    public function showSpeaker(speaker : String) : Void {

    }

    public function hideSpeaker(speaker : String) : Void {

    }
	public function setSpeakerLabel(speakerName:String):Void
	{}

    public function setText(itemRef: String, content: String):Null<Element>
    {
		return null;
    }

	public function hideText(itemRef: String):Void
	{

	}
	public function setImage(itemRef: String, src: String):Void
    {

    }

	public function unsetImage(imageRef:String):Void
	{

	}
    public function showPattern(ref:String):Void
    {

    }
    public function hidePattern(ref:String):Void
    {

    }

    public function setIntroText(fieldRef: String, content: String):Void
    {

    }

	public function switchElementToVisited (id:String):Void {
	}

    public function toggleElement (id:String, ?force: Bool):Void {
    }

    public function setVideo(videoRef:String, uri: String, videoData: VideoData, ?tokens: Array<TokenTrigger>, ?onVideoPlay: Void -> Void, ?onVideoEnd: Void -> Void, ?locale: String):Void
    {

    }

	public function hideVideoPlayer():Void
	{}

	public function setSound(soundRef:String, uri:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 1, ?onSoundEnd: Void -> Void):Void
    {

    }

	public function setVoiceOver(voiceOverUrl:String, volume: Float, ?textRef: String):Void{}
	public function stopVoiceOver():Void
	{}
	public function onMasterVolumeChanged(volume: Float):Void
	{}

    public function displayElements(?elements:List<String>, ?elem: String):Void
    {

    }

	public function setDebrief(ref:String, content:String):Void
	{
	}

	public function createChoices(refs: List<{ref: String, id: String, icon: Map<String, String>, content: Map<String, String>, selected: Bool, goto: String}>, groupeRef: String):Void
	{

	}

	public function unsetDebrief(debriefRef:String):Void {}

	public function showDebriefZone(debriefRef:String):Void
	{}

    public function hideElements(?elements:List<String>, ?elem: String):Void
    {

    }

	public function hideElementsByClass(className: String):Void
	{}

	public function removeElement(elemId:String):Void
	{}

    public function reset():Void
    {

    }

	public function disableNextButtons():Void
	{
	}

	public function enableNextButtons():Void
	{
	}

    public function setButtonAction(buttonId: String, actionName: String, action : Void -> Void) : Void {

    }

    public function createInputs(refs: List<InputData>, groupeRef: String, callbacks: InputCallback, ?autoValidation: Bool = true, ?position: Array<Point>):Void
    {

    }
	public function setRoundNumber(roundNumber:Int, totalRound:Int, ?groupRef: String):Void {}

    public function startDrag(id:String):Void
    {

    }

    public function stopDrag(id:String, dropId: String, isValid: Bool, isCorrect: Bool):Void
    {
    }

    public function setInputComplete(id:String):Void
    {
    }

    public function setInputState(id:String, state: String):Void
    {
    }

	public function removeInputState(inputId:String, state: String): Void
	{}

	public function toggleValidationButtons(?force: Bool):Void
	{}
    public function uncheckElement (id:String):Void {
    }



	public function isVideoFullscreen():Bool
	{
		return false;
	}

}
