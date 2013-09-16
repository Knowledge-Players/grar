package com.knowledgeplayers.grar.structure.contextual;

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
		for(note in fast.node.Notes.nodes.Note){
			notes.push({id: note.att.id, title: note.att.title, subtitle: note.has.subtitle?note.att.subtitle:null, content: note.att.content, unlocked: note.att.unlocked == "true", icon: note.has.icon?note.att.icon:null});
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

typedef Note = {
	var id: String;
	var title: String;
	var content: String;
	var unlocked: Bool;
	@:optionnal var subtitle: String;
	@:optionnal var icon: String;
}
