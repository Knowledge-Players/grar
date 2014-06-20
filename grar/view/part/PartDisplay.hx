package grar.view.part;

import grar.util.ParseUtils;
import grar.util.Point;
import grar.util.TextDownParser;

import grar.view.part.PartDisplay.InputEvent;
import grar.view.component.SoundPlayer;
import grar.view.component.VideoPlayer;
import grar.view.guide.Absolute;
import grar.view.guide.Grid;
import grar.view.guide.Guide;

import grar.model.part.item.Item.VideoData;

import js.html.IFrameElement;
import js.html.Document;
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
class PartDisplay
{

	/**
     * Constructor
     * @param	part : Part to display
     */
	public function new(parent: Application, mobile: Bool) {
		application = parent;
		isMobile = mobile;
		this.onActivateTokenRequest = function(tokenId : String){}
	}

	public var introScreenOn (default, null) : Bool = false;

	public var markupParser (default, default):TextDownParser;


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
	var rootDocument: Document;
	var application: Application;
	var root: Element;


	///
	// CALLBACKS
	//

	public dynamic function onHeaderStateChangeRequest(state: String) : Void { }

	public dynamic function onActivateTokenRequest(token : String) : Void { }

	public dynamic function onIntroEnd():Void { }

	public dynamic function onInputEvent(type: InputEvent, inputId: String, mousePoint: Point): Void {}

	public dynamic function onValidationRequest(inputId: String): Void {}

	///
	// GETTER / SETTER
	//

	/**
	* Initialize a part view
	* @param root: Root HTML element for this view. If null, previous root is kept (like child part keep parent part's root)
	**/
	public function init(?root:Element):Void
	{
		// Init templates
		templates = new Map();
		// Init sounds
		if(playingSounds != null)
			playingSounds.iter(function(elem: AudioElement) elem.pause());
		playingSounds = new Array();

		if(root != null){
			if(root.nodeName.toLowerCase() == "iframe"){
				var iframe: IFrameElement = cast root;
				this.root = iframe.contentDocument.body;
				rootDocument = iframe.contentDocument;
			}
			else{
				this.root = root;
				rootDocument = application.document;
			}
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
			var char: Element = rootDocument.getElementById("speaker");
			char.classList.add(speaker);
			show(char);
			show(char.parentElement);
		}
	}

	public function hideSpeaker(speaker : String) : Void {
		if(speaker != null){
			var char = rootDocument.getElementById("speaker");
			char.classList.remove(speaker);
			hide(char);
		}
	}

	public function setSpeakerLabel(speakerName:String):Void
	{
		for(label in root.getElementsByClassName("speakerLabel")){
			setText(getElement(label).id, speakerName);
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

			var elem:Element = rootDocument.getElementById(imageRef);
            var img:ImageElement = cast elem;
            img.src = src;

			show(img);

		}
	}
    public function hidePattern(ref:String):Void{
        var pat: Element = rootDocument.getElementById(ref);
	    for(child in pat.children)
		    hide(cast child);
        hide(pat);
    }
    public function showPattern(ref:String):Void{
        var pat:Element = rootDocument.getElementById(ref);
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
		var field = rootDocument.getElementById(fieldRef);
		for(elem in markupParser.parse(content))
			field.appendChild(elem);
	}

	public function setVideo(videoRef:String, uri: String, videoData: VideoData, ?onVideoPlay: Void -> Void, ?onVideoEnd: Void -> Void, ?locale: String):Void
	{
		if(videoPlayer == null)
			videoPlayer = new VideoPlayer();
		videoPlayer.init(cast rootDocument.getElementById(videoRef));
		show(videoPlayer.root);
		videoPlayer.setVideo(uri, videoData, onVideoPlay, onVideoEnd, locale);
	}

	public function setSound(soundRef:String, uri:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 1):Void
	{
		if(soundPlayer == null)
			soundPlayer = new SoundPlayer();
		soundPlayer.init(cast rootDocument.getElementById(soundRef));
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
		var debrief: Element = rootDocument.getElementById(debriefRef);
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
			show(rootDocument.getElementById(elem));
		else if(elements != null)
			for(element in elements)
				show(rootDocument.getElementById(element));
	}

	/**
	* Hide elements with their ID
	* @param elements: List of ID to hide
	* @param elem: unique ID to hide. Usefull if you want to hide only one element
	**/
    public function hideElements(?elements:List<String>, ?elem: String):Void
	{
		if(elem != null)
			hide(rootDocument.getElementById(elem));
		else if(elements != null)
			for(element in elements)
				hide(rootDocument.getElementById(element));
	}

	public function hideElementsByClass(className: String):Void
	{
		for(elem in root.getElementsByClassName(className))
			hide(Std.instance(elem, Element));
	}

	public function disableNextButtons():Void
	{
		for(b in root.getElementsByClassName("next"))
			getElement(b).classList.add("disabled");
	}

	public function enableNextButtons():Void
	{
		for(b in root.getElementsByClassName("next"))
			getElement(b).classList.remove("disabled");
	}

	public function setButtonAction(buttonId: String, actionName: String, action : Void -> Void) : Void {

		var b: Element = rootDocument.getElementById(buttonId);
		b.onclick = function(_) !b.classList.contains("disabled") ? action() : null;
		b.classList.add(actionName);
		b.classList.remove("disabled");
	}

	public function createInputs(refs: List<{ref: String, id: String, content: Map<String, String>, icon: Map<String, String>, selected: Bool}>, groupeRef: String, ?autoValidation: Bool = true):Void
	{
		var parent: Element = rootDocument.getElementById(groupeRef);

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
				t = this.rootDocument.getElementById(r.ref);
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
					var img = rootDocument.getElementById(r.id+"_"+key);
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
					#if !cocktail
                    newInput.ontouchend = function(e: MouseEvent){
	                    if(autoValidation)
		                    onValidationRequest(newInput.id);
                        onInputEvent(InputEvent.CLICK, newInput.id, new Point(0,0));
                    }
					#end
				}

			};
			#if !cocktail
			if(isMobile)
				newInput.ontouchstart = onStart;
			else
			#end
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
		var parent: Element = groupRef != null ? rootDocument.getElementById(groupRef) : root;
		for(num in parent.getElementsByClassName("roundNumbering"))
			setNumbering(num, roundNumber, "/"+totalRound);
	}

    public function toggleElement(id:String, ?force: Bool):Void {
        var elem:Element = rootDocument.getElementById(id);
        for (e in elem.getElementsByTagName("input")) {
            var input: InputElement = cast e;
	        input.checked = force != null ? force : !Std.instance(e, InputElement).checked;
        }
    }
    public function uncheckElement(id:String):Void {
        var elem:Element = rootDocument.getElementById(id);
        for (e in elem.getElementsByTagName("input")) {
	        var input: InputElement = cast e;
	        input.checked = false;
        }
    }

	public function removeElement(elemId:String):Void
	{
		var elem: Element = rootDocument.getElementById(elemId);
		elem.parentElement.removeChild(elem);
	}

	public function startDrag(id:String, mousePoint: Point):Void
	{
		// See if e.dataTransfer.setDragImage() can be use instead
		var elem: Element = rootDocument.getElementById(id);
		dragParent = elem.parentElement;
		elem.draggable = true;

		// Extract element for its div
		root.appendChild(elem);
		var bound = elem.getBoundingClientRect();
		elem.style.position = "absolute";
		elem.style.left = (mousePoint.x-bound.width/2)+"px";
		elem.style.top = (mousePoint.y-bound.height/2)+"px";

		var onEnd = function(e: Event) {
			var drop = getDroppedElement(mousePoint, elem.id);
			onInputEvent(InputEvent.MOUSE_UP(drop != null ? drop.id : ""), elem.id, mousePoint);
		};
		#if !cocktail
		if(isMobile)
			root.ontouchend = onEnd;
		else
		#end
			root.onmouseup = onEnd;

		// Detect mouse movements
		var onMove = function(e: UIEvent){
			e.preventDefault();
			mousePoint = getMousePosition(e);
			elem.style.left = (mousePoint.x-bound.width/2)+"px";
			elem.style.top = (mousePoint.y-bound.height/2)+"px";
		}
		#if !cocktail
		if(isMobile)
			root.ontouchmove = onMove;
		else
		#end
			root.onmousemove = onMove;
	}

	public function stopDrag(id:String, dropId: String, isValid: Bool, mousePoint:Point):Void
	{
		var drag: Element = rootDocument.getElementById(id);
		#if cocktail
		drag.style.top = "";
		drag.style.left = "";
		drag.style.position = "";
		#else
		drag.style.removeProperty("top");
		drag.style.removeProperty("left");
		drag.style.removeProperty("position");
		root.ontouchmove = null;
		#end
        root.onmouseup = root.onmousemove = null;

		if(isValid){
			var drop: Element = rootDocument.getElementById(dropId);
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
		rootDocument.getElementById(inputId).classList.add(state);
	}

	public function removeInputState(inputId:String, state: String): Void
	{
		rootDocument.getElementById(inputId).classList.remove(state);
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
			var element: Element = getElement(child);
			if (element != null) {
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
		var x = (rootDocument.documentElement.scrollLeft != null ? rootDocument.documentElement.scrollLeft : rootDocument.body.scrollLeft);
		var y = (rootDocument.documentElement.scrollTop != null ? rootDocument.documentElement.scrollTop : rootDocument.body.scrollTop);

		// TODO get correct scroll
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
		for(input in root.getElementsByClassName("inputs")){
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

	private function hide(elem:Element)
	{
		elem.classList.remove("visible");
		elem.classList.add("hidden");
		if(videoPlayer != null && elem == videoPlayer.root)
		videoPlayer.stop();
		else if(soundPlayer != null && elem == soundPlayer.root)
		soundPlayer.pause();
	}

	private inline function getElement(node:Node):Null<Element>
	{
		if(node.nodeType == Node.ELEMENT_NODE)
			return cast node;
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

	private function show(elem: Element) {
		elem.classList.remove("hidden");
		elem.classList.add("visible");
	}

	private function doSetText(ref:String, content:String):Null<Element>
	{
		var text: Element = rootDocument.getElementById(ref);
		if(text == null)
			return null;
		var html = "";

		// Clone child note list
		var children: Array<Node> = [];
		for(node in text.childNodes) children.push(node);
		// Clean text node in Textfield
		for(node in children){
			if(node.nodeType == Node.TEXT_NODE || node.nodeName.toLowerCase() == "p" || node.nodeName.toLowerCase().startsWith("h")){
				text.removeChild(node);
			}
		}

		if(content != null){
			if(text.nodeName.toLowerCase() == "p" || text.nodeName.toLowerCase() == "a"){
				for(elem in markupParser.parse(content))
					html += elem.outerHTML;
				text.innerHTML += html;
			}
			else
				for(elem in markupParser.parse(content))
					text.appendChild(elem);
		}
		return text;
	}
}
