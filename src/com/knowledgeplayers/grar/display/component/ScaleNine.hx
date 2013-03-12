package com.knowledgeplayers.grar.display.component;
import aze.display.TilesheetEx;
import nme.display.DisplayObject;
import com.knowledgeplayers.grar.util.ScaleNineGrid;
import nme.Lib;
import nme.events.Event;
import aze.display.TileGroup;
import aze.display.TileSprite;
import aze.display.TileLayer;
import nme.display.Sprite;
class ScaleNine extends Sprite {

    private var spriteSheet:TilesheetEx;
    private var bkg_width:Float;
    private var bkg_height:Float;
    public var middleTile:TileSprite;

    public function new(w:Float = 0, h:Float = 0)
    {
        super();
        bkg_width = w;
        bkg_height = h;

    }

    public function init(_spritesheet:TilesheetEx)
    {

        spriteSheet = _spritesheet;

        var arrayTile:Array<TileSprite> = new Array<TileSprite>();

        var layer = new TileLayer(spriteSheet);

        var img1 = new TileSprite("haut_gauche");
        var img2 = new TileSprite("haut");
        var img3 = new TileSprite("haut_droit");

        var img4 = new TileSprite("gauche");
        var img5 = new TileSprite("milieu");
        var img6 = new TileSprite("droit");

        var img7 = new TileSprite("bas_gauche");
        var img8 = new TileSprite("bas");
        var img9 = new TileSprite("bas_droit");

        arrayTile.push(img1);
        arrayTile.push(img2);
        arrayTile.push(img3);
        arrayTile.push(img4);
        arrayTile.push(img5);
        arrayTile.push(img6);
        arrayTile.push(img7);
        arrayTile.push(img8);
        arrayTile.push(img9);

        var tileGroup = new TileGroup();

        var scaleNineGrid:ScaleNineGrid = new ScaleNineGrid(3, 3);

        addChild(scaleNineGrid.container);

        for(i in 0...arrayTile.length){
            tileGroup.addChild(arrayTile[i]);

        }

        layer.addChild(tileGroup);

        scaleNineGrid.container.addChild(layer.view);

        for(j in 0...arrayTile.length){

            //scaleNineGrid.addTile(arrayTile[j]);
        }
        scaleNineGrid.initMatrice(arrayTile, bkg_width, bkg_height);

        middleTile = img5;

        /*img1.x = 0;
        img2.x = img1.x+img1.width/2+img2.width/2;
        img3.x = img2.x+img2.width/2+img3.width/2;

        img4.x = 0;
        img5.x = img4.x+img4.width/2+img5.width/2;
        img6.x = img5.x+img5.width/2+img6.width/2;

        img7.x = 0;
        img8.x = img7.x+img7.width/2+img8.width/2;
        img9.x = img8.x+img8.width/2+img9.width/2;

        img1.y = 0;
        img2.y = 0;
        img3.y = 0;

        img4.y = img1.y+img1.height/2+img4.height/2;
        img5.y = img4.y;
        img6.y = img4.y;

        img7.y = img4.y+img4.height/2+img7.height/2;
        img8.y = img7.y;
        img9.y = img7.y;

        */

        layer.render();

        this.dispatchEvent(new Event("onScaleInit", true));
    }

}
