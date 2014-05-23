package grar.view.part;

import js.html.InputElement;
import grar.view.guide.Absolute;
import grar.view.guide.Guide;
import haxe.Http;

import grar.util.Point;
import grar.view.style.TextDownParser;
import grar.view.part.PartDisplay.InputEvent;
import grar.view.guide.Grid;
import grar.view.component.SoundPlayer;
import grar.view.component.VideoPlayer;

import js.Browser;
import js.html.Element;
import js.html.Event;
import js.html.MouseEvent;
import js.html.Node;
import js.html.AnchorElement;
import js.html.ImageElement;
import js.html.ClientRect;
import js.html.TouchEvent;
import js.html.UIEvent;

using StringTools;
using Lambda;

enum InputEvent{
	//Remove name param
    MOUSE_OVER(name: String);
	CLICK(name: String);
	MOUSE_DOWN(name: String);
	MOUSE_UP(name: String, targetId: String);
}

/**
 * Display of a part
 */
class PartDisplay extends BaseDisplay
{

	/**
     * Constructor
     * @param	part : Part to display
     */
	public function new(callbacks : grar.view.DisplayCallbacks) {

		super();

		this.onActivateTokenRequest = function(tokenId : String){ callbacks.onActivateTokenRequest(tokenId); }

		// TODO deplacer dans la Config
		#if js
		isMobile = ~/ipad|iphone|ipod|android|mobile/i.match(Browser.navigator.userAgent);
		#end
	}

	public var introScreenOn (default, null) : Bool = false;

	public var ref (default, set):String;

	static var CLICK = "click";
	static var MOUSE_DOWN = "mouseDown";
	static var MOUSE_UP = "mouseUp";
	static var MOUSE_OVER = "mouseOver";

	var videoPlayer: VideoPlayer;
	var soundPlayer: SoundPlayer;
	var dragParent:Element;
	var isMobile: Bool;


	///
	// CALLBACKS
	//

	public dynamic function onExit() : Void { }

	//public dynamic function onEnterSubPart(sp : Part) : Void { }

	public dynamic function onPartLoaded() : Void { }

	public dynamic function onHeaderStateChangeRequest(state: String) : Void { }

	public dynamic function onActivateTokenRequest(token : String) : Void { }

	public dynamic function onNextRequest(?startIndex : Int = -1): Void { }

	public dynamic function onExitPart(?completed : Bool = true): Void { }

	public dynamic function onIntroEnd():Void { }

	public dynamic function onInputEvent(type: InputEvent, inputId: String, mousePoint: Point): Void {}

	public dynamic function onValidationRequest(inputId: String): Void {}

	///
	// GETTER / SETTER
	//

	public function set_ref(ref:String):String
	{
		//if(root != null)
			//hide(root);
		if(ref.indexOf("#") == -1)
			root = Browser.document.getElementById(ref);
		else{
			// Insert HTML into the layout
			// TODO GLOBAL: Utiliser des iframes et ici set src
			var ids = ref.split("#");
			root = Browser.document.getElementById(ids[1]);
			var http = new Http(ids[0]);
			http.onData = function(data){
				root.innerHTML = data;
				for(child in root.children){
					if(child.nodeType == Node.ELEMENT_NODE)
						if(Std.instance(child, Element).hasAttribute("data-layout-state")){
							onHeaderStateChangeRequest(Std.instance(child, Element).getAttribute("data-layout-state"));
						}
				}

				onPartLoaded();
			}

			http.onError = function(msg){
				throw "Can't load '"+ids[0]+"'.";
			}
			http.request();
		}

		show(root);

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
		if(itemRef != null) {
			show(doSetText(itemRef, content));
		}
	}

	public function setImage(imageRef:String,src:String):Void{

		if(imageRef != null){

			var elem:Element =getChildById(imageRef);
            //use of Std.instance
            var img:ImageElement = Std.instance(elem,ImageElement);
            img.src = src;

			show(img);

		}
	}
    public function hidePattern(ref:String):Void{
        var pat = getChildById(ref);
        hide(pat);
    }
    public function showPattern(ref:String):Void{
        var pat = getChildById(ref);
        show(pat);
    }

	public function setIntroText(fieldRef: String, content: String):Void
	{
		var field = getChildById(fieldRef);
		for(elem in markupParser.parse(content))
			field.appendChild(elem);
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

    public function hideElements(elements:List<String>):Void
	{
		for(elem in elements)
			hide(getChildById(elem));
	}

	public function hideElementsByClass(className: String):Void
	{
		for(elem in root.getElementsByClassName(className))
			hide(Std.instance(elem, Element));
	}

	public function reset():Void
	{
		/*for(child in root.childNodes)
			if(child.nodeType == Node.ELEMENT_NODE)
				hide(cast child);
        */
	}

	public function disableNextButtons():Void
	{
		for(b in root.getElementsByClassName("next"))
			Std.instance(b, Element).classList.add("disabled");
	}

	public function enableNextButtons():Void
	{
		for(b in root.getElementsByClassName("next"))
			Std.instance(b, Element).classList.remove("disabled");
	}

	public function setButtonAction(buttonId: String, actionName: String, action : Void -> Void) : Void {

		var b: Element = getChildById(buttonId);
		b.onclick = function(_) action();
		b.classList.add(actionName);
	}

	public function createInputs(refs: List<{ref: String, id: String, content: Map<String, String>, icon: Map<String, String>}>, groupeRef: String):Void
	{
		var parent = getChildById(groupeRef);
		var guide: Guide = null;
		if(parent.hasAttribute("data-grid")){
			var data = parent.getAttribute("data-grid").split(",");
			if(data.length > 1)
                guide = new Grid(parent, Std.parseInt(data[0]), Std.parseInt(data[1]));
			else
                guide = new Grid(parent, Std.parseInt(data[0]));
		} else if (parent.hasAttribute("data-absolute")) {
            var data = parent.getAttribute("data-absolute").split(",");

            var points = new Array<Point>();
            for (s in data) {
               var p:Point = new Point(Std.parseFloat(s.split(";")[0]),Std.parseFloat(s.split(";")[1]));
               points.push(p);
            }
            guide = new Absolute(parent, points);
        }

		var i = 0;
		var templates = new Map<String, Element>();
		for(r in refs){
			// Get template and store it if necessary
			var t: Element;
			if(templates.exists(r.ref))
				t = templates[r.ref];
			else{
				t = getChildById(r.ref);
				templates[r.ref] = t;
				// Remove template
				// t.remove() not compatible with IE and Safari
				t.parentElement.removeChild(t);
			}

			// Clone
			var newInput: Element = cast t.cloneNode(true);

			// Set attributes
			newInput.id = r.id;
			newInput.classList.add("inputs");
            recursiveSetId(newInput, r.id);

			// Add to DOM
			if(guide != null)
				guide.add(newInput);
			else
				parent.appendChild(newInput);

			// Setting input text
			for(key in r.content.keys()){
				if(key != "_"){
					doSetText(r.id+"_"+key, r.content[key]);
				}
				else{
					for(elem in markupParser.parse(r.content[key]))
						newInput.appendChild(elem);
				}
			}
			// Setting icons
			for(key in r.icon.keys()){
				var url = 'url('+r.icon[key]+')';
				if(key != "_"){
					var img = getChildById(r.id+"_"+key, newInput);
					if(Std.is(img, ImageElement))
						Std.instance(img, ImageElement).src = r.icon[key];
					else
						img.style.backgroundImage = url;
				}
				else{
					newInput.style.backgroundImage = url;
				}
			}
			// Event Binding
			var onStart = function(e: MouseEvent){
				if(isMobile || e.button == 0){
					e.preventDefault();
					if(!Std.is(e.target, AnchorElement))
						onInputEvent(InputEvent.MOUSE_DOWN(MOUSE_DOWN), newInput.id, getMousePosition(e));
				}

			};
			if(isMobile)
				newInput.ontouchstart = onStart;
			else
				newInput.onmousedown = onStart;

			newInput.onclick = function(e: MouseEvent){
				onInputEvent(InputEvent.CLICK(CLICK), newInput.id, getMousePosition(e));
				onValidationRequest(newInput.id);
			}

            newInput.onmouseover = function(e:MouseEvent) onInputEvent(InputEvent.MOUSE_OVER(MOUSE_OVER), newInput.id, getMousePosition(e));
			// Display
			show(newInput);
			i++;
		}

		show(parent);
	}

    private function recursiveSetId(element:Element, ref:String):Void {
        for(child in element.children){
            if (child.nodeType == Node.ELEMENT_NODE) {
                var element:Element = cast child;

                if(element.id != ""){
                    element.id = ref+"_"+ element.id ;
                }
                if(element.hasAttribute("for")){
                    element.setAttribute("for", ref+"_"+ element.getAttribute("for"));
                }
                recursiveSetId(cast child,ref);
            }
        }
    }

    public function switchElementToVisited (id:String):Void {
        var elem:Element = cast getChildById(id);
        for (e in elem.getElementsByTagName("input")) {
            cast(e, InputElement).checked = true;
        }
    }

    public function toggleElement (id:String):Void {
        var elem:Element = cast getChildById(id);
        for (e in elem.getElementsByTagName("input")) {
            Std.instance(e, InputElement).checked = !Std.instance(e, InputElement).checked;
        }
    }

	public function startDrag(id:String, mousePoint: Point):Void
	{
		// See if e.dataTransfer.setDragImage() can be use instead
		var elem: Element = getChildById(id);
		dragParent = elem.parentElement;
		elem.draggable = true;

		// Extract element for its div
		root.appendChild(elem);
		var bound = elem.getBoundingClientRect();
		elem.style.position = "absolute";
		elem.style.left = (mousePoint.x-bound.width/2)+"px";
		elem.style.top = (mousePoint.y-bound.height/2)+"px";

		// Release mouse
		for(input in Browser.document.getElementsByClassName("inputs")){

		}
		var onEnd = function(e: Event) {
			var drop = getDroppedElement(mousePoint, elem.id);
			onInputEvent(InputEvent.MOUSE_UP(MOUSE_UP, drop != null ? drop.id : ""), elem.id, mousePoint);
		};
		if(isMobile){
			root.ontouchend = onEnd;
		}
		else{
			root.onmouseup = onEnd;
		}

		// Detect mouse movements
		var onMove = function(e: UIEvent){
			e.preventDefault();
			mousePoint = getMousePosition(e);
			elem.style.left = (mousePoint.x-bound.width/2)+"px";
			elem.style.top = (mousePoint.y-bound.height/2)+"px";
		}
		if(isMobile)
			root.ontouchmove = onMove;
		else
			root.onmousemove = onMove;
	}

	public function stopDrag(id:String, dropId: String, isValid: Bool, mousePoint:Point):Void
	{
		var drag = getChildById(id);
		drag.style.top = "0px";
		drag.style.left = "0px";
		drag.style.position = "static";
		root.onmousemove = root.ontouchmove = null;
		if(isValid){
			getChildById(dropId).appendChild(drag);
			drag.draggable = false;
			drag.style.margin = "0px";
			drag.classList.add("true");
		}
		else{
			dragParent.appendChild(drag);
		}

		// TODO callback onValidationRequest()
	}

	public function setInputComplete(id:String):Void
	{
		getChildById(id).classList.add("complete");
	}

	///
	// INTERNALS
	//

	private inline function getMousePosition(e: UIEvent):Point
	{
		var x = (Browser.document.documentElement.scrollLeft != null ? Browser.document.documentElement.scrollLeft : Browser.document.body.scrollLeft);
		var y = (Browser.document.documentElement.scrollTop != null ? Browser.document.documentElement.scrollTop : Browser.document.body.scrollTop);
		// TODO get correct scroll
		//trace(x,y);

		if(isMobile){
			var event: TouchEvent = cast e;
			var touch = event.touches.item(0);
			x += touch.clientX;
			y += touch.clientY;
		}
		else{
			var event: MouseEvent = cast e;
			x += event.clientX;
			y += event.clientY;
		}
		return new Point(x, y);
	}

	/**
     * Unload the display from the scene
     */
	private function unLoad():Void
	{
		root.style.display = "none";
	}

	private function getDroppedElement(mousePoint:Point, dragId: String):Null<Element>
	{
		for(input in Browser.document.getElementsByClassName("inputs")){
			var drop: Element = cast input;
			if(drop.id != dragId){
				var bounds: ClientRect = drop.getBoundingClientRect();
				if((bounds.left <= mousePoint.x && (bounds.left+bounds.width) >= mousePoint.x) && (bounds.top <= mousePoint.y && (bounds.top+bounds.height) >= mousePoint.y))
					return drop;
			}
		}
		// No element found
		return null;
	}

	override private function hide(elem:Element)
	{
		super.hide(elem);
		if(videoPlayer != null && elem == videoPlayer.root)
		videoPlayer.stop();
		else if(soundPlayer != null && elem == soundPlayer.root)
		soundPlayer.pause();
	}

}
