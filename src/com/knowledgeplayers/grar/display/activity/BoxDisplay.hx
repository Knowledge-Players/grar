package com.knowledgeplayers.grar.display.activity;

import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.display.Bitmap;

import com.knowledgeplayers.grar.structure.activity.Box;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.localisation.Localiser;
import haxe.xml.Fast;
import nme.Lib;
import nme.Assets;
import nme.display.Graphics;

class BoxDisplay extends Sprite
{
    private var resizeD:ResizeManager;
    private var contentDisplay:Fast;
    private var boxBack:Sprite;
    private var box:Box;
    private var maskBG:Sprite;
    private var maskW:Float;
    private var maskH:Float;
    private var bgContainer:Sprite;
    private var displayObjects: Hash<DisplayObject>;


    public function new(box:Box,contentDisplay:Fast):Void
    {
        super();
        this.contentDisplay = contentDisplay;
        this.box = box;
        resizeD = ResizeManager.getInstance();

        parseBox();
    }


    private function parseBox():Void
    {
       backOfTheBox(box.ref);

        for (element in box.items){
           if(element.name =="Background"){
                backgroundOfTheBox(element.att.Ref);
           } 
           if(element.name =="Image"){
              //  imageOfTheBox(element.att.Ref);
           } 
           if(element.name =="Texte"){
              //  textOfTheBox(element.att.Content,element.att.Ref);
           }       
        }

      
    }

      private function constructBox():Void
    {
        
    }

    private function backOfTheBox(?ref:String):Void
    {
      
        for (node in contentDisplay.elements)
        {
           
           
            if (node.att.Ref == ref)
            {
                var back = new Sprite();
               
                var w =  Std.parseFloat(node.att.Width);
                var h =  Std.parseFloat(node.att.Height);
                maskW = w;
                maskH = h;

                back.graphics.beginFill(0xCCCCCC);
                back.graphics.lineStyle(1,0x000000);
                back.graphics.drawRect(0,0,w,h);
                back.graphics.endFill();
                addChild(back);

                maskBG = new Sprite();
                maskBG.graphics.beginFill(0xCCCCCC);
                maskBG.graphics.drawRect(0,0,maskW,maskH);
                maskBG.graphics.endFill();
            }

        }

    }

    private function backgroundOfTheBox(?ref:String):Void{
        bgContainer = new Sprite();
       
        for (node in contentDisplay.elements)
        {
             if (node.att.Ref == ref)
            {
               
                
                var url  =  node.att.Id;
                 var bg: Bitmap = new Bitmap(Assets.getBitmapData(url));
                var w =  Std.parseFloat(node.att.Width);
                var h =  Std.parseFloat(node.att.Height);
                var x =  Std.parseFloat(node.att.X);
                var y =  Std.parseFloat(node.att.Y);
                var z = node.att.z;
                bg.x = x;
                bg.y = y;
                bg.width = w;
                bg.height = h;
                bg.mask = maskBG;
                bgContainer.addChild(bg);
                addChild(bgContainer);
            }
        }
       // displayObjects.set(z, bgContainer);

    }

    private function imageOfTheBox(?ref:String):Void{

         for (node in contentDisplay.elements)
        {
             if (node.att.Ref == ref)
            {
               var maskIMG = new Sprite();
                maskIMG.graphics.beginFill(0xCCCCCC);
                maskIMG.graphics.drawRect(0,0,maskW,maskH);
                maskIMG.graphics.endFill();
                var url  =  node.att.Id;
                 var img: Bitmap = new Bitmap(Assets.getBitmapData(url));
                var w =  Std.parseFloat(node.att.Width);
                var h =  Std.parseFloat(node.att.Height);
                var x =  Std.parseFloat(node.att.X);
                var y =  Std.parseFloat(node.att.Y);
                var z = node.att.z;
                img.x = x;
                img.y = y;
                img.width = w;
                img.height = h;
                img.mask = maskIMG;

                addChild(img);
            }
        }

    }
    private function textOfTheBox(?content:String,?ref:String):Void{

         for (node in contentDisplay.elements)
        {
             if (node.att.Ref == ref)
            {

              
               var maskText = new Sprite();
             
                maskText.graphics.beginFill(0xCCCCCC);
                maskText.graphics.drawRect(0,0,maskW,maskH);
                maskText.graphics.endFill();
                var w =  Std.parseFloat(node.att.Width);
                var h =  Std.parseFloat(node.att.Height);
                var x =  Std.parseFloat(node.att.X);
                var y =  Std.parseFloat(node.att.Y);

                var text = new ScrollPanel(w, h);
                var txt = Localiser.getInstance().getItemContent(content);
                Lib.trace("txt :  "+txt);
                text.content = KpTextDownParser.parse(txt);
                //text.background = node.att.Background;
                text.x = x;
                text.y = y;
                var textContainer = new Sprite();
                textContainer.addChild(text);
                textContainer.mask = maskText;

                addChild(textContainer);
            }
        }

    }



}