package grar.model.contextual;

import grar.model.Item;
import grar.model.Note;

import haxe.ds.GenericStack;

typedef Page = {

	var title: {ref: String, content: String};
	var chapters: Array<Chapter>;
	var contentRef: String;
	var titleRef: String;
	var tabContent: String;
	var icon: String;
}

typedef Chapter = {

	var notes: Array<Note>;
	var icon: String;
	var name: String;
	var subtitle: String;
	var isActivated: Bool;
	var titleRef: String;
	var ref: String;
}

class Notebook {

	public function new(b : String, i : GenericStack<String>, t : GenericStack<Item>, 
							p : Array<Page>, cb : {ref: String, content: String}) {

		this.background = b;
		this.items = i;
		this.texts = t;
		this.pages = p;
		this.closeButton = cb;
	}

	/**
	 * Text of the close button
	 **/
	public var closeButton (default, default) : { ref : String, content : String };

	/**
	 * Background ref
	 **/
	public var background (default, default) : String;

	/**
	 * Items to display with the notebook
	 **/
	public var items (default, default) : GenericStack<String>;
	public var texts (default, default) : GenericStack<Item>;

	public var pages (default, null) : Array<Page>;

	public inline function getAllNotes() : Array<Note> {

		var notes = new Array<Note>();
		
		for (page in pages) {

			for (chapter in page.chapters) {

				notes = notes.concat(chapter.notes);
			}
		}
		return notes;
	}

	public function toString() : String {

		var output : String = "";

		for (page in pages) {

			output += "Page "+page.tabContent+": "+page+"\n";
		}
		return output;
	}
}