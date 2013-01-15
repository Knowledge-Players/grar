package com.knowledgeplayers.grar.display;

import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

/**
 * Manager of resize events
 */

class ResizeManager extends Sprite
{
	/**
	 * Instance of the manaager
	 */
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
	
	/**
	 * @return the instance of the manager
	 */
	public static function getInstance() : ResizeManager
	{
		if (instance == null)
			return instance = new ResizeManager();
		else
			return instance;
	}
	
	/**
	 * Listener of resize events
	 * @param	e : the event
	 */
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
	
	/**
	 * Add a display object to be managed
	 * @param	dp : object to manage
	 * @param	node : fast xml node with infos
	 */
	public function addDisplayObjects(dp: DisplayObject, ?node: Fast) : Void
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