package com.knowledgeplayers.grar.display.activity;
import com.knowledgeplayers.grar.structure.activity.Activity;
import haxe.FastList;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;

/**
 * ...
 * @author jbrichardet
 */

class ActivityDisplay extends Sprite
{	
	public var model(default, setModel): Activity;
	
	private function new() 
	{
		super();
	}

	private function initDisplayObject(display: DisplayObject, node: Fast) : Void
	{
		display.x = Std.parseFloat(node.att.X);
		display.y = Std.parseFloat(node.att.Y);
		if (node.has.Width)
			display.width = Std.parseFloat(node.att.Width);
		else
			display.scaleX = Std.parseFloat(node.att.ScaleX);
		if(node.has.Height)
			display.height = Std.parseFloat(node.att.Height);
		else
			display.scaleY = Std.parseFloat(node.att.ScaleY);
	}
	
	public function setModel(model: Activity) : Activity 
	{
		return null;
	}	
	
	private function unLoad():Void 
	{
		while (numChildren > 0)
			removeChildAt(numChildren - 1);
	}
	
	public function setDisplay(display: Fast) : Void { }	
	
	public function startActivity() : Void {}
}
