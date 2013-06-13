package com.knowledgeplayers.grar.factory;

import nme.geom.Matrix;
import nme.display.BitmapData;
import nme.filters.DropShadowFilter;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.display.FilterManager;
import nme.filters.BitmapFilter;
import nme.display.Bitmap;
import nme.display.Sprite;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.component.ScrollBar;
import com.knowledgeplayers.grar.display.element.AnimationDisplay;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
import nme.display.DisplayObject;
#if !flash
	import nme.Assets;
#end

/**
 * Factory to create UI components
 */

class UiFactory {

	/**
    * Tilesheet containing UI elements
    **/
	public static var tilesheet (default, null):TilesheetEx;
	private static var layerPath:String;

	private function new()
	{}

	/**
     * Create a button
     * @param	buttonType : Type of the button
     * @param	tile : Tile containing the button icon
     * @param	action : Event to dispatch when the button is clicked. No effects for DefaultButton type
     * @return the created button
     */

	public static function createButton(ref:String, x:Float = 0, y:Float = 0, rotation: Float = 0, states:Map<String, Map<String, {dpo:DisplayObject, z:Int, trans:String}>>, ?action:String, toggle: String = "false", ?transitionIn:String, ?transitionOut:String):DefaultButton
	{
		var creation:DefaultButton = new DefaultButton(states, action);

		creation.ref = ref;
		creation.transitionIn = transitionIn;
		creation.transitionOut = transitionOut;
		creation.x = x;
		creation.y = y;
		creation.rotation = rotation;
		if(toggle == "true") creation.enableToggle();

		return creation;
	}

	/**
     * Create a scrollbar
     * @param	width : Width of the scrollbar
     * @param	height : Height of the scrollbar
     * @param	ratio : Ratio of the cursor
     * @param	tileBackground : Tile containing background image
     * @param	tileCursor : Tile containing cursor image
     * @return the fresh new scrollbar
     */

	public static function createScrollBar(width:Float, height:Float, ratio:Float, tileBackground:String, tileCursor:String):ScrollBar
	{
		return new ScrollBar(width, height, ratio, tilesheet, tileBackground, tileCursor);
	}

	/**
     * Create a button from XML infos
     * @param	xml : fast xml node with infos
     * @return the button
     */

	public static function createButtonFromXml(xml:Fast):DefaultButton
	{

		var x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
		var y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;
		var rotation = xml.has.rotation ? Std.parseFloat(xml.att.rotation) : 0;
		var action = xml.has.action ? xml.att.action : null;

		var transitionIn = xml.has.transitionIn ? xml.att.transitionIn : null;
		var transitionOut = xml.has.transitionOut ? xml.att.transitionOut : null;

		var states = new Map<String, Map<String, {dpo:DisplayObject, z:Int, trans:String}>>();

		if(xml.hasNode.active){
			for(state in xml.node.active.elements){
				if(states.exists("active_out") || state.name == "out"){
					states.set("active_" + state.name, createStates(state));
				}
			}
		}
		if(xml.hasNode.inactive){
			for(state in xml.node.inactive.elements){
				if(states.exists("inactive_out") || state.name == "out"){
					states.set("inactive_" + state.name, createStates(state));
				}
			}
		}

		return createButton(xml.att.ref, x, y, rotation, states, action, xml.has.toggle?xml.att.toggle:"false", transitionIn, transitionOut);
	}

	private static function createStates(node:Fast):Map<String, {dpo:DisplayObject, z:Int, trans:String}>
	{
		var list = new Map<String, {dpo:DisplayObject, z:Int, trans:String}>();
		var zIndex = 0;
		var trans:String = "";
		for(elem in node.elements){
			switch (elem.name.toLowerCase()) {
				case "item":
					var layers = new Map<String, TileLayer>();
					layers.set("layer", new TileLayer(tilesheet));

					if(elem.has.transform)
						trans = elem.att.transform;
					list.set(elem.att.ref, {dpo:createImageFromXml(elem, layers), z:zIndex, trans:trans});

				case "text": list.set(elem.att.ref, {dpo:createTextFromXml(elem), z:zIndex, trans:trans});

				case "animation":list.set(elem.att.ref, {dpo:createAnimationFromXml(elem), z:zIndex, trans:trans});
			}
			zIndex++;
			trans = "";
		}
		return list;
	}

	/**
    * Create an animation from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a AnimationDisplay (sprite)
    **/

	public static function createAnimationFromXml(xml:Fast):AnimationDisplay
	{
		var x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
		var y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;
		var scaleX = xml.has.scaleX ? Std.parseFloat(xml.att.scaleX) : 1;
		var scaleY = xml.has.scaleY ? Std.parseFloat(xml.att.scaleY) : 1;
		var loop = xml.has.loop ? Std.parseFloat(xml.att.loop) : 0;
		var alpha = xml.has.alpha ? Std.parseFloat(xml.att.alpha) : 0;
		var mirror = xml.has.mirror ? xml.att.mirror : null;

		var animation:AnimationDisplay = new AnimationDisplay(xml.att.id, x, y, tilesheet, scaleX, scaleY, loop, alpha, mirror);

		return animation;

	}

	/**
    * Create a tilesprite from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a tilesprite
    **/

	public static function createImageFromXml(xml:Fast, layers:Map<String, TileLayer>, ?tilesheets: Map<String, TilesheetEx>, visible:Bool = true):DisplayObject
	{
		if(!xml.has.ref)
			throw "Items must have a ref attribute: "+xml;
		if(xml.has.src){
			var itemBmp:Bitmap = new Bitmap();
			#if flash
             itemBmp = new Bitmap(AssetsStorage.getBitmapData(xml.att.src));
            #else
			itemBmp = new Bitmap(Assets.getBitmapData(xml.att.src));
			#end
			if(xml.has.x)
				itemBmp.x = Std.parseFloat(xml.att.x);
			if(xml.has.y)
				itemBmp.y = Std.parseFloat(xml.att.y);
			if(xml.has.scale)
				itemBmp.scaleX = itemBmp.scaleY = Std.parseFloat(xml.att.scale);
			else{
				if(xml.has.scaleX)
					itemBmp.scaleX = Std.parseFloat(xml.att.scaleX);
				if(xml.has.scaleY)
					itemBmp.scaleY = Std.parseFloat(xml.att.scaleY);
			}
			if(xml.has.mirror){
				itemBmp.bitmapData = switch(xml.att.mirror.toLowerCase()){
					case "horizontal": flipBitmapData(itemBmp.bitmapData);
					case "vertical": flipBitmapData(itemBmp.bitmapData, "y");
					case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
				}
			}
			return itemBmp;
		}
		else if(xml.has.filters || xml.has.tween){
			var bmp = new Bitmap(DisplayUtils.getBitmapDataFromLayer(xml.has.spritesheet?tilesheets.get(xml.att.spritesheet):UiFactory.tilesheet, xml.att.id));
			if(xml.has.filters){
				var filters = new Array<BitmapFilter>();
				for(filter in xml.att.filters.split(","))
					filters.push(FilterManager.getFilter(filter));
				bmp.filters = filters;
			}
			if(xml.has.x)
				bmp.x = Std.parseFloat(xml.att.x);
			if(xml.has.y)
				bmp.y = Std.parseFloat(xml.att.y);
			if(xml.has.mirror){
				bmp.bitmapData = switch(xml.att.mirror.toLowerCase()){
					case "horizontal": flipBitmapData(bmp.bitmapData);
					case "vertical": flipBitmapData(bmp.bitmapData, "y");
					case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
				}
			}
			if(xml.has.scale || xml.has.scaleX || xml.has.scaleY){
				var scaleX: Float = 1;
				var scaleY: Float = 1;
				if(xml.has.scale)
					scaleX = scaleY = Std.parseFloat(xml.att.scale);
				else{
					if(xml.has.scaleX)
						scaleX = Std.parseFloat(xml.att.scaleX);
					if(xml.has.scaleY)
						scaleY = Std.parseFloat(xml.att.scaleY);
				}
				var matrix:Matrix = new Matrix();
				matrix.scale(scaleX, scaleY);
				var rescale:BitmapData = new BitmapData(Math.round(bmp.bitmapData.width * scaleX), Math.round(bmp.bitmapData.height * scaleY), true, 0x000000);
				rescale.draw(bmp.bitmapData, matrix, null, null, null, true);
				bmp.bitmapData = rescale;
			}
			return bmp;

		}
		else{
			var spritesheet;
			var itemTile;
			if(xml.has.spritesheet){
				spritesheet = xml.att.spritesheet;
			}
			else{
				spritesheet = "ui";
				if(!layers.exists(spritesheet)){
					var layer = new TileLayer(UiFactory.tilesheet);
					layers.set(spritesheet, layer);
				}
			}
			itemTile = new TileSprite(layers.get(spritesheet), xml.att.id);
			if(xml.has.x)
				itemTile.x = Std.parseFloat(xml.att.x);
			if(xml.has.y)
				itemTile.y = Std.parseFloat(xml.att.y);
			if(xml.has.scale)
				itemTile.scale = Std.parseFloat(xml.att.scale);
			if(xml.has.mirror){
				itemTile.mirror = switch(xml.att.mirror.toLowerCase()){
					case "horizontal": 1;
					case "vertical": 2;
					case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
				}
			}

			itemTile.visible = visible;
			layers.get(spritesheet).addChild(itemTile);
			layers.get(spritesheet).render();
			return layers.get(spritesheet).view;
		}
	}

	/**
    * Create a textfield from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a textfield
    **/

	public static function createTextFromXml(textNode:Fast, ?spritesheets:Map<String, TilesheetEx>):ScrollPanel
	{
		var background:String = textNode.has.background ? textNode.att.background : null;
		var spritesheet = null;
		if(background != null && background.indexOf(".") < 0 && textNode.has.spritesheet && spritesheets != null)
			spritesheet = spritesheets.get(textNode.att.spritesheet);

		var scrollable = textNode.has.scrollable ? textNode.att.scrollable == "true" : true;
		var styleSheet = textNode.has.style ? textNode.att.style : null;
		var text = new ScrollPanel(Std.parseFloat(textNode.att.width), Std.parseFloat(textNode.att.height), !scrollable, styleSheet);
		if(textNode.has.textTransition)
			text.textTransition = textNode.att.textTransition;
		if(background != null)
			text.setBackground(background, spritesheet, textNode.has.alpha ? Std.parseFloat(textNode.att.alpha) : 1);
		if(textNode.has.transitionIn)
			text.transitionIn = textNode.att.transitionIn;
		if(textNode.has.transitionOut)
			text.transitionOut = textNode.att.transitionOut;
		text.textAlpha = textNode.has.textAlpha ? Std.parseFloat(textNode.att.textAlpha) : 1;

		text.x = textNode.has.x ? Std.parseFloat(textNode.att.x) : 0;
		text.y = textNode.has.y ? Std.parseFloat(textNode.att.y) : 0;

		return text;
	}

	/**
    * Create a sprite from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a sprite
    **/

	public static function createSpriteFormXml(xml:Fast):Sprite
	{
		var background = new Sprite();

		var color:Int;

		var _alpha = xml.has.alpha ? Std.parseFloat(xml.att.alpha) : 1;

		if(xml.has.color)
			color = Std.parseInt(xml.att.color);
		else
			color = Std.parseInt("0xFFFFFF");
		background.graphics.beginFill(color, _alpha);
		background.graphics.drawRect(Std.parseFloat(xml.att.x), Std.parseFloat(xml.att.y), Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height));
		background.graphics.endFill();

		return background;
	}

	/**
     * Set the spritesheet file containing all the UI images
     * @param	id : ID of the Spritesheet in the assets
     */

	public static function setSpriteSheet(id:String):Void
	{
		tilesheet = AssetsStorage.getSpritesheet(id);
	}

	private static function flipBitmapData(original:BitmapData, axis:String = "x"):BitmapData
	{
		var flipped:BitmapData = new BitmapData(original.width, original.height, true, 0);
		var matrix:Matrix;
		if(axis == "x"){
			matrix = new Matrix( - 1, 0, 0, 1, original.width, 0);
		} else {
			matrix = new Matrix( 1, 0, 0, - 1, 0, original.height);
		}
			flipped.draw(original, matrix, null, null, null, true);
		return flipped;
	}


}