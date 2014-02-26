package com.knowledgeplayers.grar.display.component;

import flash.display.GradientType;
import flash.geom.Matrix;
import flash.display.Shape;
import flash.display.BitmapData;
import com.knowledgeplayers.grar.display.component.container.SimpleBubble;
import com.knowledgeplayers.grar.util.ParseUtils;
import aze.display.TilesheetEx;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import openfl.Assets;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.DisplayUtils;
import flash.display.Bitmap;
import haxe.xml.Fast;

using Lambda;

/**
* Image widget
**/
class Image extends Widget{

	public var bitmap (default, null):Bitmap;

	public function new(?xml: Fast, ?tilesheet: TilesheetEx)
	{
		super(xml);
		if(xml != null){
			createImg(xml, tilesheet);

			if(xml.has.clip){
				var mask = new Shape();
				var clipOrigin = ParseUtils.parseFloatArray(xml.att.clip, ";");
				for(i in 0...numChildren){
					getChildAt(i).x -= clipOrigin[0];
					getChildAt(i).y -= clipOrigin[1];
				}
				mask.graphics.beginFill(0);
				mask.graphics.drawRect(0, 0, Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height));
				mask.graphics.endFill();
				this.mask = mask;
				addChild(mask);
			}
			else{
				if(xml.has.width)
					width = Std.parseFloat(xml.att.width);
				if(xml.has.height)
					height = Std.parseFloat(xml.att.height);
			}
		}
	}

    public function setBmp(_bmpData:String):Void
    {
         if(_bmpData.indexOf(".")<0){
             var stringColor = ParseUtils.parseStringArray(_bmpData);
             var colors = new Array<Int>();
             var alphas = new Array<Float>();
             for(color in stringColor){
                 var c = ParseUtils.parseColor(color);
                 colors.push(c.color);
                 alphas.push(c.alpha);
             }
             var w = width;
             var h = height;
             while(numChildren>0)
	             removeChildAt(numChildren-1);

             addChild(DisplayUtils.initGradientSprite(w, h, colors, alphas));

         }
         else{
            if (bitmap == null){
                bitmap = new Bitmap();
                addChild(bitmap);
            }
            #if flash
                bitmap.bitmapData = AssetsStorage.getBitmapData(_bmpData);
            #else
                bitmap.bitmapData = Assets.getBitmapData(_bmpData);
            #end
         }
    }

	private function createImg(xml:Fast, ?tilesheet: TilesheetEx):Void
	{
		if(xml.has.src){
			if(xml.has.vertices){
				var vertices = new List<Point2D>();
				ParseUtils.parseStringArray(xml.att.vertices).iter(function(vertex: String){
					var v = vertex.split(";");
					vertices.add({x: Std.parseFloat(v[0]), y: Std.parseFloat(v[1])});
				});
				var shape = new Shape();
				if(xml.att.src.indexOf(",") < 0){
					var color = ParseUtils.parseColor(xml.att.src);
					shape.graphics.beginFill(color.color, color.alpha);
				}
				else{
					var stringColor = ParseUtils.parseStringArray(xml.att.src);
					var colors = new Array<Int>();
					var alphas = new Array<Float>();
					for(color in stringColor){
						var c = ParseUtils.parseColor(color);
						colors.push(c.color);
						alphas.push(c.alpha);
					}
					var matrix:Matrix = new Matrix();
					matrix.createGradientBox(width, height, Math.PI/2, 0, 0);
					shape.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, [0x00, 0xFF], matrix);
				}
				var origin = vertices.pop();
				shape.graphics.moveTo(origin.x, origin.y);
				while(!vertices.isEmpty()){
					var next = vertices.pop();
					shape.graphics.lineTo(next.x, next.y);
				}
				// Close polygon
				shape.graphics.lineTo(origin.x, origin.y);
				shape.graphics.endFill();
				addChild(shape);
			}
			else if(xml.has.radius){
				var stringColor = ParseUtils.parseStringArray(xml.att.src);
				var colors = new Array<Int>();
				var alphas = new Array<Float>();
				for(color in stringColor){
					var c = ParseUtils.parseColor(color);
					colors.push(c.color);
					alphas.push(c.alpha);
				}
				var radius = ParseUtils.parseFloatArray(xml.att.radius);
				if(xml.has.width && xml.has.height){
					ParseUtils.formatToFour(radius);
					addChild(new SimpleBubble(Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height), colors, radius,alphas));
				}
				else{
					addChild(DisplayUtils.drawElipse(colors, alphas, radius));
				}
			}
			else if(xml.att.src.indexOf(".") < 0)
            {
	            var stringColor = ParseUtils.parseStringArray(xml.att.src);
	            var colors = new Array<Int>();
	            var alphas = new Array<Float>();
	            for(color in stringColor){
		            var c = ParseUtils.parseColor(color);
		            colors.push(c.color);
		            alphas.push(c.alpha);
	            }
                addChild(DisplayUtils.initGradientSprite(Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height), colors, alphas));
            }else{
                #if flash
	                bitmap = new Bitmap(AssetsStorage.getBitmapData(xml.att.src));
	            #else
                    bitmap = new Bitmap(Assets.getBitmapData(xml.att.src));
                #end
                addChild(bitmap);
            }


		}
		else{
			bitmap = new Bitmap(DisplayUtils.getBitmapDataFromLayer(tilesheet != null ?tilesheet : UiFactory.tilesheet, xml.att.tile));
			if(bitmap != null)
				addChild(bitmap);
		}

		if(xml.has.mirror){
			mirror = switch(xml.att.mirror.toLowerCase()){
				case "horizontal": 1;
				case "vertical": 2;
				case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
			}
		}
        if(bitmap != null){
            if(xml.has.smoothing){
                bitmap.smoothing = xml.has.smoothing ? xml.att.smoothing == "true" : true;
            }
            else{
                bitmap.smoothing = true;
            }
        }
	}
}

typedef Point2D = {
	var x: Float;
	var y: Float;
}
