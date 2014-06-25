package grar.view.guide;

import grar.util.Point;

import js.html.Element;

/**
 * Manage a grid to place object
 */
class Grid extends Guide {

	/**
	* Create a grid to place element
	* @param    root: Parent of the elements, where the grid will be
	* @param    numRow: Number of rows in the grid
	* @param    numCol: Number of columns in the grid
	* @param    referenceElement: If not null, the grid will be inserted after this element
	**/
	public function new(root: Element, numRow: Int, ?numCol: Int = -1, ?referenceElement: Element) {

        super();

		this.numRow = numRow;
		this.numCol = numCol;
		rows = new Array<Element>();
		// Initialize nextCell to (0;0)
		nextCell = new Point();

		var lastRow: Element = null;
		for(i in 0...numRow){
			var row = js.Browser.document.createDivElement();
			row.classList.add("row");
			if(referenceElement != null){
				if(i == 0){
					root.insertBefore(row, referenceElement.nextSibling);
					lastRow = row;
				}
				else
					root.insertBefore(row, lastRow.nextSibling);
			}
			else
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
	override public function add(object : Element) : Element {

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
