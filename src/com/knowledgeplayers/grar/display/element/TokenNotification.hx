package com.knowledgeplayers.grar.display.element;

import haxe.Timer;
import nme.geom.Point;
import nme.display.Bitmap;
import nme.display.BitmapData;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import nme.Assets;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.factory.UiFactory;
import nme.display.Bitmap;
import nme.Lib;
import haxe.xml.Fast;
import aze.display.TileSprite;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import nme.display.Sprite;

/**
 * Graphic representation of a token of the game
 */
class TokenNotification extends Sprite {
	/**
    * Reference to the "in" transition for the notification
    **/
	public var showToken:String;

	/**
    * Reference to the "out" transition for the notification
    **/
	public var hideToken:String;

	/**
    * Max width for token image
    **/
	public var maxWidth (default, default):Float;

	/**
    * Position of the token image
    **/
	public var iconPosition (default, default):Point;

	/**
    * Text to display in the notification
    **/
	public var content (default, default):String;

	/**
    * Time (in millisecond) before the notification disappear
    **/
	public var duration (default, default):Int;

	private var layer:TileLayer;
	private var img:TileSprite;
	private var titleArea:ScrollPanel;
	private var tokenArea:ScrollPanel;

	public function new(fast:Fast):Void
	{
		super();

		var title:Fast = fast.node.Title;
		titleArea = new ScrollPanel(Std.parseFloat(title.att.width), Std.parseFloat(title.att.height), title.has.scrollable ? title.att.scrollable == "true" : true, title.has.stylesheet ? title.att.stylesheet : null);
		titleArea.x = Std.parseFloat(title.att.x);
		titleArea.y = Std.parseFloat(title.att.y);
		var tokenName:Fast = fast.node.TokenName;
		tokenArea = new ScrollPanel(Std.parseFloat(tokenName.att.width), Std.parseFloat(tokenName.att.height), tokenName.has.scrollable ? tokenName.att.scrollable == "true" : true, tokenName.has.stylesheet ? tokenName.att.stylesheet : null);
		tokenArea.x = Std.parseFloat(tokenName.att.x);
		tokenArea.y = Std.parseFloat(tokenName.att.y);

		this.x = Std.parseFloat(fast.att.x);
		this.y = Std.parseFloat(fast.att.y);
		layer = new TileLayer(UiFactory.tilesheet);
		img = new TileSprite(fast.att.id);
		img.scale = Std.parseFloat(fast.att.scale);
		showToken = fast.att.transitionIn;
		hideToken = fast.att.transitionOut;
		maxWidth = Std.parseFloat(fast.att.maxWidth);
		var coordinates:Array<String> = fast.att.iconPosition.split(";");
		iconPosition = new Point(Std.parseFloat(coordinates[0]), Std.parseFloat(coordinates[1]));
		content = fast.att.content;
		duration = Std.parseInt(fast.att.duration);

		layer.addChild(img);
		addChild(layer.view);
		layer.render();
		addChild(titleArea);
		addChild(tokenArea);
	}

	public function showNotification(tokenName:String):Void
	{
		var img = new Bitmap(GameManager.instance.tokensImages.get(tokenName).small);
		var scale = maxWidth / img.width;
		img.scaleX = img.scaleY = scale;
		img.x = iconPosition.x;
		img.y = iconPosition.y;
		addChild(img);
		titleArea.setContent(Localiser.instance.getItemContent(content));
		tokenArea.setContent(Localiser.instance.getItemContent(GameManager.instance.inventory.get(tokenName).name));
		TweenManager.applyTransition(this, showToken);
		Timer.delay(hideNotification, duration);
	}

	public function hideNotification():Void
	{
		TweenManager.applyTransition(this, hideToken);
	}
}