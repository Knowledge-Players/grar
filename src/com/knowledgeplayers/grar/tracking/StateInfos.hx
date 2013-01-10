package com.knowledgeplayers.grar.tracking;

class StateInfos 
{
	public var currentLanguage (default, default): String;
	public var currentActivity (default, default): String;
	public var activityCompletion (default, default): Array<Bool>;
	public var checksum (default, default): Int;

	public function new()
	{
		activityCompletion = new Array<Bool>();
	}

	public function loadStateInfos(state: String) : Void
	{
		var stateInfosArray: Array<String> = state.split("@");
		currentLanguage = stateInfosArray[0];
		currentActivity = stateInfosArray[1];
		
		var activities:Array<String> = stateInfosArray[2].split("-");
		for(activity in activities) {
			activityCompletion.push(activity == "1");
		}

		checksum = Std.parseInt(stateInfosArray[3]);
	}

	public function saveStateInfos() : String
	{
		var stringBuf: StringBuf = new StringBuf();
		stringBuf.add(currentLanguage);
		stringBuf.add("@");
		stringBuf.add(currentActivity);
		stringBuf.add("@");
		stringBuf.add(activityCompletion.join("-"));
		stringBuf.add("@");
		stringBuf.add(checksum);

		return stringBuf.toString();
	}
	
	public function isEmpty() : Bool 
	{
		return (currentLanguage == null && currentActivity == null && activityCompletion.length == 0);
	}

	public function toString() : String
	{
		return saveStateInfos();
	}
}