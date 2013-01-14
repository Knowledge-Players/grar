package com.knowledgeplayers.grar.display.activity.animagic;

import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.structure.activity.animagic.Animagic;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import nme.events.Event;
import nme.Lib;
import nme.display.DisplayObject;

/**
 * ...
 * @author kguilloteaux
 */
class AnimagicDisplay extends ActivityDisplay
{
	public static var instance (getInstance, null): AnimagicDisplay;
	private var displayObjects:Hash<DisplayObject>;
	private var resizeD:ResizeManager;
	private var animagic: Animagic;

	private function new() 
	{
		super();
		
		resizeD = ResizeManager.getInstance();

	}

	public static function getInstance() : AnimagicDisplay
	{
		if (instance == null)
			return instance = new AnimagicDisplay();
		else
			return instance;
	}
	override public function setModel(model: Activity) : Activity 
	{
		Lib.trace(model);
		animagic = cast(model, Animagic);
		animagic.addEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
		animagic.addEventListener(Event.COMPLETE, onEndActivity);
		this.model = animagic;
		animagic.loadActivity();
		
		return model;
	}

	override public function startActivity() : Void 
	{
		model.startActivity();
		
		addDisplayObjects();
		
	}

	private function addDisplayObjects(): Void{

	}

	private function onModelComplete(e:LocaleEvent):Void 
	{
		
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function onEndActivity(e:Event):Void 
	{
		model.endActivity();
		unLoad();
		animagic.removeEventListener(PartEvent.EXIT_PART, onEndActivity);
	}


}