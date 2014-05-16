package grar.view.guide;

import grar.util.Point;


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