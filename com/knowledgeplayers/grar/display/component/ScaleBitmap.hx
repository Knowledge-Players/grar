package com.knowledgeplayers.grar.display.component;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class ScaleBitmap extends Sprite
{
	private var _canvas:Bitmap;
	private var _originalBitmap:BitmapData;
	private var _scale9Grid:Rectangle;
	//add to class properties
	private var _originalWidth:Float;
	private var _originalHeight:Float;
	private var _scaleX:Float;
	private var _scaleY:Float;

	public var bitmapData(get_bitmapData, set_bitmapData):BitmapData;
	public var bitmapScale9Grid(get_bitmapScale9Grid, set_bitmapScale9Grid):Rectangle;
	public var bitmapScaleX(get_bitmapScaleX, set_bitmapScaleX):Float;
	public var bitmapScaleY(get_bitmapScaleY, set_bitmapScaleY):Float;
	public var bitmapHeight(get_bitmapHeight, set_bitmapHeight):Float;
	public var bitmapWidth(get_bitmapWidth, set_bitmapWidth):Float;

	public function new(bmpData:BitmapData=null, ?pixelSnapping:PixelSnapping, ?smoothing:Bool=false)
	{
		super();
		if (pixelSnapping == null)
		{
			pixelSnapping = PixelSnapping.AUTO;
		}
		_scaleX = _scaleY = 1;
		// canvas
		_canvas = new Bitmap(bmpData, pixelSnapping, smoothing);
		addChild(_canvas);
		// original bitmap
		_originalBitmap=bmpData.clone();
		//add to constructor
		_originalWidth=bmpData.width;
		_originalHeight=bmpData.height;
	}

	private function get_bitmapData():BitmapData
	{
		return _canvas.bitmapData;
	}

	/**
	 * setter bitmapData
	 */
	private function set_bitmapData(bmpData:BitmapData):BitmapData
	{
		_originalBitmap=bmpData.clone();
		_originalWidth=bmpData.width;
		_originalHeight=bmpData.height;
		if(_scale9Grid !=null)
		{
			if(!validGrid(_scale9Grid))
			{
				_scale9Grid=null;
			}
			setSize(bmpData.width, bmpData.height);
		}
		else
		{
			assignBitmapData(_originalBitmap.clone());
		}
		return _originalBitmap;
	}

	/**
	 * setter width
	 */
	private function set_bitmapWidth(w:Float):Float
	{
		if(w !=width)
		{
			setSize(w, height);
		}
		return width;
	}

	private function get_bitmapWidth():Float
	{
		return width;
	}
	/**
	 * setter height
	 */
	private function set_bitmapHeight(h:Float):Float
	{
		if(h !=height)
		{
			setSize(width, h);
		}
		return height;
	}

	private function get_bitmapHeight():Float
	{
		return height;
	}

	/**
	 * set scale9Grid
	 */


	/**
	 * get scale9Grid
	 */
	private function get_bitmapScale9Grid():Rectangle
	{
		return _scale9Grid;
	}

	private function set_bitmapScale9Grid(r:Rectangle):Rectangle
	{
		// Check if the given grid is different from the current one
		if((_scale9Grid==null && r !=null)||(_scale9Grid !=null && !_scale9Grid.equals(r)))
		{
			if(r==null)
			{
				// If deleting scale9Grid, restore the original bitmap
				// then resize it(streched)to the previously set dimensions
				var currentWidth:Float=width;
				var currentHeight:Float=height;
				_scale9Grid=null;
				assignBitmapData(_originalBitmap.clone());
				setSize(currentWidth, currentHeight);
			}
			else
			{
				if(!validGrid(r))
				{
					trace("#001 - The _scale9Grid does not match the original BitmapData");
					return _scale9Grid;
				}
				_scale9Grid=r.clone();
				resizeBitmap(width, height);
				scaleX=1;
				scaleY=1;
			}
		}
		return _scale9Grid;
	}

	/**
	 * assignBitmapData
	 * Update the effective bitmapData
	 */
	private function assignBitmapData(bmp:BitmapData):Void
	{
		_canvas.bitmapData.dispose();
		_canvas.bitmapData=bmp;
	}

	private function validGrid(r:Rectangle):Bool
	{
		return r.right<=_originalBitmap.width && r.bottom<=_originalBitmap.height;
	}

	/**
	 * setSize
	 */
	public function setSize(w:Float, h:Float):Void
	{
		if(_scale9Grid==null)
		{
			width=w;
			height=h;
		}
		else
		{
			w=Std.int(Math.max(w, _originalBitmap.width - _scale9Grid.width));
			h=Std.int(Math.max(h, _originalBitmap.height - _scale9Grid.height));
			resizeBitmap(w, h);
		}
	}

	/**
	 * get original bitmap
	 */
	public function getOriginalBitmapData():BitmapData
	{
		return _originalBitmap;
	}

	private function get_bitmapScaleX():Float
	{
		return _scaleX;
	}

	private function set_bitmapScaleX(value:Float):Float
	{
		if(value !=_scaleX)
		{
			_scaleX=value;
			var w:Float=Std.int(_originalWidth * value);
			setSize(w, height);
		}
		return _scaleX;
	}

	private function get_bitmapScaleY():Float
	{
		return _scaleY;
	}

	private function set_bitmapScaleY(value:Float):Float
	{
		if(value !=scaleY)
		{
			_scaleY=value;
			var h:Float=Std.int(_originalHeight * value);
			setSize(width, h);
		}
		return _scaleY;
	}

	// ------------------------------------------------
	//
	// ---o protected methods
	//
	// ------------------------------------------------
	/**
	 * resize bitmap
	 */
	private function resizeBitmap(w:Float, h:Float):Void
	{
		var bmpData:BitmapData=new BitmapData(Std.int(w), Std.int(h), true, 0x00000000);
		var rows:Array<Dynamic>=[0, _scale9Grid.top, _scale9Grid.bottom, _originalBitmap.height];
		var cols:Array<Dynamic>=[0, _scale9Grid.left, _scale9Grid.right, _originalBitmap.width];
		var dRows:Array<Dynamic>=[0, _scale9Grid.top, h -(_originalBitmap.height - _scale9Grid.bottom), h];
		var dCols:Array<Dynamic>=[0, _scale9Grid.left, w -(_originalBitmap.width - _scale9Grid.right), w];
		var origin:Rectangle;
		var draw:Rectangle;
		var mat:Matrix=new Matrix();
		var cx:Int;
		var cy:Int;
		for(cx in 0...3)
		{
			for(cy in 0...3)
			{
				origin=new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
				draw=new Rectangle(dCols[cx], dRows[cy], dCols[cx + 1] - dCols[cx], dRows[cy + 1] - dRows[cy]);
				mat.identity();
				mat.a=draw.width / origin.width;
				mat.d=draw.height / origin.height;
				mat.tx=draw.x - origin.x * mat.a;
				mat.ty=draw.y - origin.y * mat.d;
				bmpData.draw(_originalBitmap, mat, null, null, draw, _canvas.smoothing);
			}
		}
		assignBitmapData(bmpData);
	}
}
