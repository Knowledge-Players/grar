package com.knowledgeplayers.grar.display.activity.scanner;

import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.display.activity.scanner.PointDisplay.PointStyle;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;

import com.knowledgeplayers.grar.structure.activity.scanner.Scanner;
import haxe.xml.Fast;

class ScannerDisplay extends ActivityDisplay {

	/**
* Instance
**/
	public static var instance (getInstance, null):ScannerDisplay;

	private var pointStyles:Hash<PointStyle>;
	private var lineHeight:Float;

	/**
* @return the instance
**/

	public static function getInstance():ScannerDisplay
	{
		if(instance == null)
			instance = new ScannerDisplay();
		return instance;
	}

	public function setText(textId:String, content:String):Void
	{
		cast(displays.get(textId).obj, ScrollPanel).setContent(content);
		addChild(displays.get(textId).obj);
	}

	// Private

	override public function setModel(model:Activity):Activity
	{
		for(point in cast(model, Scanner).pointsMap){
			var pointDisplay = new PointDisplay(pointStyles.get(point.ref), point);
			pointDisplay.x = point.x;
			pointDisplay.y = point.y;
			pointDisplay.alpha = cast(model, Scanner).pointVisible ? 1 : 0;
			addChild(pointDisplay);
		}
		return super.setModel(model);
	}

	override private function createElement(elemNode:Fast):Void
	{
		super.createElement(elemNode);
		if(elemNode.name.toLowerCase() == "point"){
			if(!pointStyles.exists(elemNode.att.ref)){
				pointStyles.set(elemNode.att.ref, new PointStyle());
			}
			if(elemNode.has.radius)
				pointStyles.get(elemNode.att.ref).radius = Std.parseInt(elemNode.att.radius);
			pointStyles.get(elemNode.att.ref).addGraphic(elemNode.att.state, elemNode.att.src);
		}
	}

	private function new()
	{
		super();
		pointStyles = new Hash<PointStyle>();
	}
}