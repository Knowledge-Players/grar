package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.display.component.container.VideoPlayer;
import com.knowledgeplayers.grar.structure.contextual.Note;
import haxe.ds.GenericStack;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.event.TokenEvent;
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
	private var currentPage: Page;
	private var tabTemplate: Fast;

	private inline static var noteGroupName: String = "notes";
	private inline static var tabGroupName: String = "tabs";

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
		tabTemplate = displayFast.node.Tab;
	}

	public function set_model(model:Notebook):Notebook
	{
		if(model != this.model){
			this.model = model;

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

			// Display page
			displayPage(model.pages[0]);

			// Set Locale
			Localiser.instance.pushLocale();
			Localiser.instance.layoutPath = model.file;

			// Display close button
			var button: DefaultButton = cast(displays.get(model.closeButton.ref), DefaultButton);
			button.setText(Localiser.instance.getItemContent(model.closeButton.content));

			addChild(button);

			// Display Tabs
			var totalX: Float = Std.parseFloat(tabTemplate.att.x);
			var xOffset = Std.parseFloat(tabTemplate.att.xOffset);
			var first = true;
			for(page in model.pages){
				var cloneXml = Xml.parse(tabTemplate.x.toString()).firstElement();
				var tmpTemplate = new Fast(cloneXml);
				tmpTemplate.x.set("ref", page.tabContent);
				var icons = findIcon(tmpTemplate.x);
				for(icon in icons){
					icon.set("tile", page.icon+icon.get("tile"));
				}

				var tab = new DefaultButton(tmpTemplate);
				tab.x = totalX;
				totalX += tab.width+xOffset;
				tab.name = page.tabContent;
				tab.setText(Localiser.instance.getItemContent(page.tabContent));
				buttonGroups.get(tabGroupName).add(tab);
				setButtonAction(tab, tmpTemplate.att.action);
				addChild(tab);
				if(first){
					tab.toggle();
					first = false;
				}
				tab.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
			}
			Localiser.instance.popLocale();
		}
		return model;
	}

	// Privates

	private function new()
	{
		super();
		GameManager.instance.addEventListener(TokenEvent.ADD, onUnlocked);
		buttonGroups.set(noteGroupName, new GenericStack<DefaultButton>());
		buttonGroups.set(tabGroupName, new GenericStack<DefaultButton>());
	}

	private function displayPage(page:Page):Void
	{
		currentPage = page;

		// Set Locale
		Localiser.instance.pushLocale();
		Localiser.instance.layoutPath = model.file;

		// Display title
		var title: ScrollPanel = cast(displays.get(currentPage.title.ref), ScrollPanel);
		title.setContent(Localiser.instance.getItemContent(currentPage.title.content));
		addChild(title);

		// Clean previous note
		for(note in buttonGroups.get(noteGroupName)){
			removeChild(note);
			note = null;
		}
		buttonGroups.set(noteGroupName, new GenericStack<DefaultButton>());
		noteMap = new Map<DefaultButton, Note>();
		cast(displays.get(currentPage.contentRef), ScrollPanel).setContent("");
		if(contains(displays.get("player")))
			removeChild(displays.get("player"));

		var offsetY: Float = 0;

		// Fill every occurences of "icon" element with the proper tile/img
		for(note in currentPage.notes){
			var icons = findIcon(noteTemplate.x);
			for(icon in icons){
				if(note.icon.indexOf(".") < 0){
					icon.set("tile", note.icon);
					if(icon.exists("src"))
						icon.remove("src");
				}
				else{
					icon.set("src", note.icon);
					if(icon.exists("tile"))
						icon.remove("tile");
				}
				icon.nodeName = "Image";
			}
			// Clickable note
			var button: DefaultButton = new DefaultButton(noteTemplate);
			button.y += offsetY;
			offsetY += button.height + Std.parseFloat(noteTemplate.att.offsetY);
			button.setText(Localiser.instance.getItemContent(note.name), "title");
			button.setText(Localiser.instance.getItemContent(note.subtitle), "subtitle");
			buttonGroups.get(noteGroupName).add(button);
			button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
			// Fill hit box
			DisplayUtils.initSprite(button, button.width, button.height, 0, 0.001);
			button.visible = button.enabled = note.isActivated;
			addChild(button);
			setButtonAction(button, "show");
			noteMap.set(button, note);

		}
		Localiser.instance.popLocale();
	}

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		button.buttonAction = switch(action.toLowerCase()){
			case "close" : function(?t: DefaultButton){GameManager.instance.hideContextual(this);};
			case "show" : onSelectNote;
			case "goto" :
				changePage;
			default: throw "[NotebookDisplay] Unknown action '"+action+"'.";
		}
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

	private function onSelectNote(?target: DefaultButton):Void
	{
		var panel = cast(displays.get(currentPage.contentRef), ScrollPanel);
		var title = cast(displays.get(currentPage.titleRef), ScrollPanel);
		Localiser.instance.pushLocale();
		Localiser.instance.layoutPath = model.file;
		panel.setContent(Localiser.instance.getItemContent(noteMap.get(target).content));
		title.setContent(Localiser.instance.getItemContent(noteMap.get(target).name));
		Localiser.instance.popLocale();
		if(!contains(panel))
			addChild(panel);
		if(!contains(title))
			addChild(title);

		if(noteMap.get(target).video != null){
			var player = cast(displays.get("player"), VideoPlayer);
			player.setVideo(noteMap.get(target).video);
			player.scale = 0.5;
			addChild(player);
		}

	}

	private function changePage(?target:DefaultButton):Void
	{
		for(page in model.pages){
			if(page.tabContent == target.name)
				displayPage(page);
		}
	}

	private function onUnlocked(e:TokenEvent):Void
	{
		if(e.token.type == "note"){
			for(note in model.getAllNotes()){
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
