package grar.view.element;

import com.knowledgeplayers.grar.display.component.TileImage; // FIXME
import com.knowledgeplayers.grar.display.component.Widget; // FIXME

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

	/**
	 * Name of the timeline
	 **/
	public var name (default, default) : String;

	/**
	 * Elements affected by this timeline
	 **/
    public var elements (default, null) : Array<TimelineElement>;

    private var nbCompleteTransitions : Float = 0;

    public function new(?name:String) : Void {

		super();

		this.name = name;
        this.elements = [];

    }

    public function play():Void
    {
         nbCompleteTransitions=0;

         for (elem in elements){
            var actuator = TweenManager.applyTransition(elem.widget,elem.transition,elem.delay);
            if(actuator != null)
	            actuator.onComplete(onCompleteTransition, [elem.widget.ref]);
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