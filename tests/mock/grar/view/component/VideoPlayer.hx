package grar.view.component;

import grar.model.part.item.Item.VideoData;
typedef Element=String;

class VideoPlayer{
    public var root (default, null): Element;

    public function new(){

    }

	public dynamic function onFullscreenRequest(?button: Element): Void {}
	public dynamic function onExitFullscreenRequest(?button: Element): Void {}
	public dynamic function onToggleFullscreenRequest(?button: Element): Void {}

    public function init(root:Element):Void
    {

    }

    public function setVideo(url: String, videoData: VideoData, onVideoPlay: Void -> Void, onVideoEnd: Void -> Void) : Void {

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