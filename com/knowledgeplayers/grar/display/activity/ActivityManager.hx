package com.knowledgeplayers.grar.display.activity;

import com.knowledgeplayers.grar.display.activity.cards.CardsDisplay;
import com.knowledgeplayers.grar.display.activity.folder.FolderDisplay;
import com.knowledgeplayers.grar.display.activity.quiz.QuizDisplay;
import com.knowledgeplayers.grar.display.activity.scanner.ScannerDisplay;

/**
 * Manager of the activity, store all the activity display for a game
 */
class ActivityManager {
	/**
     * Instance
     */
	public static var instance (get_instance, null):ActivityManager;

	/**
     * Hash of all the activities displays
     */
	public var activities (default, null):Map<String, ActivityDisplay>;

	/**
     * @return the instance
     */

	public static function get_instance():ActivityManager
	{
		if(instance == null)
			return instance = new ActivityManager();
		else
			return instance;
	}

	/**
     * Return the requested activity display
     * @param	name : Name of the activity
     * @return the display for this activity
     */

	public function getActivity(name:String):Null<ActivityDisplay>
	{
		var activity:ActivityDisplay = activities.get(name.toLowerCase());
		if(activity == null){
			switch(name.toLowerCase()) {

				case "quiz": activity = QuizDisplay.instance;
				case "scanner": activity = ScannerDisplay.instance;
				case "folder": activity = FolderDisplay.instance;
				case "cards": activity = CardsDisplay.instance;

				default: trace(name + ": Unsupported activity type");
			}
			if(activity != null)
				activities.set(name.toLowerCase(), activity);
		}

		return activity;
	}

	private function new()
	{
		activities = new Map<String, ActivityDisplay>();
	}

}