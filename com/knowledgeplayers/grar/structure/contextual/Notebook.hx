package com.knowledgeplayers.grar.structure.contextual;

import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.structure.contextual.Note;
import haxe.ds.GenericStack;
import haxe.xml.Fast;
import com.knowledgeplayers.utils.assets.AssetsStorage;

class Notebook
{
	/**
	* Notes in the notebook
	**/
	public var notes (default, default):Array<Note>;

	/**
	* Title of the notebook
	**/
	public var title (default, default):{ref: String, content: String};

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
	* Ref to the text area where content will be displayed
	**/
	public var contentRef (default, default):String;

	/**
	* Ref to the text area where title will be displayed
	**/
	public var titleRef (default, default):String;

	/**
	* Items to display with the notebook
	**/
	public var items (default, default):GenericStack<String>;

	public function new(file:String)
	{
		notes = new Array<Note>();
		items = new GenericStack<String>();

		this.file = file;
		parseContent(AssetsStorage.getXml(file));
	}

	private function parseContent(content:Xml):Void
	{
		var fast:Fast = new Fast(content).node.Notebook;
		background = fast.att.background;
		title = {ref: fast.node.Title.att.ref, content: fast.node.Title.att.content};
		contentRef = fast.node.Notes.att.ref;
		titleRef = fast.node.Notes.att.titleRef;
		for(noteFast in fast.node.Notes.nodes.Note){
			var note = new Note(noteFast);
			notes.push(note);
			GameManager.instance.inventory.set(note.ref, note);
		}
		for(item in fast.nodes.Image)
			items.add(item.att.ref);
		closeButton = {ref: fast.node.Button.att.ref, content: fast.node.Button.att.content};
	}

	public function toString(): String
	{
		return '$title.content: $notes';
	}
}
