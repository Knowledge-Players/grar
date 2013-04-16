package com.knowledgeplayers.grar.display.activity;

import nme.events.MouseEvent;
import com.knowledgeplayers.grar.util.DisplayUtils;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

/**
* Abstract display for an activity
*/
class ActivityDisplay extends KpDisplay {
	/**
    * Model to display
    */
	public var model(default, setModel):Activity;

	/**
    * Setter for the model
    * @param model : the model to set
    * @return the model
    */

	public function setModel(model:Activity):Activity
	{
		this.model = model;
		this.model.addEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
		this.model.loadActivity();

		return model;
	}

	/**
    * Start the activity
    */

	public function startActivity():Void
	{
		model.startActivity();
		displayActivity();
	}

	/**
    * End the activity
    **/

	public function endActivity():Void
	{
		model.endActivity();
		unLoad();
	}

	/**
    * Show the debrief of this activity
    **/

	public function showDebrief():Void
	{
		Lib.trace("Debrief!");
	}

	// Private

	private function displayActivity():Void
	{
		if(model.background != null){
			var bkg = displaysFast.get(model.background);
			var width:Float = bkg.has.width ? Std.parseFloat(bkg.att.width) : null;
			var height:Float = bkg.has.height ? Std.parseFloat(bkg.att.height) : null;
			var alpha:Float = bkg.has.alpha ? Std.parseFloat(bkg.att.alpha) : null;
			var x:Float = bkg.has.x ? Std.parseFloat(bkg.att.x) : null;
			var y:Float = bkg.has.y ? Std.parseFloat(bkg.att.y) : null;
			DisplayUtils.setBackground(bkg.att.src, this, width, height, alpha, x, y);
		}
	}

	private function unLoad(keepLayer:Int = 0):Void
	{
		while(numChildren > keepLayer)
			removeChildAt(numChildren - 1);
	}

	private function new()
	{
		super();
	}

	// Handlers

	private function onUnload(ev:Event):Void
	{
		// Override in subclass
	}

	private function onModelComplete(e:LocaleEvent):Void
	{
		model.removeEventListener(LocaleEvent.LOCALE_LOADED, onModelComplete);
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function onValidate(e:MouseEvent):Void
	{
		// Override in subclass
	}
}