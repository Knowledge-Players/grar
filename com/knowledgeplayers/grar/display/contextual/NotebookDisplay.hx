package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.util.guide.Guide;
import com.knowledgeplayers.grar.display.component.Widget;
import flash.geom.Point;
import com.knowledgeplayers.grar.util.guide.Line;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.display.component.container.VideoPlayer;
import com.knowledgeplayers.grar.structure.contextual.Note;
import haxe.ds.GenericStack;
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

	private var chapterTemplate: Fast;
	private var chapterMap: Map<DefaultButton, Chapter>;
	private var currentPage: Page;
	private var tabTemplate: Fast;
	private var bookmark: Fast;
	private var bookmarkBkg: Widget;
	private var currentChapter: DefaultButton;

	private inline static var noteGroupName: String = "notes";
	private inline static var tabGroupName: String = "tabs";
	private inline static var stepGroupName: String = "steps";

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
		chapterTemplate = displayFast.node.Chapter;
		chapterMap = new Map<DefaultButton, Chapter>();
		tabTemplate = displayFast.node.Tab;
		bookmark = displayFast.node.Bookmark;
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
				var icons = ParseUtils.selectByAttribute("ref", "icon", tmpTemplate.x);
				ParseUtils.updateIconsXml(page.icon, icons);

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
		chapterMap = new Map<DefaultButton, Chapter>();
		cast(displays.get(currentPage.contentRef), ScrollPanel).setContent("");
		if(contains(displays.get("player")))
			removeChild(displays.get("player"));

		var offsetY: Float = 0;

		// Fill every occurences of "icon" element with the proper tile/img
		for(chapter in currentPage.chapters){
			var icons = ParseUtils.selectByAttribute("ref", "icon", chapterTemplate.x);
			ParseUtils.updateIconsXml(chapter.icon, icons);
			// Clickable note
			var button: DefaultButton = new DefaultButton(chapterTemplate);
			button.y += offsetY;
			offsetY += button.height + Std.parseFloat(chapterTemplate.att.offsetY);
			button.setText(Localiser.instance.getItemContent(chapter.name), "title");
			button.setText(Localiser.instance.getItemContent(chapter.subtitle), "subtitle");
			buttonGroups.get(noteGroupName).add(button);
			button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
			// Fill hit box
			DisplayUtils.initSprite(button, button.width, button.height, 0, 0.001);
			button.visible = button.enabled = chapter.isActivated;
			// I don't know why visible doesn't do the job
			button.alpha = button.visible ? 1 : 0;
			addChild(button);
			setButtonAction(button, "show");
			chapterMap.set(button, chapter);
		}

		// Build Bookmark container
		bookmarkBkg = createImage(bookmark);

		Localiser.instance.popLocale();
	}

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		button.buttonAction = switch(action.toLowerCase()){
			case "close" : function(?t: DefaultButton){GameManager.instance.hideContextual(this);};
			case "show" : onSelectChapter;
			case "goto" : changePage;
			case "gotonote": changeNote;
			default: throw "[NotebookDisplay] Unknown action '"+action+"'.";
		}
	}

	private function onSelectChapter(?target: DefaultButton):Void
	{
		currentChapter = target;
		var notes: Array<Note> = chapterMap.get(target).notes;
		var numActive = 0;
		for(note in notes)
			if(note.isActivated)
				numActive++;
		if(numActive > 1){
			addChild(bookmarkBkg);
			var guideFast = bookmark.node.Guide;
			// TODO check other guide  type
			var guide: Guide = switch(guideFast.att.type.toLowerCase()){
				case "line": var start = ParseUtils.parseListOfIntValues(guideFast.att.start, ";");
					var end = ParseUtils.parseListOfIntValues(guideFast.att.end, ";");
					new Line(new Point(start[0], start[1]), new Point(end[0], end[1]), guideFast.has.center?guideFast.att.center=="true":false);
				default: null;
			}
			for(i in 0...numActive){
				var step: DefaultButton = cast(createButton(bookmark.node.Step), DefaultButton);
				step.setText(Std.string(i+1));
				step.name = Std.string(i);
				guide.add(step, false);
				if(i == 0)
					step.toggle();
				addChild(step);
			}
		}
		displayNote(chapterMap.get(target).notes[0]);
	}

	private function displayNote(note: Note):Void
	{
		Localiser.instance.pushLocale();
		Localiser.instance.layoutPath = model.file;
		var panel = cast(displays.get(currentPage.contentRef), ScrollPanel);
		var title = cast(displays.get(currentPage.titleRef), ScrollPanel);

		panel.setContent(Localiser.instance.getItemContent(note.content));
		title.setContent(Localiser.instance.getItemContent(note.name));
		Localiser.instance.popLocale();
		if(!contains(panel))
			addChild(panel);
		if(!contains(title))
			addChild(title);

		if(note.video != null){
			var player = cast(displays.get("player"), VideoPlayer);
			player.setVideo(note.video);
			player.scale = 0.5;
			addChild(player);
		}
	}

	private function changeNote(?target:DefaultButton):Void
	{
		displayNote(chapterMap.get(currentChapter).notes[Std.parseInt(target.name)]);
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
			var notes = model.getAllNotes();
			var i = 0;
			while(i < notes.length && notes[i].ref != e.token.ref){
				i++;
			}
			if(i != notes.length){
				notes[i].isActivated = true;
				for(button in chapterMap.keys()){
					if(Lambda.has(chapterMap.get(button).notes, notes[i])){
						button.visible = true;
						button.alpha = 1;
					}
				}
			}
		}
	}
}
