package grar.view.contextual;

// FIXME import com.knowledgeplayers.grar.localisation.Localiser;

import grar.view.component.container.VideoPlayer;
import grar.view.component.container.DefaultButton;
import grar.view.component.container.ScrollPanel;
import grar.view.component.container.WidgetContainer;
import grar.view.component.Widget;
import grar.view.component.Image;
import grar.view.guide.Guide;
import grar.view.guide.Line;
import grar.view.guide.Grid;
import grar.view.guide.Curve;
import grar.view.Display;
import grar.view.ElementData;

import grar.model.contextual.Notebook;
import grar.model.contextual.Note;

import grar.util.ParseUtils;
import grar.util.DisplayUtils;

// FIXME import com.knowledgeplayers.grar.event.PartEvent; // FIXME
// FIXME import com.knowledgeplayers.grar.event.TokenEvent; // FIXME
// FIXME import com.knowledgeplayers.grar.event.ButtonActionEvent; // FIXME

import flash.events.Event;
import flash.net.URLRequest;
import flash.geom.Point;
import flash.display.DisplayObject;
import flash.display.Sprite;

import haxe.ds.StringMap;
import haxe.ds.GenericStack;

class NotebookDisplay extends Display /* implements ContextualDisplay */ { // TODO check use of ContextualDisplay

	static private inline var NOTE_GROUP_NAME : String = "notes";
	static private inline var TAB_GROUP_NAME : String = "tabs";
	static private inline var STEP_GROUP_NAME : String = "steps";

	public function new() {

		super();

// FIXME		GameManager.instance.addEventListener(TokenEvent.ADD, onUnlocked);
		
		buttonGroups.set(NOTE_GROUP_NAME, new GenericStack<DefaultButton>());
		buttonGroups.set(TAB_GROUP_NAME, new GenericStack<DefaultButton>());
		buttonGroups.set(STEP_GROUP_NAME, new GenericStack<DefaultButton>());

		addEventListener(Event.ADDED_TO_STAGE, function(e){

				displayPage(currentPage);
// FIXME				dispatchEvent(new PartEvent(PartEvent.ENTER_PART));

			});

		addEventListener(Event.REMOVED_FROM_STAGE, function(e){

// FIXME				dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
				clearPage();

			});
	}

	public var model (default, set) : Notebook;

	private var chapterTemplates : StringMap<{ offsetY : Float, e : ElementData }>;

	private var chapterMap : Map<DefaultButton, Chapter>;
	private var currentPage : Page;
	private var tabTemplate : { x : Float, xOffset : Float, e : WidgetContainerData };
	private var currentChapter : DefaultButton;

	private var bookmark : ImageData;
	private var bookmarkBkg : Widget;

	private var guideData : GuideData;
	private var stepData : { r : String, e : WidgetContainerData, transitionIn : Null<String> };


	///
	// API
	//

//	override public function parseContent(content:Xml):Void
	override public function setContent(d : DisplayData) : Void {

		super.setContent(d);

		switch (d.type) {

			case Notebook(ct, tt, b, gd, sd):

				if (d.layout != null) {

					this.layout = d.layout;
				}
				this.chapterTemplates = ct;
				this.chapterMap = new Map();

				this.tabTemplate = tt;
				this.bookmark = b;
				this.guideData = gd;
				this.stepData = sd;

				this.buttonGroups.set(NOTE_GROUP_NAME, new GenericStack<DefaultButton>());

			default: throw "wrong DisplayData type given to NotebookDisplay.setContent()";
		}
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
// FIXME			Localiser.instance.layoutPath = model.file;

			// Display close button
			var button: DefaultButton = cast(displays.get(model.closeButton.ref), DefaultButton);
// FIXME			button.setText(Localiser.instance.getItemContent(model.closeButton.content));

			addChild(button);

			// Display Tabs
			var totalX : Float = tabTemplate.x; // FIXME
			var xOffset : Float = tabTemplate.xOffset; // FIXME
			var first : Bool = true;

			for (page in model.pages) {

				//var cloneXml = Xml.parse(tabTemplate.x.toString()).firstElement(); ???
				//var tmpTemplate = new Fast(cloneXml);
				//tmpTemplate.x.set("ref", page.tabContent);
				tabTemplate.e.wd.ref = page.tabContent;


// FIXME				var icons = ParseUtils.selectByAttribute("ref", "icon", tmpTemplate.x);
// FIXME				ParseUtils.updateIconsXml(page.icon, icons);

				var tab = new DefaultButton(tabTemplate.e); // FIXME

				tab.x = totalX;
				totalX += tab.width+xOffset;
				tab.name = page.tabContent;
// FIXME				tab.setText(Localiser.instance.getItemContent(page.tabContent));
				
				buttonGroups.get(TAB_GROUP_NAME).add(tab);
//				setButtonAction(tab, tmpTemplate.att.action);
				setButtonAction(tab, switch(tabTemplate.e.type){ case DefaultButton(_, _, a, _, _, _, _): a; default: null; });

				addChild(tab);
				
				if(first) {

					tab.toggle();
					first = false;
				}
// FIXME				tab.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);

				var offsetY: Float = 0;
				// Fill every occurences of "icon" element with the proper tile/img
				for (chapter in page.chapters) {

					if (!chapterTemplates.exists(chapter.ref)) {

						throw "[NotebookDisplay] There is no template for chapter with ref '"+chapter.ref+"'.";
					}

// FIXME					var icons = ParseUtils.selectByAttribute("ref", "icon", chapterTemplates.get(chapter.ref).x);
// FIXME					ParseUtils.updateIconsXml(chapter.icon, icons);
					// Clickable note
					var button : DefaultButton;

					switch (chapterTemplates.get(chapter.ref).e) {

						case DefaultButton(d):

							button = new DefaultButton(d);

						default: throw "";
					}
					button.y += offsetY;
					offsetY += button.height + chapterTemplates.get(chapter.ref).offsetY;
// FIXME					var chapterTitle = Localiser.instance.getItemContent(chapter.name);
// FIXME					button.setText(chapterTitle, "title");
// FIXME					button.setText(Localiser.instance.getItemContent(chapter.subtitle), "subtitle");
					buttonGroups.get(NOTE_GROUP_NAME).add(button);
// FIXME					button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
					// Fill hit box
					DisplayUtils.initSprite(button, button.width, button.height, 0, 0.001);
					//button.alpha = chapter.isActivated ? 1 : 0;
					//addChild(button);
					setButtonAction(button, "show");
					chapterMap.set(button, chapter);
				}
			}

			currentPage = model.pages[0];
			// Display page
			//displayPage(model.pages[0]);

// FIXME			Localiser.instance.popLocale();
		}
		return model;
	}

	// Privates

	private function displayPage(page:Page):Void
	{
		currentPage = page;

		// Set Locale
// FIXME		Localiser.instance.layoutPath = model.file;

		// Display title
		var title: ScrollPanel = cast(displays.get(currentPage.title.ref), ScrollPanel);
// FIXME		title.setContent(Localiser.instance.getItemContent(currentPage.title.content));
		addChild(title);

		// Build Bookmark container
		if(bookmarkBkg == null) {

			bookmarkBkg = createImage(bookmark.wd.ref, bookmark);
		}

		// Clean previous note
		/*for(note in buttonGroups.get(NOTE_GROUP_NAME)){
			removeChild(note);
			note = null;
		}*/
		clearPage();

        if(displays.exists("player") && contains(displays.get("player")))
			removeChild(displays.get("player"));

		for(chapter in chapterMap.keys()){
			if(Lambda.has(currentPage.chapters, chapterMap.get(chapter)) && chapterMap.get(chapter).isActivated)
				addChild(chapter);
			else if(contains(chapter))
				removeChild(chapter);
		}

// FIXME		Localiser.instance.popLocale();
	}

	override private function setButtonAction(button:DefaultButton, action:String):Bool
	{
		if(super.setButtonAction(button, action))
			return true;
		button.buttonAction = switch(action.toLowerCase()){
// FIXME			case "close" : function(?t: DefaultButton){GameManager.instance.hideContextual(this);};
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
		
		for (note in notes) {

			if (note.isActivated) {

				numActive++;
			}
		}
		if (numActive > 1) {

			clearPage(target);
			addChild(bookmarkBkg);

			var guide : Guide;

			switch (guideData) {

				case Line(d):

					guide = new Line(d);

				case Grid(d):

					guide = new Grid(d);

				case Curve(d):

					guide = new Curve(d);
			}
			
			// Create steps
			for(i in 0...numActive) {

				var step : DefaultButton = cast(createButton(stepData.r, stepData.e), DefaultButton);
				step.setText(Std.string(i+1));
				step.name = Std.string(i);
				var transitionIn = null;

                if (stepData.transitionIn != null) {

                    transitionIn = stepData.transitionIn;
                }
				
				guide.add(step,transitionIn);

				if (i == 0) {

					step.toggle();
				}
				addChild(step);
				buttonGroups.get(STEP_GROUP_NAME).add(step);
			}
			var chapter: Chapter = chapterMap.get(target);
// FIXME			Localiser.instance.layoutPath = model.file;
// FIXME			cast(displays.get(chapter.titleRef), ScrollPanel).setContent(Localiser.instance.getItemContent(chapter.name));
// FIXME			Localiser.instance.popLocale();
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
// FIXME		Localiser.instance.layoutPath = model.file;
		var panel = cast(displays.get(note.ref), ScrollPanel);

		if(note.content.indexOf("/") < 1){
// FIXME			panel.setContent(Localiser.instance.getItemContent(note.content));

// FIXME			Localiser.instance.popLocale();
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
/* FIXME
	private function onUnlocked(e:TokenEvent):Void
	{
		if(e.token.type == "note"){
			var notes = model.getAllNotes();
			var k = 0;
			while(k < notes.length && notes[k].name != e.token.name){
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
					for(button in chapterMap.keys()){
						if(chapterMap.get(button) == chapter){
							button.alpha = 1;
							break ;
						}
					}
				}
			}
		}
	}
*/
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
		while(!buttonGroups.get(STEP_GROUP_NAME).isEmpty()){
			var step = buttonGroups.get(STEP_GROUP_NAME).pop();
			if(contains(step))
				removeChild(step);
			step = null;
		}
		if(contains(bookmarkBkg))
			removeChild(bookmarkBkg);
	}
}
