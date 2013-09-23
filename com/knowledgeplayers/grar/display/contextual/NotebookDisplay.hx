package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.structure.contextual.Note;
import haxe.ds.GenericStack;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.TileImage;
import com.knowledgeplayers.grar.event.TokenEvent;
import flash.events.Event;
import com.knowledgeplayers.grar.factory.UiFactory;
import haxe.xml.Fast;
import flash.display.DisplayObject;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.structure.contextual.Notebook;
import com.knowledgeplayers.grar.display.KpDisplay;
import flash.display.Sprite;

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
	private var noteMap: Map<DefaultButton, Note>;

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
		noteMap = new Map<DefaultButton, Note>();
	}

	public function set_model(model:Notebook):Notebook
	{
		if(model != this.model){
			Localiser.instance.layoutPath = model.file;
			// Display bkg
			if(model.background != null){
				addChildAt(displays.get(model.background), 0);
			}

			for(item in model.items){
				if(displays.exists(item)){
					addChild(displays.get(item));
				}
				else
					throw '[NotebookDisplay] There is no item with ref "$item."';
			}

			// Display title
			var title: ScrollPanel = cast(displays.get(model.title.ref), ScrollPanel);
			title.setContent(Localiser.instance.getItemContent(model.title.content));
			addChild(title);

			// Display button
			var button: DefaultButton = cast(displays.get(model.closeButton.ref), DefaultButton);
			button.setText(Localiser.instance.getItemContent(model.closeButton.content));

			addChild(button);

			// Display notes
			var offsetY: Float = 0;
			for(note in model.notes){
				var icons = findIcon(noteTemplate.x);
				for(icon in icons){
					icon.set("src", note.icon);
					icon.nodeName = "Image";
				}
				// Clickable note
				var button: DefaultButton = new DefaultButton(noteTemplate);
				button.y += offsetY;
				offsetY += button.height + Std.parseFloat(noteTemplate.att.offsetY);
				button.setText(Localiser.instance.getItemContent(note.name), "title");
				button.setText(Localiser.instance.getItemContent(note.subtitle), "subtitle");
				buttonGroups.get("notes").add(button);
				//button.enableToggle(true);
				button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
				// Fill hit box
				DisplayUtils.initSprite(button, button.width, button.height, 0, 0.001);
				addChild(button);
				setButtonAction(button, "show");
				button.visible = note.isActivated;
				noteMap.set(button, note);
			}
			return this.model = model;
		}
		return model;
	}

	// Privates

	private function new()
	{
		super();
		GameManager.instance.addEventListener(TokenEvent.ADD, onUnlocked);
		buttonGroups.set("notes", new GenericStack<DefaultButton>());
	}

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		button.buttonAction = switch(action.toLowerCase()){
			case "close" : function(?t: DefaultButton){GameManager.instance.hideContextual(this);};
			case "show" : onSelectNote;
			default: throw "[NotebookDisplay] Unknown action '"+action+"'.";
		}
	}

	private function findIcon(xml:Xml):GenericStack<Xml>
	{
		var results = new GenericStack<Xml>();
		findIconRec(xml, results);
		return results;
	}

	private function findIconRec(xml: Xml, res: GenericStack<Xml>):Void
	{
		if(xml.get("ref") == "icon")
			res.add(xml);
		else{
			for(elem in xml.elements()){
				findIconRec(elem, res);
			}
		}
	}

	private function onSelectNote(?target: DefaultButton):Void
	{
		target.setToggle(false);
		var panel = cast(displays.get(model.contentRef), ScrollPanel);
		var title = cast(displays.get(model.titleRef), ScrollPanel);
		Localiser.instance.pushLocale();
		Localiser.instance.layoutPath = model.file;
		panel.setContent(Localiser.instance.getItemContent(noteMap.get(target).content));
		title.setContent(Localiser.instance.getItemContent(noteMap.get(target).name));
		Localiser.instance.popLocale();
		if(!contains(panel))
			addChild(panel);
		if(!contains(title))
			addChild(title);
	}

	private function onUnlocked(e:TokenEvent):Void
	{
		if(e.token.type == "note"){
			for(note in model.notes){
				if(note.ref == e.token.ref){
					note.isActivated = true;
					for(button in noteMap.keys()){
						if(noteMap.get(button) == note)
							button.visible = true;
					}
				}
			}
		}
	}
}
