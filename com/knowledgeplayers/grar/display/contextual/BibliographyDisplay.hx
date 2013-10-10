package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.display.component.container.DropdownMenu;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.Style;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.structure.contextual.Bibliography;
import haxe.ds.GenericStack;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldType;

/**
 * Display for a bibliography
 */
class BibliographyDisplay extends Sprite implements ContextualDisplay{

	public static var instance (get_instance, null): BibliographyDisplay;

	public var layout (default, default): String;

	private var style:Style;
	private var xOffset:Float = 10;
	private var displayed:GenericStack<DisplayObject>;
	private var filter:TextField;
	private var drop:DropdownMenu;

	public static function get_instance():BibliographyDisplay
	{
		if(instance == null)
			instance = new BibliographyDisplay();
		return instance;
	}

	private function new(?wordStyle:Style)
	{
		super();
		style = wordStyle;
		displayed = new GenericStack<DisplayObject>();
		createFiltersBar();
		displayBibliography(Bibliography.instance.getEntries());
	}

	// Private

	private function onFilter(e:Event):Void
	{
		while(!displayed.isEmpty())
			removeChild(displayed.pop());

		displayBibliography(Bibliography.instance.getEntries(getFilters()));
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

		drop = new DropdownMenu(true);
		drop.addEventListener(Event.CHANGE, onFilter);
		drop.items = Bibliography.instance.getAllPrograms();
		drop.x = filter.x + filter.width + 10;
		addChild(drop);
	}
}