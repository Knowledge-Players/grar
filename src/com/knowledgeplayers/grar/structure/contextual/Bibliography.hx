package com.knowledgeplayers.grar.structure.contextual;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.FastList;
import haxe.xml.Fast;
import nme.events.Event;

/**
 * Glossary will be accessible in all your game to provide books and articles references
 */
class Bibliography {
    /**
     * Instance
     */
    public static var instance (getInstance, null): Bibliography;

    private var entries: Array<Entry>;
    private var newEntry: Bool = false;

    /**
     * @return the instance
     */

    static public function getInstance(): Bibliography
    {
        if(instance == null)
            instance = new Bibliography();
        return instance;
    }

    /**
     * Fill the bibliography using an XMl file
     * @param	filePath : Path to the XML
     */

    public function fillWithXml(filePath: String): Void
    {
        XmlLoader.load(filePath, onLoadComplete, parseContent);
    }

    /**
     * Get the entries in the bibliography
     * @param	filter : Filter the entries by any field except year and sumup
     * @return the entries matching the filter or all of them if no filter was given
     */

    public function getEntries(?filters: FastList<String>): Array<Entry>
    {
        if(newEntry){
            entries.sort(sort);
            newEntry = false;
        }
        if(filters != null){
            return applyFilter(filters, entries);
        }
        else
            return entries;
    }

    /**
     * Add an entry to the bibliography
     * @param	entry : Entry to add
     */

    public function addEntry(entry: Entry): Void
    {
        entries.push(entry);
        newEntry = true;
    }

    /**
     * @return all the programs mentionned in the bibliography
     */

    public function getAllPrograms(): FastList<String>
    {
        var list = new FastList<String>();
        for(entry in entries){
            for(prgm in entry.programs){
                if(!contains(list, prgm))
                    list.add(prgm);
            }
        }
        return list;
    }

    // Private

    private function sort(x: Entry, y: Entry): Int
    {
        if(x.author.toLowerCase() < y.author.toLowerCase())
            return -1;
        else if(x.author.toLowerCase() > y.author.toLowerCase())
            return 1;
        else{
            if(x.title.toLowerCase() < y.title.toLowerCase()){
                return -1;
            }
            if(x.title.toLowerCase() > y.title.toLowerCase()){
                return 1;
            }
            return 0;
        }
    }

    private function parseContent(content: Xml): Void
    {
        var fast: Fast = new Fast(content).node.Bibliography;
        for(def in fast.nodes.Entry){
            var themes = new List<String>();
            var programs = new List<String>();
            for(theme in def.nodes.Theme)
                themes.add(theme.innerData);
            for(program in def.nodes.Program)
                programs.add(program.innerData);
            var entry: Entry = {title:"", author:"", editor:"", year:0, programs:null, themes:null, link: "", sumup: ""};
            entry.title = def.node.Title.innerData;
            entry.author = def.node.Author.innerData;
            entry.editor = def.node.Editor.innerData;
            entry.year = Std.parseInt(def.node.Year.innerData);
            entry.programs = programs;
            entry.themes = themes;
            if(def.hasNode.Link)
                entry.link = def.node.Link.innerData;
            if(def.hasNode.SumUp)
                entry.sumup = def.node.SumUp.innerData;

            addEntry(entry);
        }
    }

    private function onLoadComplete(event: Event): Void
    {
        parseContent(XmlLoader.getXml(event));
    }

    private function new()
    {
        entries = new Array<Entry>();
    }

    private function contains(list: Iterable<String>, value: String): Bool
    {
        for(item in list){
            if(item == value)
                return true;
        }
        return false;
    }

    private function applyFilter(filters: FastList<String>, entries: Iterable<Entry>): Array<Entry>
    {
        var result = new Array<Entry>();
        var ereg = new EReg(filters.pop(), "");
        for(entry in entries){
            if(ereg.match(entry.author.toLowerCase()) || ereg.match(entry.title.toLowerCase()) || ereg.match(entry.editor.toLowerCase()))
                result.push(entry);
            else{
                for(program in entry.programs){
                    if(ereg.match(program.toLowerCase())){
                        result.push(entry);
                        break;
                    }
                }
                for(theme in entry.themes){
                    if(ereg.match(theme.toLowerCase())){
                        result.push(entry);
                        break;
                    }
                }
            }
        }
        if(!filters.isEmpty())
            return applyFilter(filters, result);
        else
            return result;
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