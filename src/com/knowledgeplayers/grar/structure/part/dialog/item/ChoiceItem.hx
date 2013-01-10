package com.knowledgeplayers.grar.structure.part.dialog.item;

import haxe.xml.Fast;

class ChoiceItem extends Item
{
	public var tokenId (default, default): String;
	public var target (default, default): String;
	public var tokenType (default, default): String;

	public function new(?xml: Fast, ?tokenId: String, ?target: String, ?tokenType: String)
	{
		super(xml);
		if (xml.hasNode.Token){
			this.tokenId = xml.node.Token.att.Id;
			this.target = xml.node.Token.att.Target.toLowerCase();
			this.tokenType = xml.node.Token.att.Type.toLowerCase();
		}	
		else{
			this.tokenId = tokenId;
			this.target = target;
			this.tokenType = tokenType;
		}
	}
	
	public function hasToken() : Bool
	{
		return tokenId != null;
	}
	
	override public function hasVerticalFlow() : Bool
	{
		return true;
	}
}