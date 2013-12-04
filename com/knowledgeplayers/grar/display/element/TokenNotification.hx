package com.knowledgeplayers.grar.display.element;

import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.localisation.Localiser;
import haxe.Timer;
import haxe.xml.Fast;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;

/**
 * Graphic representation of a token of the game
 */
class TokenNotification extends WidgetContainer {

	/**
    * Max width for token image
    **/
	public var maxWidth (default, default):Float;

	/**
    * Position of the token image
    **/
	public var iconPosition (default, default):Point;

	/**
    * Time (in millisecond) before the notification disappear
    **/
	public var duration (default, default):Int;

	private var img:TileSprite;
	private var titleArea:ScrollPanel;
	private var tokenArea:ScrollPanel;

	public function new(fast:Fast):Void
	{
		super(fast);

		// TODO Clean model and use Widget properties
		tokenArea = new ScrollPanel(fast.node.TokenName);

		img = new TileSprite(layer, fast.att.id);
		img.scale = Std.parseFloat(fast.att.scale);
		maxWidth = Std.parseFloat(fast.att.maxWidth);
		var coordinates:Array<String> = fast.att.iconPosition.split(";");
		iconPosition = new Point(Std.parseFloat(coordinates[0]), Std.parseFloat(coordinates[1]));
		duration = Std.parseInt(fast.att.duration);

		layer.addChild(img);
		addChild(layer.view);
		layer.render();
		addChild(titleArea);
		addChild(tokenArea);
	}

	public function setToken(tokenName:String):Void
	{
		var img = new Bitmap(GameManager.instance.tokensImages.get(tokenName).small);
		var scale = maxWidth / img.width;
		img.scaleX = img.scaleY = scale;
		img.x = iconPosition.x;
		img.y = iconPosition.y;
		addChild(img);
		tokenArea.setContent(Localiser.instance.getItemContent(GameManager.instance.inventory.get(tokenName).name));
		Timer.delay(hideNotification, duration);
	}

	public function hideNotification():Void
	{
		parent.removeChild(this);
	}
}