package com.knowledgeplayers.grar.display.activity.scanner;

import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.scanner.ScannerPoint;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.events.MouseEvent;
import String;

class PointDisplay extends Sprite {

	private var style:PointStyle;
	private var bitmap:Bitmap;
	private var point:ScannerPoint;
    public var viewed:Bool =false;

	/**
    * Constructor
    * @param graphic : Set of the graphics for the different states of the point
    * @param radius : Radius of the point in pixel
    * @param point : Model of the display
**/

	public function new(style:PointStyle, point:ScannerPoint)
	{
		super();
		this.style = style;
		this.point = point;
		bitmap = new Bitmap();
		setGraphic("unseen");
		addChild(bitmap);

		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}

	// Handler

	private function setGraphic(state:String):Void
	{
		if(!style.graphics.exists(state))
			return;

		if(Std.parseInt(style.graphics.get(state)) != null){
			graphics.beginFill(Std.parseInt(style.graphics.get(state)));
			graphics.drawCircle(style.radius / 2, style.radius / 2, style.radius);
			graphics.endFill();
		}
		else{
			var bmp = new Bitmap(AssetsStorage.getBitmapData(style.graphics.get(state)));
			bitmap.bitmapData = bmp.bitmapData;
		}
	}

	private function onOver(e:MouseEvent):Void
	{
		alpha = 1;
		setGraphic("over");
		var text = Localiser.instance.getItemContent(point.content);
		cast(parent, ScannerDisplay).setText(point.textRef, text);
        point.viewed=true;
        cast(parent, ScannerDisplay).checkElement();

	}

	private function onOut(e:MouseEvent):Void
	{
		setGraphic("seen");
	}
}

class PointStyle {
	/**
    * Radius of the point. If 0, the size of the image will be unchanged
**/
	public var radius (default, default):Float = 0;

	/**
    * Graphics for the different states of the point
    **/
	public var graphics (default, default):Map<String, String>;

	public function new()
	{
		graphics = new Map<String, String>();
	}

	public function addGraphic(key:String, graph:String):Void
	{
		graphics.set(key, graph);
	}
}
