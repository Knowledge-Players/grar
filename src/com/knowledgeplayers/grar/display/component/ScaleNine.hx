package com.knowledgeplayers.grar.display.component;
import nme.display.DisplayObject;
import com.knowledgeplayers.grar.util.ScaleNineGrid;
import nme.Lib;
import nme.events.Event;
import aze.display.TileGroup;
import aze.display.TileSprite;
import aze.display.TileLayer;
import aze.display.SparrowTilesheet;
import nme.display.Sprite;
class ScaleNine extends Sprite {

    private var spriteSheet:SparrowTilesheet;
    public function new() {
        super();
        }
    public function init(_spritesheet: SparrowTilesheet) {

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
        var scaleNineGrid:ScaleNineGrid = new ScaleNineGrid(3,3);
        addChild(scaleNineGrid.container);

        for ( i in 0...arrayTile.length){
            tileGroup.addChild(arrayTile[i]);

        }

        layer.addChild(tileGroup);
        scaleNineGrid.container.addChild(layer.view);

        for ( j in 1...arrayTile.length){

            scaleNineGrid.addTile(arrayTile[j-1],arrayTile[j]);
        }

        layer.render();


        this.dispatchEvent(new Event("onScaleInit",true));



    }

}
