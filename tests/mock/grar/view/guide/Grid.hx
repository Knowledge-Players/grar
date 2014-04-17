package grar.view.guide;

import grar.util.Point;


/**
 * Manage a grid to place object
 */
class Grid{

    public function new(root: Element, numRow: Int, ?numCol: Int = -1) {

    }

/**
    * Number of rows
    **/
    public var numRow (default, default):Int;
/**
    * Number of columns
    **/
    public var numCol (default, default):Int;

    private var nextCell:Point;
    private var rows:Array<Element>;

///
// API
//

/**
	* Add an object to the grid
	**/
    public function add(object : Element) : Element {
        return null;
    }
}
