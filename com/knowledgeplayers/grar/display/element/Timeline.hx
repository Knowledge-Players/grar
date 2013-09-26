package com.knowledgeplayers.grar.display.element;

import com.knowledgeplayers.grar.display.component.TileImage;
import flash.events.Event;
import flash.events.EventDispatcher;
import com.knowledgeplayers.grar.display.component.Widget;

class Timeline extends EventDispatcher
{

    private var elements:Array<TimelineElement>;

    private var nbCompleteTransitions:Float = 0;

    public function new(?_id:String):Void{
            super();
         elements = new Array<TimelineElement>();

    }

    public function addElement(_widget:Widget,_transition:String,_delay:Float):Void{

          elements.push({widget:_widget,transition:_transition,delay:_delay});

    }

    public function play():Void{

         nbCompleteTransitions=0;

         for (elem in elements){
            if (Std.is(elem.widget, TileImage)) {

                TweenManager.applyTransition(cast(elem.widget,TileImage).tileSprite,elem.transition,elem.delay).onComplete(onCompleteTransition).onUpdate(function(){cast(elem.widget,TileImage).tileSprite.layer.render();});
            }else{
                TweenManager.applyTransition(elem.widget,elem.transition,elem.delay).onComplete(onCompleteTransition);
            }
         }
    }

    private function onCompleteTransition():Void {

        nbCompleteTransitions++;
        if(nbCompleteTransitions == elements.length){

            dispatchEvent(new Event(Event.COMPLETE));

        }
    }

}

typedef TimelineElement =
{
    var widget:Widget;
    var transition:String;
    var delay:Float;
}