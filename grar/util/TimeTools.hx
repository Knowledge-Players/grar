package grar.util;

class TimeTools {

	/**
	 * Formats time in seconds in HH:MM:SS
	 */
	static public function getFormatTime(time : Int) : String {

		var output : StringBuf = new StringBuf();
		//var time:Int = timer.currentCount - startTime;
		var hours : Int = Math.floor(time / 3600);
		var minutes : Int = Math.floor((time - (hours * 3600)) / 60);
		var seconds : Int = (time - (hours * 3600)) - (minutes * 60);
		
		if (hours < 10) {
		
			output.add("0");
		}
		output.add(hours + ":");
		
		if (minutes < 10) {
		
			output.add("0");
		}
		output.add(minutes + ":");
		
		if (seconds < 10) {

			output.add("0");
		}
		output.add(seconds);
		
		return output.toString();
	}
}