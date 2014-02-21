package grar.view.component;

import openfl.Assets;

import aze.display.TilesheetEx;

import com.knowledgeplayers.grar.display.component.container.SimpleBubble;
//import com.knowledgeplayers.grar.factory.UiFactory; // FIXME
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.util.DisplayUtils;

import com.knowledgeplayers.utils.assets.AssetsStorage;

import flash.geom.Matrix;
import flash.display.Bitmap;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.BitmapData;

import haxe.xml.Fast;

using Lambda;

typedef Point2D = {

	var x: Float;
	var y: Float;
}

typedef ImageData = {

	var wd : WidgetData;
	var src : Null<String> = f.has.src ? f.att.src : null;
	var vertices : Null<List<Point2D>> = null;
	var radius : Null<Array<Float>> = null;
	var height : Null<Float> = null;
	var width : Null<Float> = null;
	var smoothing : Bool = true;
	var mirror : Null<Int> = null;
	var clipOrigin : Null<Array<Float>> = null;
	var tilesheetRef : Null<String> = null;
	var tilesheet : Null<TilesheetEx> = null; // set in second step (instanciation)
	var tile : Null<String> = null;
}

/**
 * Image widget
 **/
class Image extends Widget {

	public var bitmap (default, null) : Bitmap;

	//public function new( ? xml : Fast, ? tilesheet : TilesheetEx ) {
	public function new( id : ImageData ) {

		super(id.wd);

		createImg(id);

		if (id.clipOrigin != null) {

			var mask = new Shape();
			
			for (i in 0...numChildren) {

				getChildAt(i).x -= clipOrigin[0];
				getChildAt(i).y -= clipOrigin[1];
			}
			mask.graphics.beginFill(0);
			mask.graphics.drawRect(0, 0, id.width, id.height);
			mask.graphics.endFill();
			this.mask = mask;
			addChild(mask);
		
		} else {

			if (id.width != null) {

				width = id.width;
			}
			if (id.height != null) {

				height = id.height;
			}
		}
	}


	///
	// API
	//

    public function setBmp(_bmpData : String) : Void
    {
         if(_bmpData.indexOf(".")<0){
             var stringColor = ParseUtils.parseListOfValues(_bmpData);
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


    ///
    // INTERNALS
    //

	private function createImg(id : ImageData) : Void {

		if (id.src != null) {

			if (id.vertices != null) {
				
				var shape = new Shape();
				
				if (id.src.indexOf(",") < 0) {

					var color = ParseUtils.parseColor(id.src);
					shape.graphics.beginFill(color.color, color.alpha);
				
				} else {

					var stringColor = ParseUtils.parseListOfValues(id.src);
					var colors = new Array<Int>();
					var alphas = new Array<Float>();
					
					for (color in stringColor) {

						var c = ParseUtils.parseColor(color);
						colors.push(c.color);
						alphas.push(c.alpha);
					}
					var matrix : Matrix = new Matrix();
					matrix.createGradientBox(width, height, Math.PI/2, 0, 0);
					shape.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, [0x00, 0xFF], matrix);
				}
				var origin = vertices.pop();
				shape.graphics.moveTo(origin.x, origin.y);
				
				while (!vertices.isEmpty()) {

					var next = vertices.pop();
					shape.graphics.lineTo(next.x, next.y);
				}
				// Close polygon
				shape.graphics.lineTo(origin.x, origin.y);
				shape.graphics.endFill();
				addChild(shape);
			
			} else if (id.radius != null) {

				var stringColor = ParseUtils.parseListOfValues(id.src);
				var colors = new Array<Int>();
				var alphas = new Array<Float>();
				
				for (color in stringColor) {

					var c = ParseUtils.parseColor(color);
					colors.push(c.color);
					alphas.push(c.alpha);
				}
				
				if (id.width != null && id.height != null) {

					ParseUtils.formatToFour(id.radius);
					addChild(new SimpleBubble(id.width, id.height, colors, id.radius, alphas));
				
				} else {

					addChild(DisplayUtils.drawElipse(colors, alphas, id.radius));
				}

			} else if(id.src.indexOf(".") < 0) {

	            var stringColor = ParseUtils.parseListOfValues(id.src);
	            var colors = new Array<Int>();
	            var alphas = new Array<Float>();
	            
	            for (color in stringColor) {

		            var c = ParseUtils.parseColor(color);
		            colors.push(c.color);
		            alphas.push(c.alpha);
	            }
                addChild(DisplayUtils.initGradientSprite(id.width, id.height, colors, alphas));
            
            } else {
#if flash
                bitmap = new Bitmap(AssetsStorage.getBitmapData(id.src));
#else
                bitmap = new Bitmap(Assets.getBitmapData(id.src));
#end
                addChild(bitmap);
            }
		
		} else {
// FIXME
			bitmap = new Bitmap(DisplayUtils.getBitmapDataFromLayer(id.tilesheet != null ? id.tilesheet : /* UiFactory.tilesheet */ null, id.tile));
			
			if (bitmap != null) {

				addChild(bitmap);
			}
		}
        if (bitmap != null) {

            bitmap.smoothing = id.smoothing;
        }
	}
}