package grar.util;

class Point{

	public var x (default, default):Float;
	public var y (default, default):Float;

	public function new(?x: Float = 0, ?y: Float = 0){
		this.x = x;
		this.y = y;
	}

	public function add(point:Point):Point
	{
		x += point.x;
		y += point.y;

		return this;
	}
}