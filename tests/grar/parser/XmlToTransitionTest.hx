package grar.parser;

import utest.Assert;
import haxe.Resource;

class XmlToTransitionTest{

	private var transitionXml:Xml;

	public function new(){

	}

	// Exhume if we use transition again
	/*public function setup():Void
	{
		transitionXml = Xml.parse(Resource.getString('goodTransition'));
	}

	public function testParse():Void
	{
		var transitions = XmlToTransition.parse(transitionXml);
		var zoom = transitions.get("dezoom");
		Assert.equals(100, zoom.duration);
		Assert.equals("cubic", zoom.easingType);
		Assert.equals("out", zoom.easingStyle);
		Assert.equals(0, zoom.delay);
		Assert.isNull(zoom.repeat);
		Assert.isNull(zoom.reflect);

		var fade = transitions.get("fadeIn");
		Assert.equals(0.5, fade.duration);
		Assert.equals("cubic", fade.easingType);
		Assert.equals("out", fade.easingStyle);
		Assert.equals(1, fade.delay);
		Assert.isNull(fade.repeat);
		Assert.isNull(fade.reflect);

		var transform = transitions.get("stopBlink");
		Assert.equals(0.8, transform.duration);
		Assert.equals("expo", transform.easingType);
		Assert.equals("in", transform.easingStyle);
		Assert.equals(0, transform.delay);
		Assert.equals("0", transform.repeat);
		Assert.isNull(transform.reflect);

		var slide = transitions.get("movePersoLeft");
		Assert.equals(10, slide.duration);
		Assert.equals("quart", slide.easingType);
		Assert.equals("out", slide.easingStyle);
		Assert.equals(0, slide.delay);
		Assert.isNull(slide.repeat);
		Assert.isTrue(slide.reflect);

		for(t in transitions)
			switch(t.type){
				case Zoom(x, y, width, height):
					Assert.equals("x:x-50", x);
					Assert.equals("y:y-50", y);
					Assert.equals("width:width*0.8", width);
					Assert.equals("height:height*0.8", height);
				case Fade(alpha):
					Assert.equals("0:1", alpha);
				case Slide(x, y):
					Assert.equals("x-50:x", x);
					Assert.equals("y", y);
				case Rotate(x, y, r): null;
				case Transform(color):
					Assert.equals(0xFFFFFF, color.color);
					Assert.equals(0, color.alpha);
				case Mask(transitions, chaining): null;
			}
	}*/
}