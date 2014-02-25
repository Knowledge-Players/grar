package grar.view;

enum TransitionType {

	Zoom(x:String, y:String, width:String, height:String);
	Fade(alpha:String);
	Slide(x:String, y:String);
	Rotate(x:String, y:String, r:String);
	Transform(color:String);
	Mask(transitions:Array<String>, chaining:String);
}

class TransitionTemplate {

	public function new(d : Float, de : Int, et : Null<String>, es : Null<String>, r : Null<Int>, rf : Null<Bool>, t : TransitionType) {

		this.duration = d;
		this.delay =  de;
		this.easingType = et;
		this.easingStyle = es;
		this.repeat = r;
		this.reflect = rf;
		this.type = t;
	}

	public var duration (default, null) : Float;
    public var delay (default, null) : Int;
    public var easingType (default, null) : Null<String> = null;
    public var easingStyle (default, null) : Null<String> = null;
    public var repeat (default, null) : Null<Int> = null;
    public var reflect (default, null) : Null<Bool> = null;
    public var type (default, null) : TransitionType;
}