package com.knowledgeplayers.grar.util;
import nme.Lib;
import aze.display.TileSprite;
import nme.display.DisplayObject;
class ScaleNineGrid extends Grid{


    public function new(numRow: Int, numCol: Int) {
        super(numRow, numCol);


    }


    public function initMatrice(_array:Array<TileSprite>,_width:Float,_height:Float):Void{

        //Lib.trace("_width : "+_width);
        //Lib.trace("_height : "+_height);
        var largeur:Float=0;
        var hauteur:Float=0;

        for(i in 0..._array.length){
            if (i == 0 || i ==2)
                {
                    largeur+=_array[i].width;
                }
            if(i==0 || i==6)
                {
                    //Lib.trace(_array[i].height);
                    hauteur+=_array[i].height;

                }
        }
        largeur= _width-largeur;
        hauteur= _height-hauteur;


       // Lib.trace("largeur : "+largeur);
       // Lib.trace("hauteur : "+hauteur);
        var lastY:Float=0;

        for(i in 0..._array.length){
            if( i % 2 == 0 ){

                    if(_array[i].tile == "milieu"){
                        _array[i].scaleX=largeur/ _array[i].width;
                        _array[i].scaleY=hauteur/ _array[i].height;

                       //_array[i].width=largeur;
                       // _array[i].height=hauteur;
                    }
            }

            if(i==1 || i==7){
            //_array[i].width=largeur;
            _array[i].scaleX=largeur/ _array[i].width;
            }
            if(i==3 || i==5){
            //_array[i].height=hauteur;
              _array[i].scaleY=hauteur/ _array[i].height;
            }

            if(i==0 || i== 3 || i==6)
                {
                    _array[i].x =0;
                }
            else
            {
                _array[i].x =_array[i-1].x+_array[i-1].width/2+_array[i].width/2;
            }

            if(i == 0 || i==1 || i==2){
                    _array[i].y=0;
            }
            if( i ==3){

                _array[i].y =  _array[0].y+ _array[0].height/2+ _array[i].height/2;

            }
            if( i ==6){

                _array[i].y =  _array[3].y+ _array[3].height/2+ _array[i].height/2;

            }
            if(i== 4|| i ==5 ){

                _array[i].y =  _array[3].y;

            }
            if(i== 7|| i ==8 ){

                _array[i].y =  _array[6].y;

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




    }


}
