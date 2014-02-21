package grar.view.contextual;

import com.knowledgeplayers.grar.display.KpDisplay.Template;
import com.knowledgeplayers.grar.display.component.container.SimpleContainer;
import grar.view.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.factory.GuideFactory;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.util.guide.Guide;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.structure.Token;
import com.knowledgeplayers.grar.localisation.Localiser;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

/**
* View of an inventory
**/
class InventoryDisplay extends WidgetContainer {

	//public function new(?fast:Fast)
	public function new(idd : WidgetContainerData) {

		super(idd);

		slots = new StringMap();
		displayTemplates = new StringMap();

		var zIndex = 0;
/* FIXME
		for (elem in fast.elements) {

			if (elem.name.toLowerCase() == "guide") {

				guide = GuideFactory.createGuideFromXml(elem);
			
			} else if(elem.name.toLowerCase() == "fullscreen") {

				fullscreenXML = elem;
			
			} else {

				displayTemplates.set(elem.att.ref, {fast: elem, z: zIndex});
			}
			zIndex++;
		}
*/
		GameManager.instance.addEventListener(TokenEvent.ADD, onTokenActivated);
		fullscreenContainer = new SimpleContainer(fullscreenXML);
	}

	private var slots:Map<String, DefaultButton>;
	private var displayTemplates: Map<String, Template>;
	private var guide:Guide;
// FIXME	private var fullscreenXML: Fast;
	private var fullscreenContainer: SimpleContainer;


	/**
    * Init the inventory with all the tokens it will contained
    **/
/* FIXME  FIXME  FIXME  FIXME  FIXME 
	public function init(tokens:GenericStack<String>):Void
	{
		for(tokenRef in tokens){
			var token: Token = GameManager.instance.inventory.get(tokenRef);

			var cloneXml = Xml.parse(displayTemplates.get(token.ref).fast.x.toString()).firstElement();
			var tmpTemplate = new Fast(cloneXml);
			var icons = ParseUtils.selectByAttribute("ref", "icon", tmpTemplate.x);
			ParseUtils.updateIconsXml(token.icon, icons);

			var button = new DefaultButton(tmpTemplate);
			slots.set(tokenRef, button);
			guide.add(button);
			content.addChild(button);
			button.buttonAction = onClickToken;
			button.setText(Localiser.instance.getItemContent(token.name), "tooltip");
		}

		addEventListener(Event.ADDED_TO_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transitionIn);
		});
		addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transitionOut);
		});
	}
*/
	// Handlers

	private function onTokenActivated(e:TokenEvent):Void
	{
		if(slots.exists(e.token.id)){
			slots.get(e.token.id).toggleState = "active";
		}
	}

	private function onClickToken(?target: DefaultButton):Void
	{
		var token: Token = null;
		for(ref in slots.keys()){
			if(slots.get(ref) == target)
				token = GameManager.instance.inventory.get(ref);
		}
		if(token != null){
			fullscreenContainer.setText(Localiser.instance.getItemContent(token.name), "title");
			fullscreenContainer.setText(Localiser.instance.getItemContent(token.content), "txt");
			content.addChild(fullscreenContainer);
// FIXME			if(fullscreenXML.has.transitionIn)
// FIXME				TweenManager.applyTransition(fullscreenContainer, fullscreenXML.att.transitionIn);
		}

	}
}
