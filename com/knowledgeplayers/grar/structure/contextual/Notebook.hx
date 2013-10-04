package com.knowledgeplayers.grar.structure.contextual;

import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.structure.contextual.Note;
import haxe.ds.GenericStack;
import haxe.xml.Fast;
import com.knowledgeplayers.utils.assets.AssetsStorage;

class Notebook
{
	/**
	* Text of the close button
	**/
	public var closeButton (default, default):{ref: String, content: String};

	/**
	* Background ref
	**/
	public var background (default, default):String;

	/**
	* Path to the structure file
	**/
	public var file (default, default):String;

	/**
	* Items to display with the notebook
	**/
	public var items (default, default):GenericStack<String>;

	public var pages (default, null): Array<Page>;

	public function new(file:String)
	{
		items = new GenericStack<String>();
		pages = new Array<Page>();

		this.file = file;
		parseContent(AssetsStorage.getXml(file));
	}

	public inline function getAllNotes():Iterable<Note>
	{
		var notes = new Array<Note>();
		for(page in pages)
			notes = notes.concat(page.notes);
		return notes;
	}

	public function toString(): String
	{
		var output = "";
		for(page in pages)
			output += "Page "+page.tabContent+": "+page+"\n";
		return output;
	}

	// Privates

	private function parseContent(content:Xml):Void
	{
		var fast:Fast = new Fast(content).node.Notebook;
		background = fast.att.background;
		for(item in fast.nodes.Image)
			items.add(item.att.ref);
		for(page in fast.nodes.Page){
			var title = {ref: page.node.Title.att.ref, content: page.node.Title.att.content};
			var contentRef = page.node.Notes.att.ref;
			var titleRef = page.node.Notes.att.titleRef;
			var newPage:Page = {title: title, contentRef: contentRef, titleRef: titleRef, tabContent: page.att.tabContent, icon: page.att.icon, notes: new Array<Note>()};
			for(noteFast in page.node.Notes.nodes.Note){
				var note = new Note(noteFast);
				newPage.notes.push(note);
				GameManager.instance.inventory.set(note.ref, note);
			}
			pages.push(newPage);
		}
		closeButton = {ref: fast.node.Button.att.ref, content: fast.node.Button.att.content};
	}
}

typedef Page = {
	var title: {ref: String, content: String};
	var notes: Array<Note>;
	var contentRef: String;
	var titleRef: String;
	var tabContent: String;
	var icon: String;
}
