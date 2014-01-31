package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.factory.GuideFactory;
import com.knowledgeplayers.grar.util.guide.Guide;
import com.knowledgeplayers.grar.display.KpDisplay.Template;
import flash.display.DisplayObject;
import com.knowledgeplayers.grar.structure.Token;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.ds.GenericStack;
import haxe.xml.Fast;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

/**
* View of an inventory
**/
class InventoryDisplay extends WidgetContainer {

	private var slots:Map<String, DefaultButton>;
	private var displayTemplates: Map<String, Template>;
	private var guide:Guide;
	private var fullscreenXML: Fast;
	private var fullscreenContainer: Sprite;
	private var encapsulate: Bool;

	/**
    * Constructor
    * @param    fast : Fast XML
    **/

	public function new(?fast:Fast)
	{
		encapsulate = false;
		super(fast);
		slots = new Map<String, DefaultButton>();
		displayTemplates = new Map<String, Template>();

		var zIndex = 0;
		for(elem in fast.elements){
			if(elem.name.toLowerCase() == "guide"){
				guide = GuideFactory.createGuideFromXml(elem);
			}
			else if(elem.name.toLowerCase() == "fullscreen")
				fullscreenXML = elem;
			else{
				displayTemplates.set(elem.att.ref, {fast: elem, z: zIndex});
			}
			zIndex++;
		}
		GameManager.instance.addEventListener(TokenEvent.ADD, onTokenActivated);
		fullscreenContainer = new Sprite();
		encapsulate = true;
	}

	/**
    * Init the inventory with all the tokens it will contained
    **/

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
			addChild(button);
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
			var cloneXml = Xml.parse(fullscreenXML.x.toString()).firstElement();
			var tmpTemplate = new Fast(cloneXml);
			var icons = ParseUtils.selectByAttribute("ref", "icon", tmpTemplate.x);
			ParseUtils.updateIconsXml(token.icon, icons);
			for(elem in tmpTemplate.elements){
				createElement(elem);
			}
			content.addChild(fullscreenContainer);
			if(fullscreenXML.has.transitionIn)
				TweenManager.applyTransition(fullscreenContainer, fullscreenXML.att.transitionIn);
		}

	}

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		if(action == "close"){
			button.buttonAction = function(?target: DefaultButton){
				if(fullscreenXML.has.transitionOut){
					TweenManager.applyTransition(fullscreenContainer, fullscreenXML.att.transitionOut).onComplete(function(){
					content.removeChild(fullscreenContainer);
					});
				}
				else
					content.removeChild(fullscreenContainer);
			}
		}
	}

	override private function addElement(elem:Widget):Void
	{
		if(!encapsulate)
			super.addElement(elem);
		else{
			fullscreenContainer.addChild(elem);
		}
	}
}
