package grar.view.guide;

import grar.util.Point;
import grar.util.MathUtils;

import js.html.Element;


/**
* Utility to place items where you want
**/
class Absolute extends Guide
{

    public function new(r:Element, p : Array<Point>) {

        super();
        root = r;
        points = p;
        objects = new Array<Element>();
    }

    private var objects: Array<Element>;
    private var points: Array<Point>;
    private var root:Element;

///
// API
//

/**
	* @inherits
	**/
    override public function add(object:Element):Element
    {
        if (objects.length < points.length) {
            setCoordinates(object, points[objects.length].x, points[objects.length].y);
        } else {
            // if guide is full, put elements on top
            trace("Warning : Guide is full");
            setCoordinates(object, 0, (objects.length-points.length)*10);
        }
        root.appendChild(object);

        objects.push(object);
        return object;
    }

/**
	* Empty the list
	**/
    public function flush():Void
    {
        for(obj in objects)
            obj = null;
        objects = new Array<Element>();
    }

    public function toString():String
    {
        return 'Absolute: ' + points + ' '+objects.length+' children';
    }
}