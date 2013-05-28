package com.knowledgeplayers.grar.util;

import com.knowledgeplayers.grar.display.TweenManager;
import Lambda;
import com.knowledgeplayers.grar.display.part.DialogDisplay;
import com.knowledgeplayers.grar.structure.part.dialog.DialogPart;
import com.knowledgeplayers.grar.display.GameManager;
import nme.events.KeyboardEvent;
import nme.Lib;
import nme.ui.Keyboard;

/**
 * Utility class to manage Keyboard inputs
 */
class KeyboardManager {
	/*public static var instance (get_instance, null):KeyboardManager;

	public static function get_instance():KeyboardManager
	{
		if(instance == null)
			instance = new KeyboardManager();
		return instance;
	}

	private function new()
	{
		init();
	}*/

	public static function init():Void
	{
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
	}

	// Handlers

	private static function keyDownHandler(e:KeyboardEvent):Void
	{
		switch(e.keyCode){
			case Keyboard.SPACE: if(GameManager.instance.activityDisplay != null){
				var activity = GameManager.instance.activityDisplay.model;
				activity.score = e.altKey ? 0 : 100;
				activity.endActivity();
			}
			case Keyboard.S: TweenManager.fastForwardDiscover();
			case Keyboard.RIGHT: if(GameManager.instance.parts != null && !GameManager.instance.parts.isEmpty() && !GameManager.instance.parts.first().introScreenOn){
				var part = GameManager.instance.parts.first();
				if(Std.is(part, DialogDisplay) && Lambda.count(cast(part, DialogDisplay).currentPattern.buttons) == 1){
					part.next(null);
				}
				else if(!Std.is(part, DialogDisplay))
					part.next(null);
			}
			case Keyboard.D: for(part in GameManager.instance.game.getAllParts()){
				GameManager.instance.finishPart(part.id);
			}
		}
	}

	private static function keyUpHandler(ev:KeyboardEvent):Void
	{

	}
}
