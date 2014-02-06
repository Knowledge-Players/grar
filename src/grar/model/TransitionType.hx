package grar.model;

enum TransitionType {

	Zoom(x:String, y:String, width:String, height:String);
	Fade(alpha:String);
	Slide(x:String, y:String);
	Rotate(x:String, y:String, r:String);
	Transform(color:String);
	Mask(transitions:Array<String>, chaining:String);
}