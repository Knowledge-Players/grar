package grar.view.contextual;

import grar.view.Display.Template;
import grar.view.component.container.SimpleContainer;
import grar.view.component.container.WidgetContainer;
import grar.view.component.container.DefaultButton;
import grar.view.guide.Guide;

import grar.util.ParseUtils;

// FIXME import com.knowledgeplayers.grar.event.TokenEvent;

import grar.model.InventoryToken;

// FIXME import com.knowledgeplayers.grar.localisation.Localiser;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

typedef Template = {

	var data : ElementData;
	var z : Int;
}

/**
* View of an inventory
**/
class InventoryDisplay extends WidgetContainer {

	//public function new(?fast:Fast)
	public function new(idd : WidgetContainerData) {

		super(idd);

		slots = new StringMap();
		displayTemplates = new StringMap();

		switch (idd.type) {

			case InventoryDisplay(gd, fs, dt):

				switch (gd) {

					case Line(d):

						this.guide = new Line(d);

					case Grid(d):

						this.guide = new Grid(d);

					case Curve(d):

						this.guide = new Curve(d);
				}

				this.fullscreen = fs;
				this.displayTemplates = dt;

			default: throw "wrong WidgetContainerData type passed to InventoryDisplay constructor";
		}

// FIXME		GameManager.instance.addEventListener(TokenEvent.ADD, onTokenActivated);

		fullscreenContainer = new SimpleContainer(fullscreen);
	}

	private var slots : StringMap<DefaultButton>;

	private var displayTemplates : StringMap<Template>;

	private var guide : Guide;

	// private var fullscreenXML: Fast;
	private var fullscreen : WidgetContainerData;

	private var fullscreenContainer : SimpleContainer;


	/**
     * Init the inventory with all the tokens it will contained
     **/
	public function init(tokens : GenericStack<String>) : Void {

		for (tokenRef in tokens) {

// FIXME			var token : InventoryToken = GameManager.instance.inventory.get(tokenRef);
			var button : DefaultButton;

			switch (displayTemplates.get(token.ref).data.data) {

				case DefaultButton(d):

// FIXME			var icons = ParseUtils.selectByAttribute("ref", "icon", tmpTemplate.x);
// FIXME			ParseUtils.updateIconsXml(token.icon, icons);
					button = new DefaultButton(d);

				default: throw "unexpected ElementData type";
			}

			slots.set(tokenRef, button);
			guide.add(button);
			content.addChild(button);
			button.buttonAction = onClickToken;
// FIXME			button.setText(Localiser.instance.getItemContent(token.name), "tooltip");
		}

		addEventListener(Event.ADDED_TO_STAGE, function(e:Event) {

				TweenManager.applyTransition(this, transitionIn);

			});
		addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event) {

				TweenManager.applyTransition(this, transitionOut);

			});
	}

	// Handlers
/* FIXME
	private function onTokenActivated(e:TokenEvent):Void
	{
		if(slots.exists(e.token.id)){
			slots.get(e.token.id).toggleState = "active";
		}
	}
*/
	private function onClickToken(?target: DefaultButton):Void
	{
		var token : InventoryToken = null;
		
		for (ref in slots.keys()) {

			if (slots.get(ref) == target) {

				token = GameManager.instance.inventory.get(ref);
			}
		}
		if (token != null) {

			fullscreenContainer.setText(Localiser.instance.getItemContent(token.name), "title");
			fullscreenContainer.setText(Localiser.instance.getItemContent(token.content), "txt");
			content.addChild(fullscreenContainer);
			
			if (fullscreen.transitionIn != null) {

// FIXME				TweenManager.applyTransition(fullscreenContainer, fullscreen.transitionIn);
			}
		}
	}
}