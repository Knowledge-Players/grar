package com.knowledgeplayers.grar.display.element;

import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.localisation.Localiser;
import haxe.Timer;
import haxe.xml.Fast;

/**
 * Graphic representation of a token of the game
 */
class TokenNotification extends WidgetContainer {

	/**
    * Time (in millisecond) before the notification disappear
    **/
	public var duration (default, default):Int;

	public function new(fast:Fast):Void
	{
		super(fast);
		duration = Std.parseInt(fast.att.duration);
	}

	public function setToken(tokenName:String):Void
	{
		if(displays.exists("icon"))
			cast(displays.get("icon"), Image).setBmp(GameManager.instance.inventory.get(tokenName).icon);
		cast(displays.get("name"), ScrollPanel).setContent(Localiser.instance.getItemContent(GameManager.instance.inventory.get(tokenName).name));
		cast(displays.get("title"), ScrollPanel).setContent(Localiser.instance.getItemContent("unlock"));
		Timer.delay(hideNotification, duration);
	}

	public function hideNotification():Void
	{
		TweenManager.applyTransition(this, transitionOut).onComplete(function(){
			parent.removeChild(this);
		});
	}
}