package grar.view.contextual.menu;

import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.display.component.container.SimpleContainer;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.contextual.ContextualDisplay;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.GameManager;
import grar.view.KpDisplay;
import com.knowledgeplayers.grar.util.ParseUtils;

import flash.events.MouseEvent;
import flash.display.Shape;
import flash.events.Event;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;
import haxe.xml.Fast;

using StringTools;

/**
 * Display of a menu
 */
class MenuDisplay extends KpDisplay implements ContextualDisplay {

	public function new(kd : KpDisplayData, o : String, b : Null<BookmarkDisplay>, ld : StringMap<Fast>, xb : Float, yb : Float, xo : Float, yo : Float) {
		
		super(kd);

		this.orientation = o;
		this.bookmark = b;
		this.levelDisplays = ld;
		this.xBase = xb;
		this.yBase = yb;
		this.xOffset = xo;
		this.yOffset = yo;

		// FIXME all below
		buttons = new StringMap();
		buttonGroups.set(btnGroupName, new GenericStack());
		GameManager.instance.addEventListener(PartEvent.EXIT_PART, onFinishPart);
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

	private var levelDisplays : StringMap<Fast>;
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

	/**
    * @:setter for orientation
    * @param    orientation : The orientation set
    * @return the orientation
    **/
	public function set_orientation(orientation : String) : String {

		this.orientation = orientation.toLowerCase();
		return this.orientation;
	}

	public function init():Void
	{
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
			setButtonState(button, level);
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

	override private function addElement(elem:Widget, node:Fast):Void
	{
		super.addElement(elem, node);
		addChild(elem);
	}

}
