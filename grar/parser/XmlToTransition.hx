package grar.parser;

import haxe.xml.Fast;
import haxe.ds.StringMap;

import grar.view.TransitionTemplate;

class XmlToTransition {

    static inline var NODE_NAME_ZOOM : String = "zoom";
    static inline var NODE_NAME_FADE : String = "fade";
    static inline var NODE_NAME_SLIDE : String = "slide";
    static inline var NODE_NAME_ROTATE : String = "rotate";
    static inline var NODE_NAME_TRANSFORM : String = "transform";
    static inline var NODE_NAME_MASK : String = "mask";

    static public function parse( xml : Xml ) : StringMap<TransitionTemplate> {

        var root : Fast = new Fast(xml).node.Transitions;

        var sm : StringMap<TransitionTemplate> = new StringMap();

        for (child in root.elements) {

            var duration : Float = Std.parseFloat(child.att.duration);
            var delay : Int = 0;
            var easingType : Null<String> = null;
            var easingStyle : Null<String> = null;
            var repeat : Null<Int> = null;
            var reflect : Null<Bool> = null;
            var type : Null<TransitionType> = null;

            if(child.has.delay) {

                delay = Std.parseInt(child.att.delay);
            }
            if(child.has.easingType) {

                easingType = child.att.easingType.toLowerCase();
                easingStyle = child.att.easingStyle.toLowerCase();
            }
            if(child.has.repeat) {

                repeat = Std.parseInt(child.att.repeat);
            }
            if(child.has.reflect) {

                reflect = child.att.reflect == "true";
            }
            switch (child.name.toLowerCase()) {

                case NODE_NAME_ZOOM:
                    type = Zoom( child.has.x ? child.att.x : "x", child.has.y ? child.att.y : "y", child.has.width ? child.att.width : "width", child.has.height ? child.att.height : "height" );

                case NODE_NAME_FADE:
                    type = Fade(child.att.alpha);

                case NODE_NAME_SLIDE:
                    type = Slide(child.has.x ? child.att.x : "x", child.has.y ? child.att.y : "y");

                case NODE_NAME_ROTATE:
                    type = Rotate( child.has.x ? child.att.x : "x", child.has.y ? child.att.y : "y", child.has.rotation ? child.att.rotation : "rotation" );

                case NODE_NAME_TRANSFORM:
                    type = Transform( child.att.color );

                case NODE_NAME_MASK:
                    type = Mask(child.att.shutterTransitions.split(","), child.att.shutterChaining);
            }
            sm.set( child.att.ref, new TransitionTemplate(duration, delay, easingType, easingStyle, repeat, reflect, type) );
        }
        return sm;
    }
}