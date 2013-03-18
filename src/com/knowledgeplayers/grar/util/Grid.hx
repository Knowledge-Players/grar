package com.knowledgeplayers.grar.util;

import com.eclecticdesignstudio.motion.Actuate;
import com.knowledgeplayers.grar.util.LoadData;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.geom.Point;
import nme.Lib;

/**
 * Manage a grid to place object
 */
class Grid {
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
    public var cellSize (default, default):{width:Float, height:Float};
    /**
    * X of the grid
    **/
    public var x (default, default):Float;
    /**
    * Y of the grid
    **/
    public var y (default, default):Float;

    public var gapCol (default, default):Float;
    public var gapRow (default, default):Float;

    /**
    * Align the element in the cell, if the cell is too large
    **/
    public var alignment (default, default):GridAlignment;

    private var nextCell:Point;

    public function new(numRow:Int, numCol:Int, cellWidth:Float = 0, cellHeight:Float = 0, gapCol:Float = 0, gapRow:Float = 0, ?alignment:GridAlignment)
    {
        this.numRow = numRow;
        this.numCol = numCol;
        this.gapCol = gapCol;
        this.gapRow = gapRow;

        this.alignment = alignment != null ? alignment : GridAlignment.TOP_LEFT;

        cellSize = {width: cellWidth, height: cellHeight};

        // Initialize nextCell to (0;0)
        empty();
    }

    public function add(object:DisplayObject, ?withTween:Bool = true):Void
    {
        if(cellSize.width == 0){
            cellSize.width = object.width;
        }
        if(cellSize.height - gapRow == 0){
            cellSize.height = object.height;
        }

        var targetX = x + nextCell.x * cellSize.width;
        if(nextCell.x > 0)
            targetX += gapCol;
        targetX += switch(alignment){
            case CENTER, TOP_MIDDLE, BOTTOM_MIDDLE: cellSize.width / 2 - object.width / 2;
            case TOP_RIGHT, MIDDLE_RIGHT, BOTTOM_RIGHT: cellSize.width - object.width;
            default: // Already on the left
        }

        var targetY = y + nextCell.y * cellSize.height;
        if(nextCell.y > 0)
            targetY += gapRow;
        targetY += switch(alignment){
            case CENTER, MIDDLE_LEFT, MIDDLE_RIGHT: targetY += cellSize.height / 2 - object.height / 2;
            case BOTTOM_LEFT, BOTTOM_MIDDLE, BOTTOM_RIGHT: targetY += cellSize.height - object.height;
            default: // Already on top
        }

        if(nextCell.x < numCol - 1){
            nextCell.x++;
        }
        else if(nextCell.y < numRow){
            nextCell.x = 0;
            nextCell.y++;
        }
        else
            throw "This grid is already full!";

        if(withTween)
            Actuate.tween(object, 0.5, {x: targetX, y: targetY, width: cellSize.width, height: cellSize.height});
        else{
            object.x = targetX;
            object.y = targetY;

            object.width = cellSize.width;
            object.height = cellSize.height;
        }

    }

    public function empty():Void
    {
        nextCell = new Point(0, 0);
    }
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
