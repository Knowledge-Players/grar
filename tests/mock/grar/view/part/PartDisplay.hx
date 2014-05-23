package grar.view.part;

import grar.util.Point;

import grar.view.style.TextDownParser;
import grar.view.component.SoundPlayer;
import grar.view.component.VideoPlayer;


using StringTools;
using Lambda;

enum InputEvent{
    CLICK(name: String);
    MOUSE_DOWN(name: String);
    MOUSE_UP(name: String, targetId: String);
    MOUSE_OVER(name: String);
}

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

    public var ref (default, set):String;

    static var CLICK = "click";
    static var MOUSE_DOWN = "mouseDown";
    static var MOUSE_UP = "mouseUp";
    static var MOUSE_OVER = "mouseOver";

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

    public function set_ref(ref:String):String
    {

        return ref;
    }


///
// API
//

    public function showBackground(background : String) : Void {

    }

    public function hideBackground(oldBackground:String):Void
    {

    }

    public function showSpeaker(speaker : String) : Void {

    }

    public function hideSpeaker(speaker : String) : Void {

    }

    public function setText(itemRef: String, content: String):Void
    {

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

    public function toggleElement (id:String):Void {
    }

    public function setVideo(videoRef:String, uri: String, autoStart: Bool = false, loop: Bool = false, defaultVolume: Float = 1, capture: Float = 0, fullscreen : Bool = false, ?onVideoPlay: Void -> Void, ?onVideoEnd: Void -> Void):Void
    {

    }

    public function setSound(soundRef:String, uri:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 1):Void
    {

    }

    public function displayElements(elements:List<String>):Void
    {

    }

	public function hideElementsByClass(className: String):Void
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

    public function createInputs(refs: List<{ref: String, id: String, content: Map<String, String>, icon: Map<String, String>}>, groupeRef: String):Void
    {

    }

    public function startDrag(id:String, mousePoint: Point):Void
    {

    }

    public function stopDrag(id:String, dropId: String, isValid: Bool, mousePoint:Point):Void
    {
    }

    public function setInputComplete(id:String):Void
    {
    }

}
