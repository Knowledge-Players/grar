package grar.view.guide;

import js.html.Element;

typedef GridData = {

	var numRow : Int;
	var numCol : Int;
	var resize : Bool;
	var width : Null<Float>;
	var height : Null<Float>;
	var gapCol : Null<Float>;
	var gapRow : Null<Float>;
	var alignment : Null<String>;
	@:optional var cellWidth : Float;
	@:optional var cellHeight : Float;
}

enum GridAlignment {

	CENTER;
	TOP_LEFT;
	TOP_RIGHT;
	TOP_MIDDLE;
	MIDDLE_LEFT;
	MIDDLE_RIGHT;
	BOTTOM_LEFT;
	BOTTOM_MIDDLE;
	BOTTOM_RIGHT;
}

typedef Size = {

	var width: Float;
	var height: Float;
}

/**
 * Manage a grid to place object
 */
class Grid extends Guide {

	public function new(d : GridData) {

		super();

		this.numRow = d.numRow;
		this.numCol = d.numCol;
		this.gapCol = d.gapCol;
		this.gapRow = d.gapRow;
		this.resize = d.resize;

		this.alignment = d.alignment != null ? Type.createEnum(GridAlignment, d.alignment.toUpperCase()) : GridAlignment.TOP_LEFT;

		cellSize = { width: d.cellWidth, height: d.cellHeight };

		// Initialize nextCell to (0;0)
		empty();
	}

	/**
    * Number of rows
    **/
	public var numRow (default, default):Int;
	/**
    * Number of columns
    **/
	public var numCol (default, default):Int;
	/**
    * Size of a cell
    **/
	public var cellSize (default, default):Size;
	/**
	* Space between columns
	**/
	public var gapCol (default, default):Float;
	/**
	* Space between rows
	**/
	public var gapRow (default, default):Float;

	private var nextCell:Point;

	private var alignment: GridAlignment;
	private var resize: Bool;


	///
	// GETTER / SETTER
	//

	override public function set_x(x : Float) : Float {

		return this.x = x;
	}

	override public function set_y(y : Float) : Float {

		return this.y = y;
	}


	///
	// API
	//

	/**
	* @inherits
	**/
	override public function add(object : Element) : Element {

		var rect = object.getBoundingClientRect();

		if (cellSize.width == 0) {

			cellSize.width = rect.width;
		}
		if (cellSize.height == 0) {

			cellSize.height = rect.height;
		}
		var targetX : Float = x + nextCell.x * cellSize.width;

		targetX += gapCol * nextCell.x;

		targetX += switch (alignment) {

				case CENTER, TOP_MIDDLE, BOTTOM_MIDDLE: cellSize.width / 2 - rect.width / 2;

				case TOP_RIGHT, MIDDLE_RIGHT, BOTTOM_RIGHT: cellSize.width - rect.width;

				default: 0;// Already on the left
			}

		var targetY : Float = y + nextCell.y * cellSize.height;

		targetY += gapRow * nextCell.y;

		targetY += switch (alignment) {

				case CENTER, MIDDLE_LEFT, MIDDLE_RIGHT: cellSize.height / 2 - rect.height / 2;

				case BOTTOM_LEFT, BOTTOM_MIDDLE, BOTTOM_RIGHT: cellSize.height - rect.height;

				default: 0;// Already on top
			}

		if (nextCell.x < numCol - 1) {

			nextCell.x++; //trace("incrementing nextCell.x => "+nextCell.x);

		} else if (nextCell.y < numRow) {

			nextCell.x = 0;
			nextCell.y++;

		} else {

			throw "This grid is already full!";
		}

		setCoordinates(object, targetX, targetY);

        if (resize)
	        fitInGrid(object);

		return object;
	}

	/**
    * Align the element in the cell, if the cell is too large
    **/

	public function setAlignment(alignment: String):Void
	{
		this.alignment = Type.createEnum(GridAlignment, alignment.toUpperCase());
	}

	public function empty():Void
	{
		nextCell = new Point();
	}

	private inline function fitInGrid(object: Element):Void
	{
		object.style.width = Std.string(cellSize.width)+"px";
		object.style.height = Std.string(cellSize.height)+"px";
	}
}
