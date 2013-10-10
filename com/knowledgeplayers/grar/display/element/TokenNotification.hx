package com.knowledgeplayers.grar.display.element;

import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import haxe.Timer;
import haxe.xml.Fast;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;

/**
 * Graphic representation of a token of the game
 */
// TODO extends WidgetContainer
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
		titleArea = new ScrollPanel(title);
		var tokenName:Fast = fast.node.TokenName;
		tokenArea = new ScrollPanel(tokenName);

		this.x = Std.parseFloat(fast.att.x);
		this.y = Std.parseFloat(fast.att.y);
		layer = new TileLayer(UiFactory.tilesheet);
		img = new TileSprite(layer, fast.att.id);
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