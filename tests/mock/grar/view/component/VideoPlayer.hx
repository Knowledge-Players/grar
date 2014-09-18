package grar.view.component;

import grar.model.InventoryToken.TokenTrigger;
import grar.model.part.item.Item.VideoData;

typedef Element=String;

class VideoPlayer{
    public var root (default, null): Element;

    public function new(){

    }

	public dynamic function onFullscreenRequest(?button: Element): Void {}
	public dynamic function onExitFullscreenRequest(?button: Element): Void {}
	public dynamic function onToggleFullscreenRequest(?button: Element): Void {}
	public dynamic function onAnimationFrameRequest(callback: Void -> Void): Void {}
	public dynamic function onSubtitleRequest(path: String, callback: String -> Void): Void {}
	public dynamic function onTokenActivation(tokenId: String): Void {}

    public function init(root:Element):Void
    {

    }

    public function setVideo(url: String, videoData: VideoData, ?tokens: Array<TokenTrigger>, onVideoPlay: Void -> Void, onVideoEnd: Void -> Void) : Void {

    }

    public function play():Void
    {

    }

    public function pause():Void
    {

    }

    public function stop():Void
    {

    }
}