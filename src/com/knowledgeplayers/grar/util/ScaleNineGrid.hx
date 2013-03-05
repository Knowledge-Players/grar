package com.knowledgeplayers.grar.util;
import nme.Lib;
import aze.display.TileSprite;
import nme.display.DisplayObject;
class ScaleNineGrid extends Grid{

    public function new(numRow: Int, numCol: Int) {
        super(numRow, numCol);


    }


   public function addTile(object:TileSprite,_oldTS:TileSprite): Void
    {


        var targetX = nextCell.x * object.width;
        var targetY = nextCell.y * object.height;


        if(nextCell.x < numCol - 1)
        {
            nextCell.x++;
        }
        else if(nextCell.y < numRow){
            nextCell.x = 0;
            nextCell.y++;
        }
        else{
            throw "This grid is already full!";
        }

            object.x = targetX;
            object.y = targetY;



    }


}
