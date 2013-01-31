package com.knowledgeplayers.grar.display.activity.folder;

import nme.Lib;
import com.eclecticdesignstudio.motion.Actuate;
import nme.display.DisplayObject;
import nme.geom.Point;
class Grid {
    public var numRow (default, default): Int;
    public var numCol (default, default): Int;
    public var cellSize (default, default): {width: Float, height: Float};
    public var x (default, default): Float;
    public var y (default, default): Float;

    private var nextCell: Point;

    public function new(numRow: Int, numCol: Int, cellWidth: Float, cellHeight: Float)
    {
        this.numRow = numRow;
        this.numCol = numCol;
        cellSize = {width: cellWidth, height: cellHeight};
        empty();
    }

    public function add(object: DisplayObject, withTween: Bool = true): Void
    {
        var targetX = x + nextCell.x * cellSize.width;
        var targetY = y + nextCell.y * cellSize.height;
        if(withTween)
            Actuate.tween(object, 0.5, {x: targetX, y: targetY, width: cellSize.width, height: cellSize.height});
        else{
            object.x = targetX;
            object.y = targetY;
            object.width = cellSize.width;
            object.height = cellSize.height;
        }
        if(nextCell.x < numCol - 1)
            nextCell.x++;
        else if(nextCell.y < numRow){
            nextCell.x = 0;
            nextCell.y++;
        }
        else
            throw "This grid is already full!";
    }

    public function empty(): Void
    {
        nextCell = new Point(0, 0);
    }
}
