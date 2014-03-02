package grar.view.contextual;

import aze.display.TilesheetEx;

import grar.view.component.container.DropdownMenu;
import grar.view.style.Style;
import grar.view.text.StyledTextField;

import grar.parser.style.KpTextDownParser;

import grar.model.contextual.Bibliography;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldType;

import haxe.ds.GenericStack;

/**
 * Display for a bibliography
 */
class BibliographyDisplay extends Sprite {

	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : TilesheetEx, bibliography : Bibliography, ? wordStyle : Style)
	{
		super();

		this.applicationTilesheet = applicationTilesheet;

		this.style = wordStyle;
		this.bibliography = bibliography;
		this.callbacks = callbacks;

		displayed = new GenericStack<DisplayObject>();
		createFiltersBar();
		displayBibliography(bibliography.getEntries());
	}

	public var layout (default, default) : String;

	private var style:Style;
	private var xOffset:Float = 10;
	private var displayed:GenericStack<DisplayObject>;
	private var filter:TextField;
	private var drop:DropdownMenu;
	var bibliography : Bibliography;
	var callbacks : grar.view.DisplayCallbacks;
	var applicationTilesheet : TilesheetEx;

	// Private

	private function onFilter(e:Event):Void
	{
		while(!displayed.isEmpty())
			removeChild(displayed.pop());

		displayBibliography(bibliography.getEntries(getFilters()));
	}

	private function displayBibliography(entries:Array<Entry>):Void
	{
		var lastAuthor:String = " ";
		var yOffset:Float = 0;
		for(entry in entries){
			if(entry.author != lastAuthor){
				lastAuthor = entry.author;
				var author = new StyledTextField(style);
				author.text = lastAuthor;
				author.y = yOffset;
				addChild(author);
				displayed.add(author);
				yOffset += author.height;
			}
			var buf = new StringBuf();
			buf.add(entry.title);
			buf.add(", ");
			buf.add(entry.editor);
			buf.add(", ");
			buf.add(entry.year);
			buf.add(". ");
			buf.add(entry.programs.join(", "));
			buf.add(" ; ");
			buf.add(entry.themes.join(", "));
			buf.add(". ");
			buf.add(entry.sumup);
			var entriesKPTD = KpTextDownParser.parse(buf.toString());
			var entrySprite = entriesKPTD[0].createSprite(width);
			entrySprite.x = xOffset;
			entrySprite.y = yOffset;
			addChild(entrySprite);
			displayed.add(entrySprite);
			yOffset += entrySprite.height;
		}
	}

	private function getFilters():GenericStack<String>
	{
		var filters = new GenericStack<String>();
		if(filter.text != "Filtrer...")
			filters.add(filter.text.toLowerCase());
		filters.add(drop.currentLabel.toLowerCase());
		return filters;
	}

	private function createFiltersBar():Void
	{
		filter = new TextField();
		filter.type = TextFieldType.INPUT;
		filter.addEventListener(Event.CHANGE, onFilter);
		filter.text = "Filtrer...";
		filter.x = 600;
		filter.height = filter.textHeight + 10;
		filter.border = true;
		addChild(filter);

		drop = new DropdownMenu(callbacks, applicationTilesheet, null, true);
		drop.addEventListener(Event.CHANGE, onFilter);
		drop.items = bibliography.getAllPrograms();
		drop.x = filter.x + filter.width + 10;
		addChild(drop);
	}
}