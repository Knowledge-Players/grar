package grar.view.element;

import motion.actuators.GenericActuator.IGenericActuator;

import grar.view.component.TileImage;
import grar.view.component.Widget;

import grar.util.TweenUtils;

import flash.events.Event;
import flash.events.EventDispatcher;

import haxe.ds.StringMap;

using StringTools;

typedef TimelineElement = {

    var widget : Widget;
    var transition : String;
    var delay : Float;
    var dynamicValue : Null<String>;
}

class Timeline /* extends EventDispatcher */ {

    public function new(callbacks : grar.view.DisplayCallbacks, transitions : StringMap<TransitionTemplate>,
                             ? name : String) : Void {

        //super();

        this.transitions = transitions;
        
        this.name = name;
        this.elements = [];
    }

    var transitions : StringMap<TransitionTemplate>;

	/**
	 * Name of the timeline
	 **/
	public var name (default, default) : String;

	/**
	 * Elements affected by this timeline
	 **/
    public var elements (default, null) : Array<TimelineElement>;

    private var nbCompleteTransitions : Float = 0;


    ///
    // CALLBACKS
    //

    // dispatchEvent(new Event(elemRef));
    public dynamic function onCompleteTransition(elemRef : String) : Void { }
    
    // dispatchEvent(new Event(Event.COMPLETE));
    public dynamic function onTimelineEnded() : Void { }


    ///
    // API
    //

    public function addElement(widget : Widget, transition : String, delay : Float) : Void {

        var dynValue : String = null;

        if (widget.ref.startsWith("$")) {

            dynValue = widget.ref;
        }

        elements.push({ widget: widget, transition: transition, delay: delay, dynamicValue: dynValue });
    }

    public function play() : Void {

        nbCompleteTransitions=0;

        for (elem in elements) {

//          var actuator = TweenManager.applyTransition(elem.widget,elem.transition,elem.delay);
            var actuator = TweenUtils.applyTransition(elem.widget, transitions, elem.transition, elem.delay);
            
            if (actuator != null) {

	            actuator.onComplete(function(){

                    nbCompleteTransitions++;

                    onCompleteTransition(elem.widget.ref);

                    if (nbCompleteTransitions == elements.length) {

                        onTimelineEnded();
                    }
                });
            }
        }
    }
}