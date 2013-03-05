package com.knowledgeplayers.grar.util;
import nme.Lib;
import aze.display.TileSprite;
import nme.display.DisplayObject;
class ScaleNineGrid extends Grid{

    private var tileEnCours:TileSprite;

    public function new(numRow: Int, numCol: Int) {
        super(numRow, numCol);


    }


    public function initMatrice(_array:Array<TileSprite>,_width:Float,_height:Float):Void{

        for(i in 0..._array.length){
            if( i % 2 == 0 )
                {

                    if(_array[i].tile != "milieu"){

                    }
                }
        }


    }


   public function addTile(object:TileSprite): Void
    {
        var targetX:Float=0;
        var targetY:Float=0;


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


        Lib.trace("object.width : "+object.width);
        Lib.trace("object.height : "+object.height);
        tileEnCours = object;

    }


}
