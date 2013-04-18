package com.knowledgeplayers.grar.display.component.button;

import com.knowledgeplayers.grar.display.part.MenuDisplay;
import nme.events.MouseEvent;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import nme.Lib;
import aze.display.TileSprite;
import aze.display.TileClip;
import aze.display.TileLayer;
import nme.display.Sprite;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;

class MenuButton extends TextButton {

	private var hitBox:Sprite;
	private var status:TileClip;
	private var layerStatus:TileLayer;
	public var menuD:MenuDisplay;

	public function new(tilesheet:TilesheetEx, tile:String, eventName:String, ?_status:String, ?width:Float)
	{
		super(tilesheet, tile, eventName);
		//layer.view.visible = false;

		hitBox = setHitBox(width, 10);
		hitBox.alpha = 0;
		if(_status != ""){
			layerStatus = new TileLayer(tilesheet);
			addChild(layerStatus.view);
			status = getStatus(_status);
			layerStatus.addChild(status);
			status.currentFrame = 0;
			layerStatus.render();
		}

	}

	private function setHitBox(_w:Float, _h:Float):Sprite
	{

		var _hitBox = new Sprite();

		_hitBox.graphics.beginFill(0xFFFFFF, 1);
		_hitBox.graphics.drawRect(0, 0, _w, _h);
		_hitBox.graphics.endFill();

		addChild(_hitBox);

		return _hitBox;
	}

	public function setStatus(num:Int):Void
	{

		status.currentFrame = num;
		layerStatus.render();
	}

	private function getStatus(_id:String):TileClip
	{
		var _stat = new TileClip(_id);

		return _stat;
	}

	override public function setText(_text:String):Void
	{

		super.setText(_text);

		textSprite.mouseEnabled = false;
	}

	override private function onMouseOver(event:MouseEvent):Void
	{
		hitBox.alpha = 1;
	}

	override private function onMouseOut(event:MouseEvent):Void
	{
		hitBox.alpha = 0;
	}

	override private function onClick(e:MouseEvent):Void
	{

		var target = cast(e.target, DefaultButton);
		if(GameManager.instance.game.getAllParts() != null){
			for(part in GameManager.instance.game.getAllParts()){
				if(part.name == target.name){
					GameManager.instance.displayPart(part);
					break;
				}
			}
		}
		if(GameManager.instance.game.getAllItems() != null){
			for(activity in GameManager.instance.game.getAllItems()){
				/* if(activity.name == target.name){
                    GameManager.instance.displayActivity(activity);
                    break;
                }
                */
			}
		}

		TweenManager.applyTransition(menuD, transitionOut);
	}
	/**
*  Align all elements of the Menu Button
**/

	public function alignElements():Void
	{

		hitBox.height = textSprite.height;
		var hWidth:Float = 0;
		if(status != null){
			textSprite.x = status.width;
			status.y = textSprite.y + (textSprite.height / 2) + status.height;
			layerStatus.render();
			hWidth += status.width;
		}

		hWidth += textSprite.width;
		//hitBox.width = hWidth;

		textSprite.y = hitBox.y - textSprite.height / 2;
		textSprite.x = hitBox.x;

	}

}