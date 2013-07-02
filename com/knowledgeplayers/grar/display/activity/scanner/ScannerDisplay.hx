package com.knowledgeplayers.grar.display.activity.scanner;

import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.display.activity.scanner.PointDisplay.PointStyle;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.event.ButtonActionEvent;

import com.knowledgeplayers.grar.structure.activity.scanner.Scanner;
import haxe.xml.Fast;

class ScannerDisplay extends ActivityDisplay {

	/**
* Instance
**/
	public static var instance (get_instance, null):ScannerDisplay;

	private var pointStyles:Map<String, PointStyle>;
	private var lineHeight:Float;
    private var btNext:DefaultButton;
    private var elementsArray:Array<PointDisplay>;

	/**
* @return the instance
**/

	public static function get_instance():ScannerDisplay
	{
		if(instance == null)
			instance = new ScannerDisplay();
		return instance;
	}

	public function setText(textId:String, content:String):Void
	{
		cast(displays.get(textId), ScrollPanel).setContent(content);
		addChild(displays.get(textId));


	}

	// Private

	override public function set_model(model:Activity):Activity
	{
        var model = super.set_model(model);


		for(point in cast(model, Scanner).elements){
			var pointDisplay = new PointDisplay(pointStyles.get(point.ref), point);
			pointDisplay.x = point.x;
			pointDisplay.y = point.y;
			pointDisplay.alpha = cast(model, Scanner).pointVisible ? 1 : 0;
			addChild(pointDisplay);
            elementsArray.push(pointDisplay);
		}

        displays.get("next").visible = false;

		return model;
	}

    public function checkElement():Void{

        var nb:Int = 0;

        for(elem in cast(model, Scanner).elements){
            if (elem.viewed)nb++;

        }
        if (nb==cast(model, Scanner).elements.length)allPointsView();
    }

    public function allPointsView():Void{

        displays.get("next").visible = true;
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
		pointStyles = new Map<String, PointStyle>();
        elementsArray = new Array<PointDisplay>();
	}

    override private function setButtonAction(button:DefaultButton, action:String):Void
    {
        if(action.toLowerCase() == ButtonActionEvent.NEXT){
            btNext = button;
            btNext.buttonAction = endActivity;
        }
    }
}