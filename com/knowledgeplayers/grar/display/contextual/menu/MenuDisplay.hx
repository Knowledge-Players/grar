package com.knowledgeplayers.grar.display.contextual.menu;

import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.display.component.container.SimpleContainer;
import com.knowledgeplayers.grar.util.ParseUtils;
import flash.events.MouseEvent;
import haxe.ds.GenericStack;
import com.knowledgeplayers.grar.display.component.Widget;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.contextual.ContextualDisplay;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.event.PartEvent;
import haxe.xml.Fast;
import flash.display.Shape;
import flash.events.Event;

using StringTools;

/**
 * Display of a menu
 */

class MenuDisplay extends KpDisplay implements ContextualDisplay {

	public static var instance (get_instance, null) : MenuDisplay;
	/**
    * Orientation of the menu. Must be Horizontal or Vertical
    **/
	public var orientation (default, set_orientation):String;

	/**
	* Tell wether or not there is a menu in the module
	**/
	public var exists(default,null):Bool=false;

	/**
	* Buttons that open and close the menu. Not set internally
	**/
	public var menuButtons:GenericStack<DefaultButton>;

	private var levelDisplays:Map<String, Fast>;
	private var xOffset:Float = 0;
	private var yOffset:Float = 0;

	// grid origin for elements in the menu (buttons)
	private var yBase:Float = 0;
	private var xBase:Float = 0;

	private var buttons:Map<String, DefaultButton>;
	private var separators: Map<String, Widget>;
	private var bookmark: BookmarkDisplay;
	private var currentPartButton: DefaultButton;

// Constant that stock the name of the button group
	private inline static var btnGroupName: String = "levels";

	public static function get_instance():MenuDisplay
	{
		if(instance == null)
			instance = new MenuDisplay();
		return instance;
	}

	private function new()
	{
		super();
		buttons = new Map<String, DefaultButton>();
		buttonGroups.set(btnGroupName, new GenericStack<DefaultButton>());
		GameManager.instance.addEventListener(PartEvent.EXIT_PART, onFinishPart);
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
	}

	/**
    * @:setter for orientation
    * @param    orientation : The orientation set
    * @return the orientation
    **/

	public function set_orientation(orientation:String):String
	{
		this.orientation = orientation.toLowerCase();
		return this.orientation;
	}

    override public function parseContent(content:Xml):Void
    {
		// BAAAAAAAAAAHHH: remove singleton
        if(!Std.is(this, MenuSphericalDisplay) && content.firstElement().get("type") == "spheric"){
	        instance = MenuSphericalDisplay.instance;
	        instance.parseContent(content);
        }
	    else
            super.parseContent(content);

		if(displayFast == null)
			displayFast = new Fast(content.firstElement());
	    if(displayFast.hasNode.Bookmark)
			bookmark = new BookmarkDisplay(displayFast.node.Bookmark);

        exists = true;
    }

	public function init():Void
	{
		orientation = displayFast.att.orientation;

		levelDisplays = new Map<String, Fast>();
		var regEx = ~/h[0-9]+|hr|item/i;
		for(child in displayFast.elements){
			if(regEx.match(child.name))
				levelDisplays.set(child.name, child);
		}

		super.createDisplay();

		if(displayFast.has.xBase)
			xBase = Std.parseFloat(displayFast.att.xBase);
		if(displayFast.has.yBase)
			yBase = Std.parseFloat(displayFast.att.yBase);

		var menuXml = GameManager.instance.game.menu;

		xOffset += xBase;
		yOffset += yBase;

		Localiser.instance.pushLocale();
		Localiser.instance.layoutPath = LayoutManager.instance.interfaceLocale;

		addChild(layers.get("ui").view);

		for(elem in menuXml.firstElement().elements()){
			createMenuLevel(elem);
		}

		if(bookmark != null){
			bookmark.updatePosition(currentPartButton.x, currentPartButton.y);
			addChild(bookmark);
		}

		Localiser.instance.popLocale();

		GameManager.instance.menuLoaded = true;
	}

	// Private

	override private function createDisplay():Void
	{
	}

	private function createMenuLevel(level:Xml):Void
	{
		if(!levelDisplays.exists(level.nodeName))
			throw "Display not specified for tag " + level.nodeName;

		var fast:Fast = levelDisplays.get(level.nodeName);

		if(level.nodeName == "hr"){
			addSeparator(fast);
		}
		else{
			var partName = GameManager.instance.getItemName(level.get("id"));
			if(partName == null)
				throw "[MenuDisplay] Can't find a name for '"+level.get("id")+"'.";

			var button = addButton(fast.node.Button, partName, level.get("icon"));
			buttons.set(level.get("id"), button);
			for(part in GameManager.instance.game.getAllParts()){
				if(part.name == level.get("id")){
					if(!part.canStart())
						button.toggleState = "lock";
					else
						button.toggle(!part.isDone);
					break;
				}
			}
			buttons.set(level.get("id"), button);

            button.x += xOffset;
            button.y += yOffset;
			if(orientation == "vertical"){
				yOffset += button.height+Std.parseFloat(fast.att.yOffset);
			}
			else if(fast.has.width){
				xOffset += xOffset+Std.parseFloat(fast.att.width);
			}
			else if(orientation == "horizontal")
			    xOffset += button.width+Std.parseFloat(fast.att.xOffset);

            addChild(button);
			if(currentPartButton == null){
				currentPartButton = button;
			}
		}
		for(elem in level.elements())
			createMenuLevel(elem);
	}

	private function addSeparator(fast:Fast):Widget
	{
		var hasChildren = fast.elements.hasNext();
		var separator: Widget;
		if(hasChildren)
			separator = new SimpleContainer(fast);
		else{
			separator = new Image();
			if(fast.has.thickness){
				var line = new Shape();
				line.graphics.lineStyle(Std.parseFloat(fast.att.thickness), Std.parseInt(fast.att.color), Std.parseFloat(fast.att.alpha));
				var originCoord:Array<String> = fast.att.origin.split(';');
				var origin = {x: Std.parseFloat(originCoord[0]), y: Std.parseFloat(originCoord[1])};
				line.graphics.moveTo(origin.x, origin.y);
				var destCoord = fast.att.destination.split(";");
				var dest = {x: Std.parseFloat(destCoord[0]), y: Std.parseFloat(destCoord[1])};
				line.graphics.lineTo(dest.x, dest.y);

				line.x = Std.parseFloat(fast.att.x);
				line.y = Std.parseFloat(fast.att.y) + yOffset;
				separator.addChild(line);
			}
		}
		separator.addEventListener(Event.CHANGE, updateDynamicFields);
		return separator;
	}

	private function addButton(fast:Fast, text:String, iconId: String):DefaultButton
	{
		var icons = ParseUtils.selectByAttribute("ref", "icon", fast.x);
		ParseUtils.updateIconsXml(iconId, icons);
		var button:DefaultButton = new DefaultButton(fast);

		button.setText(text, "partName");
		button.buttonAction = onClick;
		button.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		button.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		button.transitionOut = transitionOut;
		button.name = text;
		buttonGroups.get(btnGroupName).add(button);

		return button;
	}

	private inline function findIcon(xml:Xml):GenericStack<Xml>
	{
		var results = new GenericStack<Xml>();
		findIconRec(xml, results);
		return results;
	}

	private inline function findIconRec(xml: Xml, res: GenericStack<Xml>):Void
	{
		if(xml.get("ref") == "icon")
			res.add(xml);
		else{
			for(elem in xml.elements()){
				findIconRec(elem, res);
			}
		}
	}

	// Handlers

	private function onClick(?_target:DefaultButton):Void
	{
		var target = _target;
		for(key in buttons.keys()){
			if(buttons.get(key) == target)
				GameManager.instance.displayPartById(key, true);
		}

		//TweenManager.applyTransition(this, transitionOut);
		GameManager.instance.hideContextual(instance);
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
		for(part in GameManager.instance.game.getAllParts()){
			if(buttons.exists(part.id)){
				if(!part.canStart())
					buttons.get(part.id).toggleState = "lock";
				else
					buttons.get(part.id).toggle(!part.isDone);
			}
		}
	}

	private inline function getUnlockCounterInfos(partId:String):String
	{
		var output: String;
		var parent: Part = GameManager.instance.game.getPart(partId);
		var numUnlocked = 0;
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

	override private function addElement(elem:Widget, node:Fast):Void
	{
		super.addElement(elem, node);
		addChild(elem);
	}

}
