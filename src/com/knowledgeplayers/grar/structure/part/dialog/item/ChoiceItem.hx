package com.knowledgeplayers.grar.structure.part.dialog.item;

import haxe.xml.Fast;

class ChoiceItem extends TextItem {
    public var tokenId (default, default): String;
    public var target (default, default): String;
    public var tokenType (default, default): String;

    /**
     * Constructor
     * @param	xml : fast xml node with structure infos
     * @param	tokenId : ID of the token
     * @param	target : Inventory to store the token (activity/global)
     * @param	tokenType : type of the token (info/physic)
     */

    public function new(?xml: Fast, ?tokenId: String, ?target: String, ?tokenType: String)
    {
        super(xml);
        if(xml.hasNode.Token){
            this.tokenId = xml.node.Token.att.id;
            this.target = xml.node.Token.att.target.toLowerCase();
            this.tokenType = xml.node.Token.att.type.toLowerCase();
        }
        else{
            this.tokenId = tokenId;
            this.target = target;
            this.tokenType = tokenType;
        }
    }

    /**
     * @return true if the item has a token
     */

    public function hasToken(): Bool
    {
        return tokenId != null;
    }

    override public function hasVerticalFlow(): Bool
    {
        return true;
    }
}