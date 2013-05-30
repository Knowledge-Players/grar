package com.knowledgeplayers.grar;

import nme.text.TextFormat;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import haxe.ds.GenericStack;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import com.knowledgeplayers.utils.assets.AssetsConfig;
import com.knowledgeplayers.utils.assets.AssetsLoader;
import com.knowledgeplayers.utils.assets.interfaces.IAsset;
import format.display.MovieClip;
import nme.Assets;
import nme.events.ErrorEvent;
import nme.events.Event;
import nme.events.IOErrorEvent;
import nme.events.SecurityErrorEvent;
import nme.Lib;
import nme.text.TextField;

class GRARPreloader extends NMEPreloader {

	/**
* Assets loader
*/
	public var loader:AssetsLoader;

	public var completionArea (default, default):TextField;

	/**
* Config file (optional)
*/
	public var config:AssetsConfig;

	private var assetsLoaded:Bool;
	private var text:TextField;
	private var state:Int = 0;
	private var totalAssets:Int = 0;
	private var loadedAssets:Int = 0;

	public function new()
	{

		super();
		while(numChildren > 0)
			removeChildAt(numChildren - 1);

		//assets loader and pass it to storage after load complete
		loader = new AssetsLoader();
		loader.addEventListener(Event.COMPLETE, loadAssetsCompleteHandler, false, 0, true);
		loader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler, false, 0, true);
		loader.addEventListener("ONE_LOADED", onOneLoaded, false, 0, true);

		config = new AssetsConfig("config", "assets.xml", null);
		config.addEventListener(Event.COMPLETE, loadConfigCompleteHandler);
		config.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
		config.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		config.load();

		completionArea = new TextField();
		completionArea.embedFonts = true;
		completionArea.selectable = false;
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
			icon.x = Lib.current.stage.stageWidth / 2;
			icon.y = Lib.current.stage.stageHeight / 2;
			addChild(icon);
			completionArea.y = icon.y + icon.height / 2 - 80;
			completionArea.defaultTextFormat = new TextFormat(Assets.getFont("fonts/Myriad Pro/MyriadPro-BoldCond.ttf").fontName, 28);
			completionArea.text = "0%";
			completionArea.x = Lib.current.stage.stageWidth / 2 - completionArea.textWidth / 2;
			addChild(completionArea);
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

	private function onOneLoaded(e:Event):Void
	{
		loadedAssets++;
		var prc = Math.round(loadedAssets * 100 / totalAssets);
		completionArea.text = prc + "%";
		completionArea.x = Lib.current.stage.stageWidth / 2 - completionArea.textWidth / 2;
	}

	/**
* Assets to load
* @param list
*/

	private function loadAssets(list:GenericStack<IAsset>):Void
	{
		totalAssets = Lambda.count(list);
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