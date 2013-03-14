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
    public var numRow (default, default):Int;
    public var numCol (default, default):Int;
    public var cellSize (default, default):{width:Float, height:Float};
    public var x (default, default):Float;
    public var y (default, default):Float;
    public var gapCol (default, default):Float;
    public var gapRow (default, default):Float;
    public var alignX (default, default):String;
    public var alignY (default, default):String;
    public var gapX(default, default):Float = 0;
    public var gapY(default, default):Float = 0;

    private var nextCell:Point;

    public function new(numRow:Int, numCol:Int, cellWidth:Float = 0, cellHeight:Float = 0, gapCol:Float = 0, gapRow:Float = 0, ?_alignX:String, ?_alignY:String, ?img:String = "")
    {
        this.numRow = numRow;
        this.numCol = numCol;
        this.gapCol = gapCol;
        this.gapRow = gapRow;
        this.alignX = _alignX;
        this.alignY = _alignY;

        cellSize = {width: cellWidth, height: cellHeight};

        // Initialize nextCell to (0;0)
        empty();
    }

    public function alignContainer(_container:Sprite, _bkg:Bitmap):Void
    {
        switch(alignX)
        {
            case "left":
                _container.x = 0;

            case "middle":
                _container.x = _bkg.x + _bkg.width / 2 - _container.width / 2;

            case "right":
                _container.x = _bkg.x + _bkg.width - _container.width;
        }
        switch(alignY)
        {
            case "top":
                _container.y = 0;

            case "center":
                _container.y = _bkg.y + _bkg.height / 2 - _container.height / 2 ;

            case "bottom":
                _container.y = _bkg.y + _bkg.height - _container.height;
        }
    }

    public function add(object:DisplayObject, ?withTween:Bool = true):Void
    {
        if(cellSize.width == 0){
            cellSize.width = object.width;
        }
        if(cellSize.height == 0){
            cellSize.height = object.height;
        }
        //if(nextCell.x != 0)gapX += gapRow;
        //if(nextCell.y != 0)gapY += gapCol;

        var targetX = x + nextCell.x * cellSize.width + gapX;
        var targetY = y + nextCell.y * cellSize.height + gapY;

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
