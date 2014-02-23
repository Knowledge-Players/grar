package grar.view.contextual.menu;

import com.knowledgeplayers.grar.event.PartEvent; // FIXME

import grar.model.part.Part;

import com.knowledgeplayers.grar.localisation.Localiser; // FIXME

import grar.view.Display;
import grar.view.component.Image;
import grar.view.component.Widget;
import grar.view.component.container.WidgetContainer;
import grar.view.component.container.SimpleContainer;
import grar.view.component.container.DefaultButton;
import grar.view.contextual.ContextualDisplay;

// FIXME import com.knowledgeplayers.grar.display.GameManager;

import grar.util.ParseUtils;

import flash.events.MouseEvent;
import flash.display.Shape;
import flash.events.Event;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

using StringTools;

enum MenuLevel {

	Button(? xOffset : Null<Float>, ? yOffset : Null<Float>, ? width : Null<Float>, ? button : Null<WidgetContainerData>);
	ContainerSeparator(? d : WidgetContainerData);
	ImageSeparator(? thickness : Null<Float>, ? color : Null<Int>, ? alpha : Null<Float>, ? origin : Null<Array<Float>>, ? destination : Null<Array<Float>>, ? x : Null<Float>, ? y : Null<Float>);
}

/**
 * Display of a menu
 */
class MenuDisplay extends Display /* implements ContextualDisplay */ {

	private function new() {

		super();

		buttons = new StringMap();
		buttonGroups.set(btnGroupName, new GenericStack());
// FIXME		GameManager.instance.addEventListener(PartEvent.EXIT_PART, onFinishPart);
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
	}

	/**
     * Orientation of the menu. Must be Horizontal or Vertical
     **/
	public var orientation (default, set) : String;

	/**
	 * Tell wether or not there is a menu in the module
	 **/
	//public var exists (default,null) : Bool = false; // testing null in application should be enought ?

	/**
	* Buttons that open and close the menu. Not set internally
	**/
	public var menuButtons : GenericStack<DefaultButton>;

	private var levelDisplays : StringMap<Fast>; // FIXME
	private var xOffset : Float = 0;
	private var yOffset : Float = 0;

	// grid origin for elements in the menu (buttons)
	private var yBase : Float = 0;
	private var xBase : Float = 0;

	private var buttons : StringMap<DefaultButton>;
	private var separators : StringMap<Widget>;
	private var bookmark : BookmarkDisplay;
	private var currentPartButton : DefaultButton;

// Constant that stock the name of the button group
	private inline static var btnGroupName: String = "levels";


	///
	// API
	//

    //override public function parseContent(content:Xml):Void
    override public function setContent(d : DisplayData) : Void {

        super.setContent(d);

        switch (d.type) {

        	case Menu(b):

				if (b != null) {

					this.bookmark = new BookmarkDisplay(b);
				}
			default: throw "wrong DisplayData type given to MenuDisplay.setContent()";
        }
        exists = true;
    }

	public function init() : Void {

		switch (data.type) {

        	case Menu( b, o, ld, xb, yb ):

        		this.orientation = o;
        		this.levelDisplays = ld;

				super.createDisplay();

				this.xBase = xb;
				this.yBase = yb;

// FIXME				var menuXml = GameManager.instance.game.menu;

				xOffset += xBase;
				yOffset += yBase;

// FIXME				Localiser.instance.layoutPath = LayoutManager.instance.interfaceLocale;

				addChild(layers.get("ui").view);

// FIXME				for (elem in menuXml.firstElement().elements()) {

// FIXME					createMenuLevel(elem);
// FIXME				}

				if (bookmark != null) {

					bookmark.updatePosition(currentPartButton.x, currentPartButton.y);
					addChild(bookmark);
				}

// FIXME				Localiser.instance.popLocale();

// FIXME				GameManager.instance.menuLoaded = true;

			default: // nothing
		}
	}

	/**
    * @:setter for orientation
    * @param    orientation : The orientation set
    * @return the orientation
    **/
	public function set_orientation(orientation : String) : String {

		this.orientation = orientation.toLowerCase();
		return this.orientation;
	}

	
	///
	// INTERNALS
	//

	private function createMenuLevel(level : Xml) : Void { // FIXME FIXME FIXME FIXME FIXME 

		if (!levelDisplays.exists(level.nodeName)) {

			throw "Display not specified for tag " + level.nodeName;
		}

		var ml : MenuLevel = levelDisplays.get(level.nodeName);

		switch (ml) {

			case Button(xo, yo, w, bd):

// FIXME				var partName = GameManager.instance.getItemName(level.get("id"));
				if (partName == null) {

					throw "[MenuDisplay] Can't find a name for '"+level.get("id")+"'.";
				}

				var button = addButton(bd, partName, level.get("icon"));

				buttons.set(level.get("id"), button);
				setButtonState(button, level); // FIXME
				buttons.set(level.get("id"), button);

	            button.x += xOffset;
	            button.y += yOffset;

				if (orientation == "vertical") {

					yOffset += button.height + yo;
				
				} else if (w != null) {

					xOffset += xOffset + w;
				
				} else if (orientation == "horizontal") {

				    xOffset += button.width + xo;
				}
	            addChild(button);

				if (currentPartButton == null) {

					currentPartButton = button;
				}

			case ContainerSeparator(? d : WidgetContainerData):

				var separator : Widget = new SimpleContainer(d);

				separator.addEventListener(Event.CHANGE, updateDynamicFields);

			case ImageSeparator(thickness, color, alpha, origin, destination, x, y):

				var separator : Widget = new Image();

				if (thickness != null) {

					var line = new Shape();
					
					line.graphics.lineStyle(thickness, color, alpha);
					line.graphics.moveTo(origin[0], origin[1]);
					line.graphics.lineTo(destination[0], destination[1]);
					line.x = x;
					line.y = y + yOffset;
					
					separator.addChild(line);
				}
				separator.addEventListener(Event.CHANGE, updateDynamicFields);

			default: 
		}
		for(elem in level.elements())	// FIXME FIXME FIXME FIXME
			createMenuLevel(elem);	// FIXME FIXME FIXME FIXME
	}
// FIXME FIXME FIXME FIXME FIXME FIXME FIXME
	private function setButtonState(button:DefaultButton, level: Xml):Void
	{
		for(part in GameManager.instance.game.getAllParts()){
			if(part.name == level.get("id")){
				if(!part.canStart())
					button.toggleState = "lock";
				else
					button.toggle(!part.isDone);
				break;
			}
		}
	}

//	private function addButton(fast : Fast, text : String, iconId : String) : DefaultButton {
	private function addButton(d : WidgetContainerData, text : String, iconId : String) : DefaultButton {

// FIXME parse "icons" in WidgetContainerData		var icons = ParseUtils.selectByAttribute("ref", "icon", fast.x);
// FIXME parse "icons" in WidgetContainerData		ParseUtils.updateIconsXml(iconId, icons);
		var button : DefaultButton = new DefaultButton(d);

		button.setText(text, "partName");
		button.buttonAction = onClick;
		button.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		button.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		button.transitionOut = transitionOut;
		button.name = text;
		buttonGroups.get(btnGroupName).add(button);

		return button;
	}

	override private function createDisplay() : Void { } // ?

	// Handlers

	private function onClick(?_target:DefaultButton):Void
	{
		var target = _target;
		var canStart = false;
		for(key in buttons.keys()){
			if(buttons.get(key) == target)
				canStart = GameManager.instance.displayPartById(key, true);
		}

		if(canStart){
			var actuator = TweenManager.applyTransition(this, transitionOut);
			if(actuator != null)
				actuator.onComplete(function(){
					GameManager.instance.hideContextual(instance);
				});
			else
				GameManager.instance.hideContextual(instance);
		}
	}

	private function onOver(e: Event):Void
	{
		for(button in buttonGroups.get(btnGroupName)){
			if(button != e.target){
				button.renderState("groupOver");
			}
		}
	}

	private function onOut(e: Event):Void
	{
		for(button in buttonGroups.get(btnGroupName)){
			for(i in 0...button.content.numChildren){
				button.renderState("out");
			}
		}
	}

	private function onFinishPart(e:PartEvent):Void
	{
		// Set to finish
		if(buttons.exists(e.partId))
			buttons.get(e.partId).toggle(false);
		// Unlock next parts
		for(part in GameManager.instance.game.getAllParts()){
			if(buttons.exists(part.id) && part.id != e.partId && !part.isDone){
				if(!part.canStart())
					buttons.get(part.id).toggleState = "lock";
				else
					buttons.get(part.id).toggle(true);
			}
		}
	}

	private inline function getUnlockCounterInfos(partId:String):String
	{
		var output: String = "";
		var parent: Part = GameManager.instance.game.getPart(partId);
		var numUnlocked = 0;
		if(parent != null){
			var children = parent.getAllParts();
			if(children.length <= 1){
				var totalChildren = 0;
				var allParts = GameManager.instance.game.getAllParts();
				for(part in allParts){
					if(part.id.startsWith(partId) && part.id != partId){
						totalChildren++;
						if(part.canStart())
							numUnlocked++;
					}
				}
				output = numUnlocked+"/"+totalChildren;
			}
			else{
				for(child in children){
					if(child.canStart())
						numUnlocked++;
				}
				output = numUnlocked+"/"+children.length;
			}
		}

		return output;
	}

	private function updateDynamicFields(e: Event):Void
	{
		for(field in dynamicFields){
			if(field.content == "unlock_counter"){
				var content = getUnlockCounterInfos(field.field.ref);
				field.field.setContent(content);
			}
			else{
				field.field.setContent(Localiser.instance.getItemContent(field.content));
			}
			field.field.updateX();
		}
	}

	private function onAdded(e:Event):Void
	{
		// Update bookmark
		var i = 0;
		while(i < GameManager.instance.game.getAllParts().length && GameManager.instance.game.getAllParts()[i].isDone){
			i++;
		}
		var part;
		if(!buttons.exists(GameManager.instance.game.getAllParts()[i].id)){
			part = GameManager.instance.game.getAllParts()[i];
			while(part != null && !buttons.exists(part.id))
				part = part.parent;
		}
		else
			part = GameManager.instance.game.getAllParts()[i];
		if(part != null){
			currentPartButton = buttons.get(part.id);
			if(bookmark != null)
				bookmark.updatePosition(currentPartButton.x, currentPartButton.y);
		}

		if (timelines.exists("in")){
			timelines.get("in").play();
		}
		dispatchEvent(new PartEvent(PartEvent.ENTER_PART));
	}

	private function onRemove(e:Event):Void
	{
        if( timelines.get("in") != null){
            for(elem in timelines.get("in").elements)
                elem.widget.reset();
        }
		dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
	}

}
