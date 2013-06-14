package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.event.TokenEvent;
import nme.events.Event;
import com.knowledgeplayers.grar.factory.UiFactory;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.structure.contextual.Notebook;
import com.knowledgeplayers.grar.display.KpDisplay;
import nme.display.Sprite;

class NotebookDisplay extends KpDisplay implements ContextualDisplay
{
	/**
	* Instance of the display
	**/
	public static var instance (get_instance, null): NotebookDisplay;

	/**
	* Model
	**/
	public var model (default, set_model): Notebook;

	private var noteTemplate: Fast;
	private var noteMap: Map<DefaultButton, String>;

		/**
	* @return the instance
	**/
	public static function get_instance():NotebookDisplay
	{
		if(instance == null)
			instance = new NotebookDisplay();
		return instance;
	}

	override public function parseContent(content:Xml):Void
	{
		super.parseContent(content);
		if(displayFast.has.layout)
			layout = displayFast.att.layout;
		noteTemplate = displayFast.node.Note;
		noteMap = new Map<DefaultButton, String>();
	}

	// Privates

	private function set_model(model:Notebook):Notebook
	{
		if(model != this.model){
			Localiser.instance.layoutPath = model.file;
			// Display bkg
			if(model.background != null){
				var bkg = displaysFast.get(model.background);
				var width:Float = bkg.has.width ? Std.parseFloat(bkg.att.width) : 0;
				var height:Float = bkg.has.height ? Std.parseFloat(bkg.att.height) : 0;
				var alpha:Float = bkg.has.alpha ? Std.parseFloat(bkg.att.alpha) : 1;
				var x:Float = bkg.has.x ? Std.parseFloat(bkg.att.x) : 0;
				var y:Float = bkg.has.y ? Std.parseFloat(bkg.att.y) : 0;
				DisplayUtils.setBackground(bkg.att.src, this, width, height, alpha, x, y);
			}

			for(item in model.items){
				if(displays.exists(item))
					addChild(displays.get(item).obj);
				else
					throw '[NotebookDisplay] There is no item with ref "$item."';
			}

			// Display title
			var title: ScrollPanel = cast(displays.get(model.title.ref).obj, ScrollPanel);
			title.setContent(Localiser.instance.getItemContent(model.title.content));
			addChild(title);

			// Display button
			var button: DefaultButton = cast(displays.get(model.closeButton.ref).obj, DefaultButton);
			button.setText(Localiser.instance.getItemContent(model.closeButton.content));
			button.addEventListener("close", function(e){
				GameManager.instance.hideContextual(this);
			});
			addChild(button);

			// Display notes
			var offsetY: Float = 0;
			for(note in model.notes){
				var icon: Xml = findIcon(noteTemplate.x);
				if(icon != null)
					icon.set("src", note.icon);
				var button: DefaultButton = UiFactory.createButtonFromXml(noteTemplate);
				button.y += offsetY;
				offsetY += button.height + Std.parseFloat(noteTemplate.att.offsetY);
				button.setText(Localiser.instance.getItemContent(note.title), "title");
				button.setText(Localiser.instance.getItemContent(note.subtitle), "subtitle");
				// Fill hit box
				DisplayUtils.initSprite(button, button.width, button.height, 0, 0.001);
				addChild(button);
				button.addEventListener("show", onSelectNote);
				button.visible = note.unlocked;
				noteMap.set(button, note.content);
			}

			return this.model = model;
		}
		return model;
	}

	private function new()
	{
		super();
		GameManager.instance.addEventListener(TokenEvent.ADD, onUnlocked);
	}

	private function findIcon(xml:Xml):Xml
	{
		if(xml.nodeName == "Item" && xml.get("ref").toLowerCase() == "icon")
			return xml;
		else{
			var iconXml: Xml = null;
			for(elem in xml.elements()){
				var result = findIcon(elem);
				if(result != null)
					iconXml = result;
			}
			return iconXml;
		}
	}

	private function onSelectNote(e: Event):Void
	{
		var panel = cast(displays.get(model.contentRef).obj, ScrollPanel);
		panel.setContent(Localiser.instance.getItemContent(noteMap.get(e.target)));
		if(!contains(panel))
			addChild(panel);
	}

	private function onUnlocked(e:TokenEvent):Void
	{
		for(note in model.notes){
			if(note.id == e.token.ref){
				note.unlocked = true;
				for(button in noteMap.keys()){
					if(noteMap.get(button) == note.content)
						button.visible = true;
				}
			}
		}
	}
}
