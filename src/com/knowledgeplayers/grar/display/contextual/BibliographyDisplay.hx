package com.knowledgeplayers.grar.display.contextual;
import com.knowledgeplayers.grar.display.component.DropdownMenu;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.Style;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.structure.contextual.Bibliography;
import haxe.FastList;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.text.TextField;
import nme.text.TextFieldType;

/**
 * Display for a bibliography
 */
class BibliographyDisplay extends Sprite
{
	private var style: Style;
	private var xOffset: Float = 10;
	private var displayed: FastList<DisplayObject>;
	private var filter: TextField;
	private var drop: DropdownMenu;
	
	public function new(?wordStyle: Style) 
	{
		super();
		style = wordStyle;
		displayed = new FastList<DisplayObject>();
		createFiltersBar();
		displayBibliography(Bibliography.instance.getEntries());
	}
	
	// Private
	
	private function onFilter(e: Event) : Void 
	{
		while(!displayed.isEmpty())
			removeChild(displayed.pop());
		
		displayBibliography(Bibliography.instance.getEntries(getFilters()));
	}
	
	private function displayBibliography(entries: Array<Entry>) : Void
	{
		var lastAuthor: String = " ";
		var yOffset: Float = 0;
		for (entry in entries) {
			if (entry.author != lastAuthor) {
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
			var entrySprite = KpTextDownParser.parse(buf.toString());
			entrySprite.x = xOffset;
			entrySprite.y = yOffset;
			addChild(entrySprite);
			displayed.add(entrySprite);
			yOffset += entrySprite.height;
		}
	}
	
	private function getFilters() : FastList<String> 
	{
		var filters = new FastList<String>();
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
		filter.height = filter.textHeight +10;
		filter.border = true;
		addChild(filter);
		
		drop = new DropdownMenu(true);
		drop.addEventListener(Event.CHANGE, onFilter);
		drop.items = Bibliography.instance.getAllPrograms();
		drop.x = filter.x + filter.width + 10;
		addChild(drop);
	}
}