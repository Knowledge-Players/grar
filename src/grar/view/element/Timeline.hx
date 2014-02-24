package grar.view.element;

import grar.view.component.TileImage;
import grar.view.component.Widget;

import flash.events.Event;
import flash.events.EventDispatcher;

using StringTools;

typedef TimelineElement = {

    var widget : Widget;
    var transition : String;
    var delay : Float;
    var dynamicValue : Null<String>;
}

class Timeline extends EventDispatcher {

    public function new( ? name : String ) : Void {

        super();

        this.name = name;
        this.elements = [];
    }

	/**
	 * Name of the timeline
	 **/
	public var name (default, default) : String;

	/**
	 * Elements affected by this timeline
	 **/
    public var elements (default, null) : Array<TimelineElement>;

    private var nbCompleteTransitions : Float = 0;

    public function play():Void
    {
         nbCompleteTransitions=0;

         for (elem in elements){
// FIXME            var actuator = TweenManager.applyTransition(elem.widget,elem.transition,elem.delay);
// FIXME            if(actuator != null)
// FIXME	            actuator.onComplete(onCompleteTransition, [elem.widget.ref]);
         }
    }

    private function onCompleteTransition(elemRef: String):Void {
        nbCompleteTransitions++;
		dispatchEvent(new Event(elemRef));
        if(nbCompleteTransitions == elements.length){
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }

}