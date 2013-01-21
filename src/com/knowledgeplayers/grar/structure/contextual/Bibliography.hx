package com.knowledgeplayers.grar.structure.contextual;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.events.Event;
import nme.Lib;

/**
 * Glossary will be accessible in all your game to provide books and articles references
 */
class Bibliography 
{
	/**
	 * Instance
	 */
	public static var instance (getInstance, null): Bibliography;
	
	private var entries: Array<Entry>;
	private var newEntry: Bool = false;
	
	/**
	 * @return the instance
	 */
	static public function getInstance() : Bibliography
	{
		if (instance == null)
			instance = new Bibliography();
		return instance;
	}
	
	/**
	 * Fill the bibliography using an XMl file
	 * @param	filePath : Path to the XML
	 */
	public function fillWithXml(filePath: String) : Void 
	{
		var content = XmlLoader.load(filePath, onLoadComplete);
		#if !flash
			parseContent(content);
		#end
	}
	
	/**
	 * Get the entries in the bibliography
	 * @param	filter : Filter the entries by any field except year and sumup
	 * @return the entries matching the filter or all of them if no filter was given
	 */
	public function getEntries(?filter: String) : Array<Entry> 
	{
		if(newEntry){
			entries.sort(sort);
			newEntry = false;
		}
		if (filter != null) {
			var ereg = new EReg(filter, "");
			var filteredEntries = new Array<Entry>();
			for (entry in entries) {
				if (ereg.match(entry.author.toLowerCase()) || ereg.match(entry.title.toLowerCase()) || ereg.match(entry.editor.toLowerCase()))
					filteredEntries.push(entry);
				else {
					for (program in entry.programs) {
						if (ereg.match(program.toLowerCase())) {
							filteredEntries.push(entry);
							break;
						}
					}
					for (theme in entry.themes) {
						if (ereg.match(theme.toLowerCase())) {
							filteredEntries.push(entry);
							break;
						}
					}
				}
			}
			return filteredEntries;
		}
		else
			return entries;
	}
	
	/**
	 * Add an entry to the bibliography
	 * @param	entry : Entry to add
	 */
	public function addEntry(entry: Entry) : Void
	{
		entries.push(entry);
		newEntry = true;
	}
	
	// Private
	
	private function sort(x: Entry, y: Entry) : Int 
	{
		if (x.author.toLowerCase() < y.author.toLowerCase())
			return -1;
		else if (x.author.toLowerCase() > y.author.toLowerCase())
			return 1;
		else {
			if (x.title.toLowerCase() < y.title.toLowerCase()) {
				return -1;
			}
			if (x.title.toLowerCase() > y.title.toLowerCase()) {
				return 1;
			}
			return 0;
		}
	}
	
	private function parseContent(content: Xml) : Void
	{
		var fast: Fast = new Fast(content).node.Bibliography;
		for (def in fast.nodes.Entry) {
			var themes = new List<String>();
			var programs = new List<String>();
			for (theme in def.nodes.Theme)
				themes.add(theme.innerData);
			for (program in def.nodes.Program)
				programs.add(program.innerData);
			var entry: Entry = {title:"", author:"", editor:"", year:0, programs:null, themes:null, link: "", sumup: ""};
			entry.title = def.node.Title.innerData;
			entry.author = def.node.Author.innerData;
			entry.editor = def.node.Editor.innerData;
			entry.year = Std.parseInt(def.node.Year.innerData);
			entry.programs = programs;
			entry.themes = themes;
			if (def.hasNode.Link)
				entry.link = def.node.Link.innerData;
			if(def.hasNode.SumUp)
				entry.sumup = def.node.SumUp.innerData;
			
			addEntry(entry);
		}
	}
	
	private function onLoadComplete(event: Event) : Void 
	{
		parseContent(XmlLoader.getXml(event));
	}
	
	private function new() 
	{
		entries = new Array<Entry>();
	}
}

typedef Entry = {
	var title: String;
	var author: String;
	var editor: String;
	var year: Int;
	var link: String;
	var sumup: String;
	var themes: List<String>;
	var programs: List<String>;
}