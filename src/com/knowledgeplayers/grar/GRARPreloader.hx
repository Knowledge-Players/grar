package com.knowledgeplayers.grar;

import nme.display.MovieClip;
import nme.Lib;
import nme.Assets;
import nme.text.TextFormat;
import nme.text.TextField;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import haxe.FastList;
import com.knowledgeplayers.utils.assets.interfaces.IAsset;
import nme.events.ErrorEvent;
import nme.events.SecurityErrorEvent;
import nme.events.IOErrorEvent;
import nme.events.Event;
import nme.media.Sound;
import nme.display.Bitmap;
import com.knowledgeplayers.utils.assets.AssetsConfig;
import com.knowledgeplayers.utils.assets.AssetsLoader;

class GRARPreloader extends NMEPreloader {

	/**
	 * Assets loader
	 */
	public var loader:AssetsLoader;

	/**
	 * Config file (optional)
	 */
	public var config:AssetsConfig;

	private var assetsLoaded:Bool;
	private var text:TextField;
	private var state:Int = 0;
	private var nbFrame:Int = 0;

	public function new()
	{

		super();
		while(numChildren > 0)
			removeChildAt(numChildren - 1);

		//assets loader and pass it to storage after load complete
		loader = new AssetsLoader();
		loader.addEventListener(Event.COMPLETE, loadAssetsCompleteHandler, false, 0, true);
		loader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler, false, 0, true);

		config = new AssetsConfig("config", "assets.xml", null);
		config.addEventListener(Event.COMPLETE, loadConfigCompleteHandler);
		config.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
		config.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		config.load();

		text = new TextField();
		text.defaultTextFormat = new TextFormat(Assets.getFont("fonts/Myriad Pro/MyriadPro-BoldCond.ttf").fontName, 20);
		text.x = Lib.current.stage.stageWidth / 2;
		text.y = Lib.current.stage.stageHeight / 2;
		addChild(text);
	}

	override public function onLoaded()
	{
		if(assetsLoaded){
			Lib.current.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			super.onLoaded();
		}
		else
			Lib.current.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	override public function onUpdate(bytesLoaded:Int, bytesTotal:Int)
	{
		if(state == 0)
			text.text = "Loading";
		else if(state == 1)
			text.text = "Loading.";
		else if(state == 2)
			text.text = "Loading..";
		else if(state == 3)
			text.text = "Loading...";

	}

	private function onEnterFrame(e:Event):Void
	{
		nbFrame++;
		if(nbFrame % 8 == 0) state++;
		if(state == 4) state = 0;
		onUpdate(0, 0);
	}

	/**
	 * Assets have been loaded
	 * @param event
	 */

	private function loadAssetsCompleteHandler(event:Event):Void
	{
		assetsLoaded = true;
		onLoaded();
	}

	/**
	 * Assets to load
	 * @param list
	 */

	private function loadAssets(list:FastList<IAsset>):Void
	{
		loader.load(list);
	}

	/**
	 * Config file has been loaded
	 * @param event
	 */

	private function loadConfigCompleteHandler(event:Event):Void
	{
		//load assets
		loadAssets(config.list);
		//clear config
		config.dispose();
		config.removeEventListener(Event.COMPLETE, loadConfigCompleteHandler);
		config.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
		config.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		config = null;
	}

	/**
	 * Error, asset not found!
	 * @param event
	 */

	private function loadErrorHandler(event:ErrorEvent):Void
	{
		throw "[Preloader] Can't load asset: " + event;
	}
}
