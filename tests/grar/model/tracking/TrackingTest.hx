package grar.model.tracking;

import utest.Assert;
import grar.model.tracking.Tracking.TrackingType;

class TrackingTest{

	public function new(){

	}

	var tracking: Tracking;
	static var lessonStatusTest = "test";

	public function setup():Void
	{
		tracking = new Tracking(true,  "", "", null, null, null, null, null, TrackingType.Scorm(false, "", ""));
	}

	public function testGetStatus():Void
	{
		// Préparation
		tracking.lessonStatus = lessonStatusTest;

		// Execution
		var result = tracking.getStatus();

		// Verification
		Assert.equals(lessonStatusTest, result);
	}
}