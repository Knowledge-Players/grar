package com.knowledgeplayers.grar.display;

import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.geom.Point;
import nme.Lib;
import nme.events.Event;
import com.knowledgeplayers.grar.display.button.DefaultButton;

/**
 * ...
 * @author kguilloteaux
 */

class ResizeManager extends Sprite
{
	static var instance (getInstance, null): ResizeManager;
	
	private var resizedObjects:List<Dynamic>;
	private var replacedObjects:List<Dynamic>;

	private var originW:Int=0;
	private var originH:Int = 0;
	private var ratioW:Float = 0;
	private var ratioH:Float = 0;
	
	private function new() 
	{
		super();
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
		originW = Lib.current.stage.stageWidth;
		originH = Lib.current.stage.stageHeight;
		resizedObjects = new List<Dynamic>();
		replacedObjects = new List<Dynamic>();
	}
	
	public static function getInstance() : ResizeManager
	{
		if (instance == null)
			return instance = new ResizeManager();
		else
			return instance;
	}
	
	public function onResize(?e: Event) : Void
	{		
		ratioW =  Lib.current.stage.stageWidth/originW;
		ratioH =   Lib.current.stage.stageHeight/originH;

		for (obj in resizedObjects){
			obj.dp.scaleX = ratioW;
			obj.dp.scaleY = ratioH;	

			obj.dp.x = ratioW * obj.originX;
			obj.dp.y = ratioH * obj.originY;
		}
		for (obj in replacedObjects) {
			obj.dp.x = ratioW * obj.originX;
			obj.dp.y = ratioH * obj.originY;
		}	
	}
	
	public function addDisplayObjects(dp: DisplayObject, ?node:Fast) : Void
	{		
		var obj:Dynamic={};
		obj.dp = dp;
		obj.originW = dp.width;
		obj.originH = dp.height;
		obj.originX = dp.x;
		obj.originY = dp.y;

		if (!node.has.resize) {
			resizedObjects.add(obj);
		}
		else if (node.att.resize == "true" || node.att.resize == ""){
			resizedObjects.add(obj);
		}
		else{
			replacedObjects.add(obj);
		}
	}
}