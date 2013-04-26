package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.utils.assets.AssetsStorage;
import nme.Assets;
import com.knowledgeplayers.grar.display.FilterManager;
import nme.media.Sound;
import nme.net.URLRequest;
import nme.media.SoundChannel;
import nme.media.SoundTransform;
import com.knowledgeplayers.grar.display.element.AnimationDisplay;
import com.knowledgeplayers.grar.display.GameManager;
import nme.filters.DropShadowFilter;
import nme.Lib;
import nme.filters.BitmapFilter;
import nme.geom.Point;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import nme.events.EventDispatcher;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import aze.display.TileSprite;
import aze.display.SparrowTilesheet;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.button.AnimationButton;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.display.component.button.MenuButton;
import com.knowledgeplayers.grar.display.component.ScrollBar;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.events.Event;
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

	public static function createButton(buttonType:String, ref:String, tile:String, x:Float = 0, y:Float = 0, scale:Float = 1, ?action:String, ?iconStatus:String, ?mirror:String, ?style:String, ?className:String, ?animations:Hash<AnimationDisplay>, ?width:Float, ?transitionIn:String, ?transitionOut:String):DefaultButton
	{
		var creation:DefaultButton =
		switch(buttonType.toLowerCase()) {
			case "text": new TextButton(tilesheet, tile, action, style, animations);
			case "event": new CustomEventButton(tilesheet, tile, action, animations);
			case "anim": new AnimationButton(tilesheet, tile, action);
			case "menu": new MenuButton(tilesheet, tile, action, iconStatus, width);
			default: new DefaultButton(tilesheet, tile);
		}
		creation.ref = ref;
		creation.transitionIn = transitionIn;
		creation.transitionOut = transitionOut;
		creation.x = x;
		creation.y = y;
		creation.scale = scale;
		creation.className = className != null ? className : "text";
		if(mirror == "horizontal")
			creation.mirror = 1;
		if(mirror == "vertical")
			creation.mirror = 2;

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
		var animations:Hash<AnimationDisplay> = null;

		var x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
		var y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;
		var scale = xml.has.scale ? Std.parseFloat(xml.att.scale) : 1;
		var action = xml.has.action ? xml.att.action : null;
		var iconStatus = xml.has.status ? xml.att.status : null;
		var mirror = xml.has.mirror ? xml.att.mirror : null;
		var style = xml.has.style ? xml.att.style : null;
		var className = xml.has.className ? xml.att.className : null;
		var width = xml.has.width ? Std.parseFloat(xml.att.width) : 100;
		var transitionIn = xml.has.transitionIn ? xml.att.transitionIn : null;
		var transitionOut = xml.has.transitionOut ? xml.att.transitionOut : null;

		if(xml.hasNode.Animation){

			animations = new Hash<AnimationDisplay>();
			for(node in xml.elements){
				animations.set(node.att.type, createAnimationFromXml(node));
			}
		}
		return createButton(xml.att.type, xml.att.ref, xml.att.id, x, y, scale, action, iconStatus, mirror, style, className, animations, width, transitionIn, transitionOut);
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

		var animation:AnimationDisplay = new AnimationDisplay(xml.att.id, x, y, tilesheet, scaleX, scaleY, xml.att.type, loop, alpha, mirror);

		return animation;

	}

	/**
    * Create a tilesprite from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a tilesprite
    **/

	public static function createImageFromXml(xml:Fast):TileSprite
	{
		var image = new TileSprite(xml.att.id);
		image.x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
		image.y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;
		image.scaleX = xml.has.scaleX ? Std.parseFloat(xml.att.scaleX) : 1;
		image.scaleY = xml.has.scaleY ? Std.parseFloat(xml.att.scaleY) : 1;

		return image;
	}

	/**
    * Create a textfield from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a textfield
    **/

	public static function createTextFromXml(xml:Fast):ScrollPanel
	{
		var text = new ScrollPanel(Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height));
		text.x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
		text.y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;

		if(xml.has.background)
			text.setBackground(xml.att.background);
		return text;
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