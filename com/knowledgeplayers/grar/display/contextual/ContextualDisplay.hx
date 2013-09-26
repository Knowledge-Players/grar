package com.knowledgeplayers.grar.display.contextual;

interface ContextualDisplay{
	public var layout (default, default):String;
}

enum ContextualType {
	MENU;
	NOTEBOOK;
	GLOSSARY;
	BIBLIOGRAPHY;
	INVENTORY;
}
