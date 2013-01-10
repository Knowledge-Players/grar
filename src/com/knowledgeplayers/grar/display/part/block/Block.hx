package com.knowledgeplayers.grar.structure.part.block;

import haxe.xml.Fast;
import nme.Lib;

// A voir un peu d'optimisation

class Block 
{
	inline static var RELATIVE: String = "relative";
	inline static var ABSOLUTE: String = "absolute";
	inline static var RECALC: String = "recalc";
	
	inline static var LEFT_BORDER: String = "left_border";
	inline static var RIGHT_BORDER: String = "right_border";
	inline static var TOP_BORDER: String = "top_border";
	inline static var BOTTOM_BORDER: String = "bottom_border";
	
	inline static var ROUND_UPLEFT: String = "upleft";
	inline static var ROUND_UPRIGHT: String = "upright";
	inline static var ROUND_DOWNLEFT: String = "downleft";
	inline static var ROUND_DOWNRIGHT: String = "downright";
	
	
	public var id (default, default): String = "";
	public var visible (default, default): Bool = true;
	public var colsNumber (default, default): Int = 0;
	public var rowsNumber (default, default): Int = 0;
	public var bgColor (default, default): Int;
	public var width (default, default): Float;
	public var absolute_width (default, default): Int;
	public var absolute_height (default, default): Int;
	public var height (default, default): Float;
	public var wPosition (default, default): String = Block.RELATIVE;
	public var hPosition (default, default): String = Block.RELATIVE;
	public var delay (default, default): Int = 0;
	public var x (default, default): Int;
	public var y (default, default): Int;
	public var animation (default, default): String;

	public var blocks (default, default): Array<Block>;
	public var sprites (default, default): Array<Sprite>;
	public var borders (default, default): Hash<Int>;
	public var rounded (default, default): Array<String>;
	
	private var items: Array<Item>;
	private var itemIndex: Int = 0;

	public function new(xml: Fast = null, width: String = "100%", height: String = "100%")
	{
		if(StringTools.endsWith(width, "%")){
			wPosition = Block.RELATIVE;
			width = width.substr(0, width.length-1);
			this.width = Std.parseInt(width)/100;
		}
		else if(width == "*") {
			wPosition = Block.RECALC;
			this.width = -1;
		}
		else{
			wPosition = Block.ABSOLUTE;
			this.width = Std.parseInt(width);
		}

		if(StringTools.endsWith(height, "%")){
			hPosition = Block.RELATIVE;
			height = height.substr(0, height.length-1);
			this.height = Std.parseInt(height)/100;
		}
		else if(height == "*"){
			hPosition = Block.RECALC;
			this.height = -1;
		}
		else{
			hPosition = Block.ABSOLUTE;
			this.height = Std.parseInt(height);
		}

		if(xml != null){
			// X position
			if(xml.has.X) x = Std.parseInt(xml.att.X);
			// Y position
			if(xml.has.Y) y = Std.parseInt(xml.att.Y);
			// Animation type
			if(xml.has.Animation) animation = xml.att.Animation;
			// Background color
			if(xml.has.BgColor) {
				bgColor = Std.parseInt("0x" + xml.att.BgColor.substr(1));
			} else {
				bgColor = 0xFFFFFF;
			}
			// ID
			if(xml.has.Id) id = xml.att.Id;
			// Visible
			if(xml.has.visible) {
					visible = xml.att.visible == "true";
			}
			// Rounded corner
			if(xml.has.Round) {
				rounded = xml.att.Round.split(",");
			}
			// Columns
			if(xml.has.Columns) {
				var sizes: Array<String> = xml.att.Columns.split(",");
				colsNumber = sizes.length;
				blocks = new Array<Block>();
				var widthIndex: Int = 0;
				for(col in xml.nodes.Column) {
					blocks.push(new Block(col, sizes[widthIndex], "100%"));
					widthIndex++;
				}
			}
			// or Rows 
			else if(xml.has.Rows) {
				var sizes: Array<String> = xml.att.Rows.split(",");
				rowsNumber = sizes.length;
				blocks = new Array<Block>();
				var heightIndex: Int = 0;
				for(row in xml.nodes.Row) {
					blocks.push(new Block(row, "100%", sizes[heightIndex]));
					heightIndex++;
				}
			}
			// Borders
			if(xml.has.Border) {
				borders = new Hash<Int>();
				var bordersStrings: Array<String> = xml.att.Border.split(" ");
				var topIndex: Int = 0;
				var bottomIndex: Int = 0;
				var rightIndex: Int = 0;
				var leftIndex: Int = 0;

				if(bordersStrings.length == 2){
					topIndex = bottomIndex = 0;
					rightIndex = leftIndex = 1;
				}
				else if(bordersStrings.length == 4){
					topIndex = 0;
					rightIndex = 1;
					bottomIndex = 2;
					leftIndex = 3;
				}

				borders.set(TOP_BORDER, Std.parseInt(bordersStrings[topIndex]));
				borders.set(BOTTOM_BORDER, Std.parseInt(bordersStrings[bottomIndex]));
				borders.set(RIGHT_BORDER, Std.parseInt(bordersStrings[rightIndex]));
				borders.set(LEFT_BORDER, Std.parseInt(bordersStrings[leftIndex]));
			}
			// Delay of apparition
			if(xml.has.delay) delay = Std.parseInt(xml.att.delay);
			// Items
			if(xml.hasNode.Item){
				items = new Array<Item>();
				for (item in xml.nodes.Item) {
					items.push(new Item(item));
				}
			}
			// Sprite
			if(xml.hasNode.Sprite){
				sprites = new Array<Sprite>();
				for(sprite in xml.nodes.Sprite){
					sprites.push(new Sprite(sprite));
				}
			}
		}
	}

	public function getNbItem() : Int
	{
		var nbItem: Int = 0;
		if(blocks != null){
			for(block in blocks){
				nbItem += block.getNbItem();
			}
		}
		nbItem += (items == null ? 0 : items.length);
		return nbItem;
	}

	public function getNbSprite() : Int
	{
		var nbSprite: Int = 0;
		if(blocks != null){
			for(block in blocks){
				nbSprite += block.getNbSprite();
			}
		}
		nbSprite += (sprites == null ? 0 : sprites.length);
		return nbSprite;
	}

	public function toString() : String
	{
		return "Block contains "+getNbItem()+" item"+(getNbItem()>1?"s":"")+" and "+getNbSprite()+" sprite"+(getNbSprite()>1?"s":"");
	}
}
