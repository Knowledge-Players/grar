package com.knowledgeplayers.grar.display.activity;
import com.knowledgeplayers.grar.display.activity.quizz.QuizzDisplay;
import nme.Lib;

/**
 * ...
 * @author jbrichardet
 */

class ActivityManager 
{
	public static var instance (getInstance, null): ActivityManager;
	public var activities (default, null): Hash<ActivityDisplay>;
	
	public static function getInstance() : ActivityManager
	{
		if (instance == null)
			return instance = new ActivityManager();
		else
			return instance;
	}
	
	public function getActivity(name: String) : Null<ActivityDisplay>
	{
		var activity: ActivityDisplay = activities.get(name.toLowerCase());
		if (activity == null) {
			switch(name.toLowerCase()) {
				case "quizz": activity = QuizzDisplay.instance;
				default: Lib.trace(name + ": Unsupported activity type");
			}
			if (activity != null)
				activities.set(name.toLowerCase(), activity);
		}
		
		return activity;
	}

	private function new() 
	{
		activities = new Hash<ActivityDisplay>();
	}
	
}