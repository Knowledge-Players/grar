package com.knowledgeplayers.grar.display.element;


/**
 * Graphic representation of a token of the game
 */

import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.factory.UiFactory;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.util.LoadData;
import nme.Lib;
import haxe.xml.Fast;
import aze.display.TileSprite;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import nme.display.Sprite;

class TokenDisplay extends Sprite {


    public var showToken:String;
    public var hideToken:String;


    private var layer:TileLayer;
    private var img:TileSprite;

/**
* Images of the different tokens
**/
    public var imgsToken:Hash<Bitmap>;
/**
* Texts of the different tokens
**/
    public var textsToken:Hash<ScrollPanel>;

    public function new(spritesheet:TilesheetEx, tileId:String,_x:Float,_y:Float,_scale:Float,_transitionIn:String,_transitionOut:String,nodes:Fast)
    {
        super();
        this.x = _x;
        this.y = _y;
        layer = new TileLayer(spritesheet);
        img = new TileSprite(tileId);
        imgsToken = new Hash<Bitmap>();
        textsToken = new Hash<ScrollPanel>();
        img.scale = _scale;
        showToken = _transitionIn;
        hideToken = _transitionOut;

        layer.addChild(img);
        addChild(layer.view);
        layer.render();


        for (node in nodes.elements)
            {
                //Lib.trace("img : "+img.att.src);
                switch(node.name.toLowerCase())
                {
                    case "img":
                        var image:Bitmap = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(node.att.src), Bitmap).bitmapData);
                        image.x = Std.parseFloat(node.att.x);
                        image.y = Std.parseFloat(node.att.y);
                        image.scaleX = Std.parseFloat(node.att.scale);
                        image.scaleY = Std.parseFloat(node.att.scale);
                        image.visible = false;
                        imgsToken.set(node.att.ref,image);
                        addChild(image);

                    case "text":
                        var txt:ScrollPanel  =UiFactory.createTextFromXml(node);
                        //var content = Localiser.instance.getItemContent(node.att.ref);
                        //txt.content = KpTextDownParser.parse(content);

                        textsToken.set(node.att.ref,txt);
                        addChild(txt);

                }


            }

    }
    public function setImage(_key:String):Void
    {
        imgsToken.get(_key).visible = true;
    }

    public function setScale(scale:Float):Float
    {
        img.scale = scale;
        layer.render();
        return scale;
    }

}