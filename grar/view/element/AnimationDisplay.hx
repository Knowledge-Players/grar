package grar.view.element;

import aze.display.TileClip;
import aze.display.TileLayer;
import aze.display.TilesheetEx;

import grar.view.component.container.WidgetContainer;

import flash.events.Event;

class AnimationDisplay extends WidgetContainer {

    //public function new(?xml: Fast, ?_id:String, ?_tileSheet:TilesheetEx, _loop:Int = 0,_visible:Bool=false) {
    public function new(add : WidgetContainerData) {

        //super(xml);
        super(add);

        set_visible(_visible);

        if (_tileSheet != null) {

            tilesheet = _tileSheet;
        }
        if (_id != null) {
            
            clip = new TileClip(layer, _id);
            layer.addChild(clip);
            layer.render();
        }
        loop = _loop;

        addEventListener(Event.ADDED_TO_STAGE, animate);
    }

	private var clip : TileClip;
	private var loop : Int;
    private var callBack : Dynamic;
    private var parameters : Array<Dynamic>;
    private var frame : Int;
    private var totalFrames : Int;

	/**
    * Play the animation with an Enter_Frame
    **/

	public function animate(?e:Event):Void
	{
		clip.play();
		clip.loop = false;
		clip.onComplete = onAnimationEnd;
		layer.render();
	}
    public function animateBack(?e:Event):Void
    {

        clip.currentFrame = frame;
        clip.loop = false;
        if (clip.currentFrame==0){
            onAnimationEndBack(clip);
        }

        layer.render();
        frame--;
    }

    private function onAnimationEndBack(_clip:TileClip):Void
    {

        if(loop > 0){
            _clip.currentFrame = totalFrames;
            animateBack();
        }
        else
        {
            removeEventListener(Event.ENTER_FRAME, animateBack);

            callBack(parameters);
        }
        loop--;
    }


	/**
    * Stop the animation
    **/

	public function stopElement():Void
	{
		clip.stop();
		clip.currentFrame = 0;
		layer.render();

	}
	/*
     Goto the frame you want;
     */

	public function goto(_frame:Int):Void
	{
		clip.currentFrame = _frame;
		layer.render();
	}

	private function onAnimationEnd(clip:TileClip):Void
	{

		if(loop > 0){
			clip.currentFrame = 0;
			clip.play();
			layer.render();
		}
        else
        {
            removeEventListener(Event.ENTER_FRAME, animate);
            callBack(parameters);
        }
        loop--;
	}

    public function playAnimation(?_loop:Int=0,?_callBack:Dynamic,?_parameters:Array <Dynamic>):Void{

        if (_callBack != null)callBack=_callBack;
        if(_parameters != null)parameters = _parameters;
        addEventListener(Event.ENTER_FRAME, animate);
    }

    public function playAnimationBack(?_loop:Int=0,?_callBack:Dynamic,?_parameters:Array <Dynamic>):Void{
        totalFrames = frame = clip.currentFrame;
        if (_callBack != null)callBack=_callBack;
        if(_parameters != null)parameters = _parameters;
        addEventListener(Event.ENTER_FRAME, animateBack);
    }

    public function stopAnimation():Void{
        addEventListener(Event.ENTER_FRAME, animate);
    }
}