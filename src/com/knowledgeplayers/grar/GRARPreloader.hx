package com.knowledgeplayers.grar;

import format.display.MovieClip;
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

	public function new()
	{

		super();
		while(numChildren > 0)
			removeChildAt(numChildren - 1);

		// Black background
		/*graphics.beginFill(0);
		graphics.drawRect(0,0,nme.Lib.stage.stageWidth, nme.Lib.stage.stageHeight);
		graphics.endFill();*/

		//assets loader and pass it to storage after load complete
		loader = new AssetsLoader();
		loader.addEventListener(Event.COMPLETE, loadAssetsCompleteHandler, false, 0, true);
		loader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler, false, 0, true);

		config = new AssetsConfig("config", "assets.xml", null);
		config.addEventListener(Event.COMPLETE, loadConfigCompleteHandler);
		config.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
		config.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		config.load();
	}

	override public function onLoaded()
	{
		if(assetsLoaded){
			super.onLoaded();
			cast(getChildAt(0), MovieClip).stop();
			removeChildAt(0);
		}
		else{
			// Loader icon
			var icon = Assets.getMovieClip("loadingCircular:loading");
			icon.x = Lib.current.stage.stageWidth / 2 - icon.width / 2;
			icon.y = Lib.current.stage.stageHeight / 2 - icon.height / 2;
			//icon.stop();
			addChild(icon);
		}
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
