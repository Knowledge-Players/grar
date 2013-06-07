package com.knowledgeplayers.grar.factory;

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
import String;

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

	public static function createButton(ref:String, x:Float = 0, y:Float = 0, states:Map<String, Map<String, {dpo:DisplayObject, z:Int, trans:String}>>, ?action:String, toggle: String = "false", ?transitionIn:String, ?transitionOut:String):DefaultButton
	{
		var creation:DefaultButton = new DefaultButton(states, action);

		creation.ref = ref;
		creation.transitionIn = transitionIn;
		creation.transitionOut = transitionOut;
		creation.x = x;
		creation.y = y;
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

		return createButton(xml.att.ref, x, y, states, action, xml.has.toggle?xml.att.toggle:"false", transitionIn, transitionOut);
	}

	private static function createStates(node:Fast):Map<String, {dpo:DisplayObject, z:Int, trans:String}>
	{
		var list = new Map<String, {dpo:DisplayObject, z:Int, trans:String}>();
		var zIndex = 0;
		var trans:String = "";
		for(elem in node.elements){
			switch (elem.name.toLowerCase()) {
				case "item":
					var layer = new TileLayer(tilesheet);
					layer.addChild(createImageFromXml(elem, layer));
					layer.render();

					if(elem.has.transform)
						trans = elem.att.transform;
					list.set(elem.att.ref, {dpo:layer.view, z:zIndex, trans:trans});

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

	public static function createImageFromXml(xml:Fast, layer:TileLayer):TileSprite
	{
		var image = new TileSprite(layer, xml.att.id);
		image.x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
		image.y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;
		image.scaleX = xml.has.scaleX ? Std.parseFloat(xml.att.scaleX) : 1;
		image.scaleY = xml.has.scaleY ? Std.parseFloat(xml.att.scaleY) : 1;
		if(xml.has.mirror)
			image.mirror = xml.att.mirror == "horizontal" ? 1 : 2;

		return image;
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

}