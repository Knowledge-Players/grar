package grar.model;

enum FilterQuality {

	Low;
	Medium:
	High;
}

enum FilterType {

	DropShadow(distance : Float, angle : Float, color : Int, alpha : Float, blurX : Float, blurY : Float, strength : Float, quality : FilterQuality, inner : Bool, knockout : Bool, hideObject : Bool);
	Blur(blurX : Float, blurY : Float, quality : FilterQuality);
	Glow(color : Int, alpha : Float, blurX : Float, blurY : Float, strength : Float, quality : FilterQuality, inner : Bool, knockout : Bool);
	ColorMatrix(matrix : Array<Float>);
}