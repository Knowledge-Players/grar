package com.knowledgeplayers.grar.display.element;

import com.knowledgeplayers.grar.display.component.TileImage;
import flash.events.Event;
import flash.events.EventDispatcher;
import com.knowledgeplayers.grar.display.component.Widget;

using StringTools;

class Timeline extends EventDispatcher
{
	/**
	* Name of the timeline
	**/
	public var name (default, default):String;

	/**
	* Elements affected by this timeline
	**/
    public var elements (default, null):Array<TimelineElement>;

    private var nbCompleteTransitions:Float = 0;

    public function new(?name:String):Void
	{
		super();
		this.name = name;
        elements = new Array<TimelineElement>();

    }

    public function addElement(widget: Widget, transition:String, delay: Float):Void
    {
        var dynValue: String = null;
		if(widget.ref.startsWith("$"))
			dynValue = widget.ref;
        elements.push({widget: widget, transition: transition, delay: delay, dynamicValue: dynValue});
    }

    public function play():Void
    {
         nbCompleteTransitions=0;

         for (elem in elements){
            /*if (Std.is(elem.widget, TileImage)) {
	            TweenManager.applyTransition(cast(elem.widget,TileImage).tileSprite,elem.transition,elem.delay).onComplete(onCompleteTransition).onUpdate(function(){
		            //cast(elem.widget,TileImage).tileSprite.layer.render();
		            cast(elem.widget,TileImage).trueLayer.render();
	            });
            }
            else{*/
	            var actuator = TweenManager.applyTransition(elem.widget,elem.transition,elem.delay);
	            if(actuator != null)
		            actuator.onComplete(onCompleteTransition);
            //}
         }
    }

    private function onCompleteTransition():Void {
        nbCompleteTransitions++;
        if(nbCompleteTransitions == elements.length){
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }

}

typedef TimelineElement = {
    var widget:Widget;
    var transition:String;
    var delay:Float;
	var dynamicValue: String;
}