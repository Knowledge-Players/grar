package grar.util;

class MathUtils {

	public static inline function degreeToRad(degree: Float): Float
	{
		return degree * Math.PI/180;
	}

	public static inline function radToDegree(rad:Float):Float
	{
		return rad * 180/Math.PI;
	}
}
