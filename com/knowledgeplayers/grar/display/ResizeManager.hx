package com.knowledgeplayers.grar.display;

import haxe.xml.Fast;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.Lib;

/**
 * Manager of resize events
 */
class ResizeManager {
	/**
     * Instance of the manaager
     */
	public static var instance (get_instance, null):ResizeManager;

	private var resizedObjects:List<Resizable>;
	private var replacedObjects:List<Resizable>;

	private var originW:Int = 0;
	private var originH:Int = 0;
	private var ratioW:Float = 0;
	private var ratioH:Float = 0;

	private function new()
	{
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
		originW = Lib.current.stage.stageWidth;
		originH = Lib.current.stage.stageHeight;
		resizedObjects = new List<Resizable>();
		replacedObjects = new List<Resizable>();
	}

	/**
     * @return the instance of the manager
     */

	public static function get_instance():ResizeManager
	{
		if(instance == null)
			return instance = new ResizeManager();
		else
			return instance;
	}

	/**
     * Listener of resize events
     * @param	e : the event
     */

	public function onResize(?e:Event):Void
	{
		ratioW = Lib.current.stage.stageWidth / originW;
		ratioH = Lib.current.stage.stageHeight / originH;

		for(obj in resizedObjects){
			obj.display.scaleX *= ratioW;
			obj.display.scaleY *= ratioH;

			obj.display.x = ratioW * obj.originalX;
			obj.display.y = ratioH * obj.originalY;
		}
		for(obj in replacedObjects){
			obj.display.x = ratioW * obj.originalX;
			obj.display.y = ratioH * obj.originalY;
		}
	}

	/**
     * Add a display object to be managed
     * @param	dp : object to manage
     * @param	node : fast xml node with infos
     */

	public function addDisplayObjects(dp:DisplayObject, ?node:Fast):Void
	{
		var obj:Resizable = {display: dp, originalWidth: dp.width, originalHeight: dp.height, originalX: dp.x, originalY: dp.y};

		if(!node.has.resize){
			resizedObjects.add(obj);
		}
		else if(node.att.resize == "true" || node.att.resize == ""){
			resizedObjects.add(obj);
		}
		else{
			replacedObjects.add(obj);
		}
	}
}

typedef Resizable = {
	var display: DisplayObject;
	var originalWidth: Float;
	var originalHeight: Float;
	var originalX: Float;
	var originalY: Float;
}