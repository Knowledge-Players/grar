package grar.view.part;

import Array;
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
import js.html.ImageElement;
import js.html.ClientRect;
import js.html.TouchEvent;
import js.html.UIEvent;
import js.html.Audio;
import js.html.AudioElement;

using StringTools;
using Lambda;
using grar.util.HTMLTools;

enum InputEvent{
    MOUSE_OVER;
	MOUSE_OUT;
	CLICK;
	MOUSE_DOWN;
	MOUSE_UP(targetId: String);
}

typedef InputTemplate = {
	var element: Element;
	@:optional var guide: Guide;
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
	var templates: Map<String, InputTemplate>;
	var templatesPosition: Map<Element, {refElement: Node, parent: Node}>;
	var playingSounds: Array<AudioElement>;
	var rootDocument: Document;
	var application: Application;
	var root: Element;


	///
	// CALLBACKS
	//

	public dynamic function onActivateTokenRequest(token : String) : Void { }

	public dynamic function onIntroEnd():Void { }

	public dynamic function onInputEvent(type: InputEvent, inputId: String, mousePoint: Point): Void {}

	public dynamic function onValidationRequest(inputId: String): Void {}

	public dynamic function onChangePatternRequest(patternId: String): Void {}

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
		templatesPosition = new Map();
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

		application.initSounds(rootDocument.body);
	}


	///
	// API
	//

	public function unloadPart(partRef:String):Void
	{
		hideElements(partRef);
		resetTemplates(partRef);
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
			setText(label.getElement().id, speakerName);
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
            show(child.getElement());
        }

		// Verify parent is also visible
		if(!t.parentElement.classList.contains("hidden"))
			show(t.parentElement);

		return t;
	}

	public function hideText(itemRef:String):Void
	{
		var t:Element = doSetText(itemRef, "");
		if(t == null)
			return null;

		hide(t);
	}

	public function setImage(imageRef:String,src:String):Void
	{
		if(imageRef != null){
			var elem:Element = rootDocument.getElementById(imageRef);
            var img:ImageElement = cast elem;
            img.src = src;

			show(img);
		}
	}

	public function unsetImage(imageRef:String):Void
	{
		if(imageRef != null){
			var elem:Element = rootDocument.getElementById(imageRef);
			var img:ImageElement = cast elem;
			img.src = "";

			hide(img);
		}
	}


    public function hidePattern(ref:String):Void{
        var pat: Element = rootDocument.getElementById(ref);
	    for(child in pat.children)
		    hide(child.getElement());
        hide(pat);
	    resetTemplates(pat);
    }

    public function showPattern(ref:String):Void{
        var pat:Element = rootDocument.getElementById(ref);
        show(pat);

	    // Show the first non-visible child. Usefull for box in strip
	    for(child in pat.children){
	        var elem: Element = child.getElement();
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
		if(videoPlayer == null){
			videoPlayer = new VideoPlayer();
			videoPlayer.onFullscreenRequest = function(?button){
				videoPlayer.root.classList.add("fullscreenOn");
				onFullscreenRequest(button);
			};
			videoPlayer.onExitFullscreenRequest = function(?button){
				videoPlayer.root.classList.remove("fullscreenOn");
				onExitFullscreenRequest(button);
			};
			videoPlayer.onToggleFullscreenRequest = function(?button){
				videoPlayer.root.classList.toggle("fullscreenOn", onToggleFullscreenRequest(button));
			};
		}
		videoPlayer.init(rootDocument.getElementById(videoRef));
		show(videoPlayer.root);
		videoPlayer.setVideo(uri, videoData, onVideoPlay, onVideoEnd, locale);
	}

	public function hideVideoPlayer():Void
	{
		if(videoPlayer != null){
			videoPlayer.stop();
			hide(videoPlayer.root);
		}
	}

	public function setSound(soundRef:String, uri:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 1):Void
	{
		if(soundPlayer == null)
			soundPlayer = new SoundPlayer();
		soundPlayer.init(cast rootDocument.getElementById(soundRef));
		playingSounds.push(soundPlayer.root);
		soundPlayer.setSound(uri, autoStart, loop, defaultVolume);
	}

	public function setVoiceOver(voiceOverUrl:String, volume: Float, ?textRef: String):Void
	{
		var audio = new Audio();
		audio.volume = volume;
		playingSounds.push(audio);
		audio.src = voiceOverUrl;


		if(application.isMobile){
			var button = rootDocument.createAnchorElement();
			button.innerHTML = "&#9654;";
			button.href = 'javascript:void(0);';
			button.classList.add("voiceOver");
			var play = null;
			var pause = function(_){
				audio.pause();
				button.innerHTML = "&#9654;";
				button.onclick = play;
			}
			play = function(_){
				audio.play();
				button.innerHTML = "&#9616;&#9616;";
				button.onclick = pause;
			}
			button.onclick = play;
			if(textRef == null)
				root.appendChild(button);
			else{
				rootDocument.getElementById(textRef).appendChild(button);
			}
		}
		else
			audio.play();
	}

	/**
	* Stop currently playing voice over
	**/
	public function stopVoiceOver():Void
	{
		for(sound in playingSounds)
			sound.pause();
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
				recursiveShow(child.getElement());
			show(debrief);
		}
	}

	public function setDebrief(debriefRef:String, content:String):Void
	{
		setText(debriefRef, content);
		for(elem in root.getElementsByClassName("debriefable"))
			elem.getElement().classList.add("debrief");
		if(root.classList.contains("debriefable"))
			root.classList.add("debrief");
	}

	public function unsetDebrief(debriefRef:String):Void
	{
		var debrief = setText(debriefRef, "");
		if(debrief != null)
			hide(debrief);
		for(elem in root.getElementsByClassName("debriefable"))
			elem.getElement().classList.remove("debrief");
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
		if(elem != null){
			var target = rootDocument.getElementById(elem);
			if(target != null)
				hide(target);
			else
				throw 'Unable to find element $elem. If it can\'t be found, it can\'t be hidden!';
		}
		else if(elements != null)
			for(element in elements){
				var target = rootDocument.getElementById(element);
				if(target != null)
					hide(target);
				else
					throw 'Unable to find element $element. If it can\'t be found, it can\'t be hidden!';
			}
	}

	public function hideElementsByClass(className: String):Void
	{
		for(elem in root.getElementsByClassName(className))
			hide(elem.getElement());
	}

	public function disableNextButtons():Void
	{
		for(b in root.getElementsByClassName("next"))
			b.getElement().classList.add("disabled");
	}

	public function enableNextButtons():Void
	{
		for(b in root.getElementsByClassName("next"))
			b.getElement().classList.remove("disabled");
	}

	public function setButtonAction(buttonId: String, actionName: String, action : Void -> Void) : Void {

		var b: Element = rootDocument.getElementById(buttonId);
		b.onclick = function(_) !b.classList.contains("disabled") ? action() : null;
		b.classList.add(actionName);
		b.classList.remove("disabled");
	}

	// TODO Merge with createInputs
	public function createChoices(refs: List<{ref: String, id: String, icon: Map<String, String>, content: Map<String, String>, goto: String, selected: Bool}>, groupeRef: String):Void
	{
		var parent: Element = rootDocument.getElementById(groupeRef);

		var i = 0;
		var lastInput: Element = null;
		var guide: Guide = null;
		var firstUse: Bool = true;

		for(r in refs){
			// Get template and store it if necessary
			var t: Element;
			if(templates.exists(r.ref)){
				t = templates[r.ref].element;
				if(firstUse){
					if(templates[r.ref].guide != null)
						templates[r.ref].guide.init(t);
					firstUse = false;
				}
			}
			else{
				t = rootDocument.getElementById(r.ref);
				templatesPosition.set(t, {refElement: t.nextSibling, parent: t.parentNode});

				// Guide creation for this group
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
				else
					guide = null;

				if(firstUse && guide != null){
					guide.init(t);
					firstUse = false;
				}

				templates[r.ref] = {element: t, guide: guide};
			}

			// Clone
			var newInput: Element = cast t.cloneNode(true);

			// Set attributes
			newInput.id = r.id;
			newInput.classList.add("inputs");
			recursiveSetId(newInput, r.id);

			// Add it to the guide
			if(templates[r.ref].guide != null){
				templates[r.ref].guide.add(newInput);
				if(i == 0)
					parent.removeChild(t);
			}
			// Replace template by new node if it's the first
			else if(i == 0)
				parent.replaceChild(newInput, t);
			// Insert after the last created input
			else
				parent.insertBefore(newInput, lastInput.nextSibling);

			lastInput = newInput;


			// Adding numbering system if any
			for(num in newInput.getElementsByClassName("numbering")){
				setNumbering(num, i);
			}

			// Setting input text
			for(key in r.content.keys()){
				if(key != "_")
					doSetText(r.id+"_"+key, r.content[key]);
				else
					doSetText(r.id, r.content[key]);
			}
			// Setting icons
			for(key in r.icon.keys()){
				var url = 'url('+r.icon[key]+')';
				if(key != "_"){
					var img = rootDocument.getElementById(r.id+"_"+key);
					if(img.nodeName.toLowerCase() == "img"){
						var imgElement: ImageElement = cast img;
						imgElement.src = r.icon[key];
					}
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

			// Binding
			newInput.onclick = function(_){
				hideElements(groupeRef);
				onChangePatternRequest(r.goto);
			}

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

	public function createInputs(refs: List<{ref: String, id: String, content: Map<String, String>, icon: Map<String, String>, selected: Bool}>, groupeRef: String, ?autoValidation: Bool = true, ?position: Array<Point>):Void
	{
		var parent: Element = rootDocument.getElementById(groupeRef);

		var i = 0;
		var lastInput: Element = null;
		var guide: Guide = null;
		var firstUse: Bool = true;

		for(r in refs){
			// Get template and store it if necessary
			var t: Element;
			if(templates.exists(r.ref)){
				t = templates[r.ref].element;
				if(firstUse){
					if(templates[r.ref].guide != null)
						templates[r.ref].guide.init(t);
					firstUse = false;
				}
			}
			else{
				t = rootDocument.getElementById(r.ref);
				templatesPosition.set(t, {refElement: t.nextSibling, parent: t.parentNode});

				// Guide creation for this template
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
				else if(position != null){
					guide = new Absolute(parent, position);
				}
				else
					guide = null;

				if(firstUse && guide != null){
					guide.init(t);
					firstUse = false;
				}

				templates[r.ref] = {element: t, guide: guide};
			}

			// Clone
			var newInput: Element = cast t.cloneNode(true);

			// Set attributes
			newInput.id = r.id;
			newInput.classList.add("inputs");
			recursiveSetId(newInput, r.id);

			// Add it to the guide
			if(templates[r.ref].guide != null){
				templates[r.ref].guide.add(newInput);
				if(i == 0)
					parent.removeChild(t);
			}
			// Replace template by new node if it's the first
			else if(i == 0)
				parent.replaceChild(newInput, t);
			// Insert after the last created input
			else
				parent.insertBefore(newInput, lastInput.nextSibling);

			lastInput = newInput;


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
					if(img.nodeName.toLowerCase() == "img"){
						var imgElement: ImageElement = cast img;
						imgElement.src = r.icon[key];
					}
					else
						img.style.backgroundImage = url;
				}
				else{
					newInput.style.backgroundImage = url;
				}
			}
			// Update state
			if(r.selected){
				newInput.classList.add("selected");
				for(node in newInput.getElementsByTagName("input")){
					var input: InputElement = cast node;
					input.checked = true;
				}
			}

			// Event Binding
			var onStart = function(e: MouseEvent){
				if(isMobile || e.button == 0){
					e.preventDefault();
					var target: Node = cast e.target;
					if(target.nodeName.toLowerCase() != "a")
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
	        input.checked = force != null ? force : !input.checked;
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
			b.getElement().classList.toggle("disabled", force);
	}

	public function removeFullscreenState():Void
	{
		for(b in root.getElementsByClassName("fullscreenOn"))
			b.getElement().classList.remove("fullscreenOn");
	}

	///
	// INTERNALS
	//

	private function setNumbering(node:Node, order: Int, ? suffix: String):Void
	{
		var elem: Element = node.getElement();
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
			var element: Element = child.getElement();
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
	}

	private function recursiveHide(elem:Element):Void
	{
		for(child in elem.children)
			if(child.nodeName.toLowerCase() == "div")
				recursiveHide(child.getElement());

		hide(elem);
	}

	private function recursiveShow(elem:Element):Void
	{
		for(child in elem.children)
			if(child.nodeName.toLowerCase() == "div")
				recursiveShow(child.getElement());

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
			if(node.nodeType == Node.TEXT_NODE || node.nodeName.toLowerCase() == "p" || node.nodeName.toLowerCase() == "a" || node.nodeName.toLowerCase().startsWith("h")){
				text.removeChild(node);
			}
		}

		if(content != null){
			if(text.nodeName.toLowerCase() == "p" || text.nodeName.toLowerCase() == "a"){
				for(elem in markupParser.parse(content))
					html += elem.innerHTML;
				text.innerHTML += html;
			}
			else
				for(elem in markupParser.parse(content))
					text.appendChild(elem);
		}
		return text;
	}

	private function onFullscreenRequest(?button:Element):Void
	{
		application.requestFullscreen();
		if(button != null)
			button.classList.add("fullscreenOn");
	}

	private function onExitFullscreenRequest(?button:Element):Void
	{
		application.exitFullscreen();
		if(button != null)
			button.classList.remove("fullscreenOn");
	}

	private function onToggleFullscreenRequest(?button:Element):Bool
	{
		if (!application.isFullscreen){
			onFullscreenRequest(button);
			return true;
		}
		else{
			onExitFullscreenRequest(button);
			return false;
		}
	}

	private function resetTemplates(?rootRef: String, ?rootElement: Element):Void
	{
		var parent;
		if(rootElement != null)
			parent = rootElement;
		else
			parent = rootDocument.getElementById(rootRef);

		for(t in templates){
			var pos = templatesPosition[t.element];
			hide(t.element);
			if(pos.refElement != null)
				pos.parent.insertBefore(t.element, pos.refElement);
			else
				pos.parent.appendChild(t.element);
		}

		// Remove Guide if any
		var rows = new Array<Node>();
		for(node in parent.getElementsByClassName("row"))
			rows.push(node);
		for(row in rows)
			row.parentNode.removeChild(row);
	}
}
