package grar.view.component;

import grar.model.part.item.Item.VideoData;
typedef VideoElement=String;

class VideoPlayer{
    public var root (default, null): VideoElement;

    public function new(){

    }

    public function init(root:VideoElement):Void
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