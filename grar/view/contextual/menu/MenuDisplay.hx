package grar.view.contextual.menu;

import grar.model.part.Part;

import grar.view.Display;
import grar.view.component.Image;
import grar.view.component.TileImage.TileImageData;
import grar.view.component.Widget;
import grar.view.component.container.WidgetContainer;
import grar.view.component.container.SimpleContainer;
import grar.view.component.container.DefaultButton;

import grar.util.TweenUtils;
import grar.util.ParseUtils;

import flash.events.MouseEvent;
import flash.display.Shape;
import flash.events.Event;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

using StringTools;

typedef LevelData = {

	var name : String;
	var id : String;
	@:optional var icon : Null<String>;
	@:optional var items : Null<Array<LevelData>>;
	@:optional var partName : String;
}
typedef MenuData = {

	var levels : Array<LevelData>;
}

enum MenuLevel {

	Button(xOffset : Null<Float>, yOffset : Null<Float>, width : Null<Float>, button : Null<WidgetContainerData>);
	ContainerSeparator(d : WidgetContainerData);
	ImageSeparator(thickness : Null<Float>, color : Null<Int>, alpha : Null<Float>, origin : Null<Array<Float>>, destination : Null<Array<Float>>, x : Null<Float>, y : Null<Float>);
}

/**
 * Display of a menu
 */
class MenuDisplay extends Display /* implements ContextualDisplay */ {

	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : aze.display.TilesheetEx, 
							transitions : StringMap<TransitionTemplate>) {

		super(callbacks, applicationTilesheet, transitions);

		buttons = new StringMap();
		buttonGroups.set(btnGroupName, new GenericStack<DefaultButton>());
// GameManager.instance.addEventListener(PartEvent.EXIT_PART, onFinishPart); <= replaced by setPartFinished()
		
		addEventListener(Event.ADDED_TO_STAGE, function(?_){

				onMenuAdded();
			});
		
		addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
	}

	/**
     * Orientation of the menu. Must be Horizontal or Vertical
     **/
	public var orientation (default, set) : String;

	/**
	* Buttons that open and close the menu. Not set internally
	**/
	public var menuButtons : GenericStack<DefaultButton>;

	private var levelDisplays : StringMap<MenuLevel>;

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
	private inline static var btnGroupName : String = "levels";


	///
	// CALLBACKS
	//

	public dynamic function onMenuHide() : Void { }

	public dynamic function onMenuAdded() : Void { }

	public dynamic function onMenuReady() : Void { }

	public dynamic function onMenuRemoved() : Void { }

	public dynamic function onMenuClicked(partId : String) : Void { }

	public dynamic function onMenuButtonStateRequest(partName : String) : { l : Bool, d : Bool } { return null; }


	///
	// API
	//

	public function updateDynamicFields(numUnlocked : Int, totalChildren : Int) : Void {

		for (field in dynamicFields) {

			if (field.content == "unlock_counter") {

				var content = numUnlocked + "/" + totalChildren;
				field.field.setContent(content);
			
			} else {

				field.field.setContent(field.content);
				field.field.setContent(onLocalizedContentRequest(field.content));
			}
			field.field.updateX();
		}
	}

	public function setMenuExit() : Void {

//		var actuator = TweenManager.applyTransition(this, transitionOut);
		var actuator = TweenUtils.applyTransition(this, transitions, transitionOut);

		if (actuator != null) {

			actuator.onComplete(function(){

//					GameManager.instance.hideContextual(instance);
					onMenuHide();
				});
		
		} else {

//			GameManager.instance.hideContextual(instance);
			onMenuHide();
		}
	}

	public function setCurrentPart(p : Part) : Void {

		if (!buttons.exists(p.id)) {

			while (p != null && !buttons.exists(p.id)) {

				p = p.parent;
			}
		
		}
		if (p != null) {

			currentPartButton = buttons.get(p.id);
			
			if (bookmark != null) {

				bookmark.updatePosition(currentPartButton.x, currentPartButton.y);
			}
		}

		if (timelines.exists("in")) {

			timelines.get("in").play();
		}

		onMenuReady();
//  dispatchEvent(new PartEvent(PartEvent.ENTER_PART));
	}

	public function setPartFinished(partId : String) : Void {

		// Set to finish
		if (buttons.exists(partId)) {

			buttons.get(partId).toggle(false);
		}
	}

	public function unlockNextPart(partId : String) : Void {

		if (buttons.exists(partId)) {

			buttons.get(partId).toggle(true);
		}
	}

    //override public function parseContent(content:Xml):Void
    override public function setContent(d : DisplayData) : Void {

        super.setContent(d);

        switch (d.type) {

        	case Menu(b, _, _, _, _):

				if (b != null) {

					this.bookmark = new BookmarkDisplay(callbacks, applicationTilesheet, transitions, b);
				}
			default: throw "wrong DisplayData type given to MenuDisplay.setContent()";
        }
//        exists = true;
    }

	public function init(d : MenuData) : Void {

		switch (data.type) {

        	case Menu( b, o, ld, xb, yb ):

        		this.orientation = o;
        		this.levelDisplays = ld;

				super.createDisplay(data);

				this.xBase = xb;
				this.yBase = yb;

				xOffset += xBase;
				yOffset += yBase;

//				Localiser.instance.layoutPath = LayoutManager.instance.interfaceLocale; // now done in Application.hx

				addChild(layers.get("ui").view);

				for (l in d.levels) {

					createMenuLevel(l);
				}
				if (bookmark != null) {

					bookmark.updatePosition(currentPartButton.x, currentPartButton.y);

					addChild(bookmark);
				}

//				Localiser.instance.popLocale(); // now done in Application.hx

// 				GameManager.instance.menuLoaded = true; // should be useless now...

			default: // nothing
		}
	}


	///
	// GETTER / SETTER
	//

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

	// This is so because super.createDisplay() is called later in MenuDisplay
	override private function createDisplay(d : DisplayData) : Void {  }

	//override private function addElement(elem : Widget, node : Fast) : Void {
	override private function addElement(elem : Widget, ref : String) : Void {

		super.addElement(elem, ref);

		addChild(elem);
	}

	private function createMenuLevel(level : LevelData) : Void {

		if (!levelDisplays.exists(level.name)) {

			throw "Display not specified for tag " + level.name;
		}

		var ml : MenuLevel = levelDisplays.get(level.name);

		switch (ml) {

			case Button(xo, yo, w, bd): // xOffset : Null<Float>, yOffset : Null<Float>, width : Null<Float>, button : Null<WidgetContainerData>

				var button = addButton(bd, onLocalizedContentRequest(level.partName), level.icon);

				buttons.set(level.id, button);
				setButtonState(button, level);
				buttons.set(level.id, button);

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


			case ContainerSeparator(d):

				var separator : Widget = new SimpleContainer(callbacks, applicationTilesheet, transitions, d);

				separator.addEventListener(Event.CHANGE, function(?_){

						onUpdateDynamicFieldsRequest();
					});


			case ImageSeparator(thickness, color, alpha, origin, destination, x, y):

				var separator : Widget = new Image(callbacks, applicationTilesheet, transitions);

				if (thickness != null) {

					var line = new Shape();
					
					line.graphics.lineStyle(thickness, color, alpha);
					line.graphics.moveTo(origin[0], origin[1]);
					line.graphics.lineTo(destination[0], destination[1]);
					line.x = x;
					line.y = y + yOffset;
					
					separator.addChild(line);
				}
				separator.addEventListener(Event.CHANGE, function(?_){

						onUpdateDynamicFieldsRequest();
					});

		}
		if (level.items != null) {

			for (elem in level.items) {
trace("inner item in "+elem.id);
				createMenuLevel(elem);
			}
		}
	}

	private function setButtonState(button : DefaultButton, level : LevelData) : Void {

		var s : { l : Bool, d : Bool } = onMenuButtonStateRequest(level.id);

		if (s.l) {

			button.toggleState = "lock";

		} else {

			button.toggle(!s.d);
		}
/* was:
		for (part in GameManager.instance.game.getAllParts()) {

			if (part.name == level.id) {

				if (!part.canStart()) {

					button.toggleState = "lock";
				
				} else {

					button.toggle(!part.isDone);
				}
				break;
			}
		}
*/
	}

//	private function addButton(fast : Fast, text : String, iconId : String) : DefaultButton {
	private function addButton(d : WidgetContainerData, text : String, iconId : String) : DefaultButton {

		switch(d.type) {

			case DefaultButton(_, _, _, _, _, _, statesElts):

				for (st in statesElts) {

					for (c in st) {
//trace("c.ref = "+c.ref);
						if (c.ref == "icon") {

							if (iconId.indexOf(".") < 0) {

								switch(c.ed) {

									case Image(i):

										i.tile = iconId; trace("set icon Image to "+iconId);
										var tid : TileImageData = cast { id: i };
										c.ed = TileImage(tid);

									case TileImage(ti):

										ti.id.tile = iconId;

									default: throw "unexpected ElementData type given as button icon (not an Image)";
								}

							} else {

								switch(c.ed) {

									case Image(i):

										i.src = iconId;

									case TileImage(ti):

										ti.id.src = iconId;
										c.ed = Image(ti.id);

									default: throw "unexpected ElementData type given as button icon (not an Image)";
								}
							}
						}
					}
				}

			default: throw "wrong WidgetContainerData type passed to MenuDisplay.addButton()";
		}
		var button : DefaultButton = new DefaultButton(callbacks, applicationTilesheet, transitions, d);

		button.setText(text, "partName");
		button.buttonAction = onClick;
		button.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		button.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		button.transitionOut = transitionOut;
		button.name = text;
		buttonGroups.get(btnGroupName).add(button);

		return button;
	}

	// Handlers

	private function onClick(? _target : DefaultButton) : Void {

		var target = _target;
		var canStart = false;

		for (key in buttons.keys()) {

			if (buttons.get(key) == target) {

				onMenuClicked(key);
			}
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

	private function onRemove(e : Event) : Void {

        if ( timelines.get("in") != null) {

            for (elem in timelines.get("in").elements) {

                elem.widget.reset();
            }
        }

        onMenuRemoved();
// 		dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
	}
}
