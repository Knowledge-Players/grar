package grar.view.guide;

import grar.util.Point;

import js.html.Element;


/**
 * Manage a grid to place object
 */
class Grid{

	public function new(root: Element, numRow: Int, ?numCol: Int = -1) {

		this.numRow = numRow;
		this.numCol = numCol;
		rows = new Array<Element>();
		// Initialize nextCell to (0;0)
		nextCell = new Point();

		for(i in 0...numRow){
			var row = js.Browser.document.createDivElement();
			row.classList.add("row");
			root.appendChild(row);
			rows.push(row);
		}


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

		object.classList.add("cell");

		if(nextCell.y < numRow){
			rows[Std.int(nextCell.y)].appendChild(object);
			if (numCol < 0 || nextCell.x < numCol - 1)
				nextCell.x++;
			else{
				nextCell.x = 0;
				nextCell.y++;
			}
		} else {

			throw "This grid is already full!";
		}

		return object;
	}
}
