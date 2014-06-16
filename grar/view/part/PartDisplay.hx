package grar.view.part;

import haxe.Http;

import grar.util.ParseUtils;
import grar.util.Point;

import grar.view.style.TextDownParser;
import grar.view.part.PartDisplay.InputEvent;
import grar.view.component.SoundPlayer;
import grar.view.component.VideoPlayer;
import grar.view.guide.Absolute;
import grar.view.guide.Grid;
import grar.view.guide.Guide;

import grar.model.part.item.Item.VideoData;

import js.Browser;
import js.html.InputElement;
import js.html.Element;
import js.html.Event;
import js.html.MouseEvent;
import js.html.Node;
import js.html.AnchorElement;
import js.html.ImageElement;
import js.html.ClientRect;
import js.html.TouchEvent;
import js.html.UIEvent;
import js.html.Audio;
import js.html.AudioElement;

using StringTools;
using Lambda;

enum InputEvent{
    MOUSE_OVER;
	MOUSE_OUT;
	CLICK;
	MOUSE_DOWN;
	MOUSE_UP(targetId: String);
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


	public static var CLICK = "click";
	public static var MOUSE_DOWN = "mouseDown";
	public static var MOUSE_UP = "mouseUp";
	public static var MOUSE_OVER = "mouseOver";
	public static var MOUSE_OUT = "mouseOut";

	var videoPlayer: VideoPlayer;
	var soundPlayer: SoundPlayer;
	var dragParent:Element;
	var isMobile: Bool;
	var templates: Map<String, Element>;
	var playingSounds: Array<AudioElement>;


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

	public function init(ref:String, ?next: Bool = true, ?noReload = false):Void
	{
		// Init templates
		templates = new Map();
		// Init sounds
		if(playingSounds != null)
			playingSounds.iter(function(elem: AudioElement) elem.pause());
		playingSounds = new Array();

		// Check if a HTML template is needed
		if(ref.indexOf("#") == -1){
			root = Browser.document.getElementById(ref);
			if(!noReload)
				for(child in root.children)
					recursiveHide(getElement(child));
			show(root);
			onPartLoaded();
		}
		else{
			// Insert HTML into the layout
			// TODO GLOBAL: Utiliser des iframes et ici set src
			// TODO add stylesheets in the Browser.document.headElement
			var ids = ref.split("#");
			root = Browser.document.getElementById(ids[1]);

			if(noReload){
				show(root);
				return;
			}

            for(child in root.children){
                if(child.nodeType == Node.ELEMENT_NODE)
                if(Std.instance(child, Element).hasAttribute("data-layout-state")){
                    onHeaderStateChangeRequest(Std.instance(child, Element).getAttribute("data-layout-state")+"Remove");
                }
            }
			var http = new Http(ids[0]);
			http.onData = function(data){
				var hasChild = root.hasChildNodes();
				if(next)
				    root.innerHTML += data;

				else{
					root.innerHTML = (data + root.innerHTML);
					root.style.left = "-100%";
				}

				// If a part is already displayed
				if(hasChild){
					var listener = null;
					listener = function(_){
						root.removeEventListener('transitionend', listener);
						root.removeEventListener('webkitTransitionEnd', listener);
						if(next){
							root.style.transition = "none";
							// Remove all non-div elements
							while(root.children[0].nodeName.toLowerCase() != "div")
								root.removeChild(root.children[0]);
							// Remove the first div (= previous part display)
							root.removeChild(root.children[0]);
							root.classList.remove("nextTransition");
						}
						else{
                            root.removeChild(root.children[root.children.length-1]);

							var i = root.children.length-1;
							while(root.children[i].nodeName.toLowerCase() != "div") {
                                root.removeChild(root.children[i]);
                                i--;
                            }
							root.style.left = "";
							root.classList.remove("previousTransition");
						}

                        // If layout state need to be updated
                        for(child in root.children){
                            if(child.nodeType == Node.ELEMENT_NODE)
                            if(Std.instance(child, Element).hasAttribute("data-layout-state")){
                                onHeaderStateChangeRequest(Std.instance(child, Element).getAttribute("data-layout-state"));
                            }
                        }

						show(root);
						onPartLoaded();
					}
					root.addEventListener("transitionend",listener);
					root.addEventListener("webkitTransitionEnd",listener);

					if(!next){
						// Need to wait for next frame to see the animation
						var firstFrame = true;
						var update = null;
						update = function(_){
							if(firstFrame){
								firstFrame = false;
								Browser.window.requestAnimationFrame(update);
							}
							else{
								root.style.transition = "";
								root.classList.add("previousTransition");
							}
							return true;
						};
						Browser.window.requestAnimationFrame(update);
					}
					else{
						root.style.transition = "";
						root.classList.add("nextTransition");
					}
				}
				else{
					show(root);
					onPartLoaded();
				}
			}

			http.onError = function(msg){
				throw "Can't load '"+ids[0]+"'.";
			}
			http.request();
		}
	}


	///
	// API
	//

	public function unloadPart(partRef:String):Void
	{
		hideElements(partRef);
		for(t in templates)
			root.appendChild(t);
	}

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
			var char: Element = getChildById("speaker");
			char.classList.add(speaker);
			show(char);
			show(char.parentElement);
		}
	}

	public function hideSpeaker(speaker : String) : Void {
		if(speaker != null){
			var char = getChildById("speaker");
			char.classList.remove(speaker);
			hide(char);
		}
	}

	public function setText(itemRef: String, content: String):Null<Element>
	{
        var t:Element = doSetText(itemRef, content);
		if(t == null)
			return null;

		show(t);
		// Show children too
        for (child in t.children) {
            show(getElement(child));
        }

		// Verify parent is also visible
		if(!t.parentElement.classList.contains("hidden"))
			show(t.parentElement);

		return t;
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
        var pat: Element = getChildById(ref);
	    for(child in pat.children)
		    hide(cast child);
        hide(pat);
    }
    public function showPattern(ref:String):Void{
        var pat:Element = getChildById(ref);
        show(pat);

	    // Show the first non-visible child. Usefull for box in strip
	    for(child in pat.children){
	        var elem: Element = getElement(child);
	        if(!elem.classList.contains("visible")){
		        elem.classList.add("visible");
		        if(elem.classList.contains("hidden"))
			        elem.classList.remove("hidden");
		        break;
	        }
	    }
    }

	public function setIntroText(fieldRef: String, content: String):Void
	{
		var field = getChildById(fieldRef);
		for(elem in markupParser.parse(content))
			field.appendChild(elem);
	}

	public function setVideo(videoRef:String, uri: String, videoData: VideoData, ?onVideoPlay: Void -> Void, ?onVideoEnd: Void -> Void, ?locale: String):Void
	{
		if(videoPlayer == null)
			videoPlayer = new VideoPlayer();
		videoPlayer.init(cast getChildById(videoRef));
		show(videoPlayer.root);
		videoPlayer.setVideo(uri, videoData, onVideoPlay, onVideoEnd, locale);
	}

	public function setSound(soundRef:String, uri:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 1):Void
	{
		if(soundPlayer == null)
			soundPlayer = new SoundPlayer();
		soundPlayer.init(cast getChildById(soundRef));
		playingSounds.push(soundPlayer.root);
		soundPlayer.setSound(uri, autoStart, loop, defaultVolume);
	}

	public function setVoiceOver(voiceOverUrl:String, volume: Float):Void
	{
		var audio = new Audio();
		audio.autoplay = true;
		audio.volume = volume;
		playingSounds.push(audio);
		audio.src = voiceOverUrl;
		audio.play();
	}

	public function onMasterVolumeChanged(volume: Float):Void
	{
		playingSounds.iter(function(elem: AudioElement) elem.volume = volume);
	}

	public function showDebriefZone(debriefRef:String):Void
	{
		var debrief: Element = getChildById(debriefRef);
		if(debrief != null){
			for(child in debrief.children)
				recursiveShow(getElement(child));
			show(debrief);
		}
	}

	public function setDebrief(debriefRef:String, content:String):Void
	{
		setText(debriefRef, content);
		for(elem in root.getElementsByClassName("debriefable"))
			getElement(elem).classList.add("debrief");
		if(root.classList.contains("debriefable"))
			root.classList.add("debrief");
	}

	public function unsetDebrief(debriefRef:String):Void
	{
		var debrief = setText(debriefRef, "");
		if(debrief != null)
			hide(debrief);
		for(elem in root.getElementsByClassName("debriefable"))
			getElement(elem).classList.remove("debrief");
		if(root.classList.contains("debriefable"))
			root.classList.remove("debrief");
	}

	/**
	* Show elements with their ID
	* @param elements: List of ID to show
	* @param elem: unique ID to show. Usefull if you want to show only one element
	**/
	public function displayElements(?elements:List<String>, ?elem: String):Void
	{
		if(elem != null)
			show(getChildById(elem));
		else if(elements != null)
			for(element in elements)
				show(getChildById(element));
	}

	/**
	* Hide elements with their ID
	* @param elements: List of ID to hide
	* @param elem: unique ID to hide. Usefull if you want to hide only one element
	**/
    public function hideElements(?elements:List<String>, ?elem: String):Void
	{
		if(elem != null)
			hide(getChildById(elem));
		else if(elements != null)
			for(element in elements)
				hide(getChildById(element));
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
		b.onclick = function(_) !b.classList.contains("disabled") ? action() : null;
		b.classList.add(actionName);
		b.classList.remove("disabled");
	}

	public function createInputs(refs: List<{ref: String, id: String, content: Map<String, String>, icon: Map<String, String>, selected: Bool}>, groupeRef: String, ?autoValidation: Bool = true):Void
	{
		var parent: Element = getChildById(groupeRef);

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

		for(r in refs){
			// Get template and store it if necessary
			var t: Element;
			if(templates.exists(r.ref))
				t = templates[r.ref];
			else{
				t = getChildById(r.ref);
				templates[r.ref] = t;
				// Remove template
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

			// Adding numbering system if any
			for(num in newInput.getElementsByClassName("numbering")){
				setNumbering(num, i);
			}

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
			// Update state
			if(r.selected)
				newInput.classList.add("selected");

			// Event Binding
			var onStart = function(e: MouseEvent){
				if(isMobile || e.button == 0){
					e.preventDefault();
					if(!Std.is(e.target, AnchorElement))
						onInputEvent(InputEvent.MOUSE_DOWN, newInput.id, getMousePosition(e));
                    newInput.ontouchend = function(e: MouseEvent){
	                    if(autoValidation)
		                    onValidationRequest(newInput.id);
                        onInputEvent(InputEvent.CLICK, newInput.id, new Point(0,0));
                    }
				}

			};
			if(isMobile)
				newInput.ontouchstart = onStart;
			else
				newInput.onmousedown = onStart;

			newInput.onclick = function(e: MouseEvent){
				if(autoValidation)
					onValidationRequest(newInput.id);
				onInputEvent(InputEvent.CLICK, newInput.id, getMousePosition(e));
			}

            newInput.onmouseover = function(e:MouseEvent) onInputEvent(InputEvent.MOUSE_OVER, newInput.id, getMousePosition(e));
            newInput.onmouseout = function(e:MouseEvent) onInputEvent(InputEvent.MOUSE_OUT, newInput.id, getMousePosition(e));
			// Display
			show(newInput);
			i++;
		}

		// Set visible all the way to input
		var ancestor: Element = parent;
		while(ancestor != null && !ancestor.classList.contains("visible")){
			show(ancestor);
			ancestor = ancestor.parentElement;
		}
	}

	public function setRoundNumber(roundNumber:Int, totalRound:Int, ?groupRef: String):Void
	{
		var parent: Element = groupRef != null ? getChildById(groupRef) : root;
		for(num in parent.getElementsByClassName("roundNumbering"))
			setNumbering(num, roundNumber, "/"+totalRound);
	}

    public function toggleElement(id:String, ?force: Bool):Void {
        var elem:Element = getChildById(id);
        for (e in elem.getElementsByTagName("input")) {
            Std.instance(e, InputElement).checked = force != null ? force : !Std.instance(e, InputElement).checked;
        }
    }
    public function uncheckElement(id:String):Void {
        var elem:Element = getChildById(id);
        for (e in elem.getElementsByTagName("input")) {
            Std.instance(e, InputElement).checked = false;
        }
    }

	public function removeElement(elemId:String):Void
	{
		var elem: Element = getChildById(elemId);
		elem.parentElement.removeChild(elem);
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
			onInputEvent(InputEvent.MOUSE_UP(drop != null ? drop.id : ""), elem.id, mousePoint);
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
		var drag: Element = getChildById(id);
		drag.style.removeProperty("top");
		drag.style.removeProperty("left");
		drag.style.removeProperty("position");
        root.onmouseup = root.onmousemove = root.ontouchmove = null;
		if(isValid){
			var drop: Element = getChildById(dropId);
			var dropZone = drop.getElementsByClassName("dropZone");
			if(dropZone.length > 0)
				dropZone[0].appendChild(drag);
			else
				drop.appendChild(drag);

            drag.onmousedown = null;
            drag.onmouseup = null;
			drag.classList.add("true");
		}
		else{
			dragParent.appendChild(drag);
		}

		// TODO callback onValidationRequest()
	}

	/**
	* Shortcut for setInputState(id, "complete")
	* @param id: ID of the input
	**/
	public function setInputComplete(id:String):Void
	{
		setInputState(id, "complete");
	}

	public function setInputState(inputId:String, state: String): Void
	{
		getChildById(inputId).classList.add(state);
	}

	public function removeInputState(inputId:String, state: String): Void
	{
		getChildById(inputId).classList.remove(state);
	}

	public function toggleValidationButtons(?force: Bool):Void
	{
		for(b in root.getElementsByClassName("validate"))
			getElement(b).classList.toggle("disabled", force);
	}

	///
	// INTERNALS
	//

	private function setNumbering(node:Node, order: Int, ? suffix: String):Void
	{
		var elem: Element = getElement(node);
		if(elem != null){
			if(elem.hasAttribute("data-numbering")){
				var numbers = ParseUtils.parseListOfValues(elem.getAttribute("data-numbering"));
				if(order < numbers.length)
					elem.textContent = numbers[order];
			}
			else
				elem.textContent = Std.string(order+1);

			if(suffix != null)
				elem.textContent += suffix;
		}
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
	// TODO use scroll to get right drop
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

	private inline function getElement(node:Node):Null<Element>
	{
		if(node.nodeType == Node.ELEMENT_NODE)
			return Std.instance(node, Element);
		return null;
	}

	private function recursiveHide(elem:Element):Void
	{
		for(child in elem.children)
			if(child.nodeName.toLowerCase() == "div")
				recursiveHide(getElement(child));

		hide(elem);
	}

	private function recursiveShow(elem:Element):Void
	{
		for(child in elem.children)
			if(child.nodeName.toLowerCase() == "div")
				recursiveShow(getElement(child));

		elem.classList.remove("hidden");
	}
}
