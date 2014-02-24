package grar.parser.contextual;

import grar.model.contextual.Notebook;
import grar.model.contextual.Note;
import grar.model.InventoryToken;
import grar.model.part.Item;

import haxe.ds.StringMap;
import haxe.ds.GenericStack;

import haxe.xml.Fast;

class XmlToNotebook {
	
	static public function parseModel(xml : Xml) : { n: Notebook, i: StringMap<InventoryToken> } {

		var f : Fast = new Fast(xml).node.Notebook;

		var background : String = f.att.background;
		var items : GenericStack<String> = new GenericStack<String>();
		var texts : GenericStack<Item> = new GenericStack<Item>();
		var pages : Array<Page> = new Array();
		var closeButton : { ref : String, content : String };

		var inventory : StringMap<InventoryToken> = new StringMap();

		for (item in f.nodes.Image) {

			items.add(item.att.ref);
		}
		for (txt in f.nodes.Text) {

			texts.add(XmlToItem.parse(txt.x));
		}
		// Reverse pile order to match XML order
		var tmpStack : GenericStack<String> = new GenericStack<String>();
		
		for (img in items) {

			tmpStack.add(img);
		}
		items = tmpStack;
		
		for (page in f.nodes.Page) {

			var title : {ref: String, content: String} = {ref: page.node.Title.att.ref, content: page.node.Title.att.content};
			var contentRef : String = page.node.Chapter.att.ref;
			var titleRef : String = page.node.Chapter.att.titleRef;
			var newPage : Page = {title: title, contentRef: contentRef, titleRef: titleRef, tabContent: page.att.tabContent, icon: page.att.icon, chapters: new Array<Chapter>()};
			
			for (chapter in page.nodes.Chapter) {

				var chap : Chapter = {notes: new Array(), titleRef: chapter.att.titleRef, icon: chapter.att.icon, name: chapter.att.name, subtitle: chapter.att.subtitle, ref: chapter.att.ref, isActivated: chapter.has.unlocked ? chapter.att.unlocked == "true" : false};
				
				for (nf in chapter.nodes.Note) {

					var note : Note = XmlToInventory.parseNoteToken(nf.x);
					
					chap.notes.push(note);

					inventory.set(note.name, note);
				}
				newPage.chapters.push(chap);
			}
			pages.push(newPage);
		}
		closeButton = {ref: f.node.Button.att.ref, content: f.node.Button.att.content};

		return { n: new Notebook(background, items, texts, pages, closeButton), i: inventory };
	}
}