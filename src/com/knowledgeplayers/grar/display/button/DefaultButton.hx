package com.knowledgeplayers.grar.display.button;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * Custom base button class
 * @author jbrichardet
 */

class DefaultButton extends Sprite
{
	public var upState: TileSprite;
	public var overState: TileSprite;
	public var downState: TileSprite;

	public var layer: TileLayer;
	public var enabled (default, enable): Bool;

	public function new(tilesheet: TilesheetEx, tile: String)
	{
		super();
		
		this.layer = new TileLayer(tilesheet);
		this.upState = new TileSprite(tile);
		this.downState = new TileSprite(tile+"_pressed");
		this.overState = new TileSprite(tile + "_over");

		mouseChildren = false;
		
		init();
	}

	
	public function setAllListeners(listener: MouseEvent -> Void): Void 
	{
		removeAllEventsListeners(listener);
		addEventListener(MouseEvent.MOUSE_OUT, listener);
		addEventListener(MouseEvent.MOUSE_OVER, listener);
		addEventListener(MouseEvent.ROLL_OVER, listener);
		addEventListener(MouseEvent.ROLL_OUT, listener);
		addEventListener(MouseEvent.CLICK, listener);
		addEventListener(MouseEvent.DOUBLE_CLICK, listener);
		addEventListener(MouseEvent.MOUSE_DOWN, listener);
		addEventListener(MouseEvent.MOUSE_UP, listener);
	}
	
	public function enable(activate: Bool) : Bool
	{
		enabled = buttonMode = mouseEnabled = activate;
		
		return activate;
	}
	
	// Abstract


	private function onMouseOver(event: MouseEvent) : Void {}

	private function onMouseOut(event: MouseEvent) : Void {}

	private function onClick(event: MouseEvent) : Void {}

	private function onDblClick(event: MouseEvent) : Void {}

	private function open(event: MouseEvent) : Void {}

	private function close(event: MouseEvent) : Void {}

	// Private

	private function onOver(event: MouseEvent) : Void 
	{
		upState.visible = false;
		overState.visible = true;
		
		layer.render();
	}

	private function onOut(event: MouseEvent) : Void
	{
		overState.visible = false;
		upState.visible = true;
		
		layer.render();
	}

	private function onClickDown(event: MouseEvent) : Void
	{
		overState.visible = false;
		downState.visible = true;	
		layer.render();	
	}

	private function onClickUp(event: MouseEvent) : Void 
	{
		upState.visible = true;
		downState.visible = false;	
		layer.render();
	}

	private function init() : Void 
	{
		enabled = true;
		
		downState.visible = false;
		overState.visible = false;
		upState.visible = true;
		layer.addChild(upState);
		layer.addChild(downState);
		layer.addChild(overState);

		setAllListeners(onMouseEvent);
		
		
		addChild(layer.view);
		
		layer.render();
		
		// Hack for C++ hitArea (NME 3.4.4)
		#if cpp
			graphics.beginFill (0xFFFFFF, 0.01);
			graphics.drawRect (-upState.width/2, -upState.height/2, upState.width, upState.height);
		#end
	}

	private function removeAllEventsListeners(listener: MouseEvent -> Void) : Void 
	{
		removeEventListener(MouseEvent.MOUSE_OUT, listener);
		removeEventListener(MouseEvent.MOUSE_OVER, listener);
		removeEventListener(MouseEvent.ROLL_OVER, listener);
		removeEventListener(MouseEvent.ROLL_OUT, listener);
		removeEventListener(MouseEvent.CLICK, listener);
		removeEventListener(MouseEvent.DOUBLE_CLICK, listener);
		removeEventListener(MouseEvent.MOUSE_DOWN, listener);
		removeEventListener(MouseEvent.MOUSE_UP, listener);
	}

	// Listener

	private function onMouseEvent(event : MouseEvent) : Void 
	{
		if (!enabled) {
			event.stopImmediatePropagation();
			return;
		}
		
		switch (event.type) {
			case MouseEvent.MOUSE_OUT:	onMouseOut(event);
			case MouseEvent.MOUSE_OVER:	onMouseOver(event);
			case MouseEvent.ROLL_OVER:	onOver(event);
			case MouseEvent.ROLL_OUT:	onOut(event);
			case MouseEvent.CLICK:		onClick(event);
			case MouseEvent.MOUSE_DOWN:	onClickDown(event);
			case MouseEvent.MOUSE_UP:	onClickUp(event);
			case MouseEvent.DOUBLE_CLICK: onDblClick(event);
		}
	}
}