package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.factory.GuideFactory;
import com.knowledgeplayers.grar.event.PartEvent;
import flash.events.Event;
import flash.net.URLRequest;
import com.knowledgeplayers.grar.localisation.Localiser;
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

	private inline static var noteGroupName: String = "notes";
	private inline static var tabGroupName: String = "tabs";
	private inline static var stepGroupName: String = "steps";

	/**
	* Instance of the display
	**/
	public static var instance (get_instance, null): NotebookDisplay;

	/**
	* Model
	**/
	public var model (default, set_model): Notebook;

	private var chapterTemplates: Map<String, Fast>;
	private var chapterMap: Map<DefaultButton, Chapter>;
	private var currentPage: Page;
	private var tabTemplate: Fast;
	private var bookmark: Fast;
	private var bookmarkBkg: Widget;
	private var currentChapter: DefaultButton;

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
		chapterTemplates = new Map<String,Fast>();
		for(chapter in displayFast.nodes.Chapter)
			chapterTemplates.set(chapter.att.ref, chapter);
		chapterMap = new Map<DefaultButton, Chapter>();
		tabTemplate = displayFast.node.Tab;
		bookmark = displayFast.node.Bookmark;
		buttonGroups.set(noteGroupName, new GenericStack<DefaultButton>());
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


			// Set Locale
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

				var offsetY: Float = 0;
				// Fill every occurences of "icon" element with the proper tile/img
				for(chapter in page.chapters){
					if(!chapterTemplates.exists(chapter.ref))
						throw "[NotebookDisplay] There is no template for chapter with ref '"+chapter.ref+"'.";
					var icons = ParseUtils.selectByAttribute("ref", "icon", chapterTemplates.get(chapter.ref).x);
					ParseUtils.updateIconsXml(chapter.icon, icons);
					// Clickable note
					var button: DefaultButton = new DefaultButton(chapterTemplates.get(chapter.ref));
					button.y += offsetY;
					offsetY += button.height + Std.parseFloat(chapterTemplates.get(chapter.ref).att.offsetY);
					var chapterTitle = Localiser.instance.getItemContent(chapter.name);
					button.setText(chapterTitle, "title");
					button.setText(Localiser.instance.getItemContent(chapter.subtitle), "subtitle");
					buttonGroups.get(noteGroupName).add(button);
					button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
					// Fill hit box
					DisplayUtils.initSprite(button, button.width, button.height, 0, 0.001);
					setButtonAction(button, "show");
					chapterMap.set(button, chapter);
				}
			}

			currentPage = model.pages[0];

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
		buttonGroups.set(stepGroupName, new GenericStack<DefaultButton>());

		addEventListener(Event.ADDED_TO_STAGE, function(e){
			displayPage(currentPage);
			dispatchEvent(new PartEvent(PartEvent.ENTER_PART));
		});

		addEventListener(Event.REMOVED_FROM_STAGE, function(e){
			dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
			clearPage();
		});
	}

	private function displayPage(page:Page):Void
	{
		currentPage = page;

		// Set Locale
		Localiser.instance.layoutPath = model.file;

		// Display title
		var title: ScrollPanel = cast(displays.get(currentPage.title.ref), ScrollPanel);
		title.setContent(Localiser.instance.getItemContent(currentPage.title.content));
		addChild(title);

		// Build Bookmark container
		if(bookmarkBkg == null)
			bookmarkBkg = createImage(bookmark);

		clearPage();

        if(displays.exists("player") && contains(displays.get("player")))
			removeChild(displays.get("player"));

		for(chapter in chapterMap.keys()){
			if(Lambda.has(currentPage.chapters, chapterMap.get(chapter)) && chapterMap.get(chapter).isActivated)
				addChild(chapter);
			else if(contains(chapter))
				removeChild(chapter);
		}

		Localiser.instance.popLocale();
	}

	override private function setButtonAction(button:DefaultButton, action:String):Bool
	{
		if(super.setButtonAction(button, action))
			return true;
		button.buttonAction = switch(action.toLowerCase()){
			case "close" : function(?t: DefaultButton){GameManager.instance.hideContextual(this);};
			case "show" : onSelectChapter;
			case "goto" : changePage;
			case "gotonote": changeNote;
			default: throw "[NotebookDisplay] Unknown action '"+action+"'.";
		}
		return true;
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
			clearPage(target);
			addChild(bookmarkBkg);
			var guide: Guide = GuideFactory.createGuideFromXml(bookmark.node.Guide);
			// Create steps
			for(i in 0...numActive){
				var step: DefaultButton = cast(createButton(bookmark.node.Step), DefaultButton);
				step.setText(Std.string(i+1));
				step.name = Std.string(i);
				var transitionIn = null;
                if(bookmark.node.Step.has.transitionIn)
                    transitionIn = bookmark.node.Step.att.transitionIn;
				guide.add(step,transitionIn);
				if(i == 0)
					step.toggle();
				addChild(step);
				buttonGroups.get(stepGroupName).add(step);
			}
			var chapter: Chapter = chapterMap.get(target);
			Localiser.instance.layoutPath = model.file;
			cast(displays.get(chapter.titleRef), ScrollPanel).setContent(Localiser.instance.getItemContent(chapter.name));
			Localiser.instance.popLocale();
			addChild(displays.get(chapter.titleRef));
		}
		var i = 0;
		while(i < notes.length && !notes[i].isActivated)
			i++;
		if(i < notes.length)
			displayNote(chapterMap.get(target).notes[i]);
	}

	private function displayNote(note: Note):Void
	{
		Localiser.instance.layoutPath = model.file;
		var panel = cast(displays.get(note.ref), ScrollPanel);

		if(note.content.indexOf("/") < 1){
			panel.setContent(Localiser.instance.getItemContent(note.content));

			Localiser.instance.popLocale();
			addChild(panel);

			if(note.video != null){
				var player = cast(displays.get("player"), VideoPlayer);
				player.setVideo(note.video);
				addChild(player);
			}
			else if(displays.exists("player")){
				var player = cast(displays.get("player"), VideoPlayer);
				player.stopVideo();
				if(contains(player))
					removeChild(player);
			}
		}
		#if flash
		else{
			var url = new URLRequest(note.content);
			flash.Lib.getURL(url, "_blank");
		}
		#end
	}

	private function changeNote(?target:DefaultButton):Void
	{
		var notes = Lambda.filter(chapterMap.get(currentChapter).notes, function(note: Note){
			return note.isActivated;
		});
		var i = 0;
		while(i < Std.parseInt(target.name)){
			i++;
			notes.pop();
		}
		displayNote(notes.first());
	}

	private function changePage(?target:DefaultButton):Void
	{
		// Clear page
		clearPage();

		var i = 0;
		while(i < model.pages.length && model.pages[i].tabContent != target.name)
			i++;
		if(i < model.pages.length)
			displayPage(model.pages[i]);
	}

	private function onUnlocked(e:TokenEvent):Void
	{
		if(e.token.type == "note"){
			var notes = model.getAllNotes();
			var k = 0;
			while(k < notes.length && notes[k].id != e.token.id){
				k++;
			}
			if(k != notes.length){
				var chapter: Chapter = null;
				var i = 0;
				while(i < model.pages.length && chapter == null){
					var j = 0;
					while(j < model.pages[i].chapters.length && !Lambda.has(model.pages[i].chapters[j].notes, notes[k]))
						j++;
					chapter = j == model.pages[i].chapters.length ? null : model.pages[i].chapters[j];
					i++;
				}
				if(chapter != null){
					chapter.isActivated = true;
				}
			}
		}
	}

	private inline function clearPage(?activeChapter: DefaultButton):Void
	{
		clearSteps();
		if(chapterMap.exists(currentChapter)){
			for(note in chapterMap.get(currentChapter).notes){
				if(contains(displays.get(note.ref)))
					removeChild(displays.get(note.ref));
			}
		}
		for(chapter in chapterMap.keys())
			if(chapter != activeChapter)
				chapter.toggle(false);
	}

	private inline function clearSteps():Void
	{
		while(!buttonGroups.get(stepGroupName).isEmpty()){
			var step = buttonGroups.get(stepGroupName).pop();
			if(contains(step))
				removeChild(step);
			step = null;
		}
		if(contains(bookmarkBkg))
			removeChild(bookmarkBkg);
	}
}
