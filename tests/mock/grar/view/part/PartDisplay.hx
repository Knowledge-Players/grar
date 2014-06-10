package grar.view.part;

import grar.util.Point;

using StringTools;
using Lambda;

enum InputEvent{
    CLICK;
    MOUSE_DOWN;
    MOUSE_UP(targetId: String);
    MOUSE_OVER;
}

typedef Element = String;

/**
 * Display of a part
 */
class PartDisplay extends BaseDisplay{

/**
     * Constructor
     * @param	part : Part to display
     */
    public function new(callbacks : grar.view.DisplayCallbacks) {
		super();
    }

    public var introScreenOn (default, null) : Bool = false;

    public static var CLICK = "click";
    public static var MOUSE_DOWN = "mouseDown";
    public static var MOUSE_UP = "mouseUp";
    public static var MOUSE_OVER = "mouseOver";

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

    public dynamic function onInputEvent(type: InputEvent, inputId: String, mousePoint: Point): Void {}

	public dynamic function onHeaderStateChangeRequest(state: String) : Void { }

	public dynamic function onValidationRequest(inputId: String): Void {}

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

    public function setText(itemRef: String, content: String):Null<Element>
    {
		return null;
    }
	public function setImage(itemRef: String, src: String):Void
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

    public function setVideo(videoRef:String, uri: String, autoStart: Bool = false, loop: Bool = false, defaultVolume: Float = 1, capture: Float = 0, fullscreen : Bool = false, ?onVideoPlay: Void -> Void, ?onVideoEnd: Void -> Void):Void
    {

    }

    public function setSound(soundRef:String, uri:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 1):Void
    {

    }

    public function displayElements(?elements:List<String>, ?elem: String):Void
    {

    }

	public function setDebrief(ref:String, content:String):Void
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

    public function createInputs(refs: List<{ref: String, id: String, content: Map<String, String>, icon: Map<String, String>}>, groupeRef: String, ?autoValidation: Bool = true):Void
    {

    }
	public function setRoundNumber(roundNumber:Int, totalRound:Int, ?groupRef: String):Void {}

    public function startDrag(id:String, mousePoint: Point):Void
    {

    }

    public function stopDrag(id:String, dropId: String, isValid: Bool, mousePoint:Point):Void
    {
    }

    public function setInputComplete(id:String):Void
    {
    }

    public function setInputState(id:String, state: String):Void
    {
    }

	public function toggleValidationButtons(?force: Bool):Void
	{}
    public function uncheckElement (id:String):Void {
    }

}
