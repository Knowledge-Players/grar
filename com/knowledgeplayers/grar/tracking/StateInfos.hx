package com.knowledgeplayers.grar.tracking;

import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.display.GameManager;

class StateInfos {

	public var currentLanguage (default, default):String;
	public var bookmark (default, default):Int = -1;
	public var checksum (default, default):Int;
	public var tmpState (default, null): String;

	private var activityData:Map<String, String>;
	private var completion:Map<String, Int>;
	private var completionOrdered:Array<String>;
	private var allItem:Array<Trackable>;

	private var save:Map<String, String>;

	public function new()
	{
		completion = new Map<String, Int>();
		completionOrdered = new Array<String>();
		save = new Map<String, String>();
	}

	public function loadStateInfos(state:String):Void
	{
		allItem = GameManager.instance.game.getAllItems();
		var stateInfosArray:Array<String> = state.split("@");
		currentLanguage = stateInfosArray[0];
		bookmark = Std.parseInt(stateInfosArray[1]);

		var trackable:Array<String> = stateInfosArray[2].split("-");

		if(allItem.length > 0){
            while(allItem.length > trackable.length)
                trackable.push("0");
			for(i in 0...trackable.length){
				if(i < allItem.length){
					completion.set(allItem[i].id, Std.parseInt(trackable[i]));
					completionOrdered.push(allItem[i].id);
				}
			}
			var sParts:Array<String> = stateInfosArray[3].split("-");

			for(partID in sParts){
				var p = GameManager.instance.game.getPart(partID);
				if (p!=null)
					NotebookDisplay.instance.stockPart(p);
			}
			if(stateInfosArray.length > 4)
				activityData = ParseUtils.parseHash(stateInfosArray[4]);
		}
		else{
			tmpState = state;
		}

		checksum = Std.parseInt(stateInfosArray[3]);
	}

    /*public function initTrackable():Array<String>
    {
        var a:Array<String> = new Array<String>();
        allItem = GameManager.instance.game.getAllItems();
        for(i in 0...allItem.length){
            a.push("0");
        }
        return a;
    }*/

	public function saveStateInfos():String
	{
		var stringBuf:StringBuf = new StringBuf();
		stringBuf.add(currentLanguage);
		stringBuf.add("@");
		stringBuf.add(bookmark);
		stringBuf.add("@");
		stringBuf.add(completionString());
		stringBuf.add("@");
		stringBuf.add(stockedParts());
		stringBuf.add("@");
		stringBuf.add(activityData);
		stringBuf.add("@");
		stringBuf.add(checksum);

		return stringBuf.toString();
	}

	/**
	* Concatene data for the activity
	* @param idActivity: Id of the activity
	* @param data: data to add for this activity
	* @param separator: string between 2 added data
	**/
	public function storeActivityData(idActivity:String, data:String, separator: String = "-"):Void
	{
		if(activityData.exists(idActivity))
			activityData[idActivity] = activityData[idActivity]+data;
		else
			activityData[idActivity] = data;
	}

	/**
	* Fetch data for the activity
	* @param idActivity: Id of the activity
	* @return data for this activity
	**/
	public function getActivityData(idActivity:String):Null<String>
	{
		return activityData[idActivity];
	}

    public function setPartStarted(partId:String):Void
    {
        completion.set(partId, 1);
    }

	public function setPartFinished(partId:String):Void
	{
		completion.set(partId, 2);
	}

    public function isPartStarted(partId:String):Bool
    {
        return completion.get(partId) == 1;
    }

	public function isPartFinished(partId:String):Bool
	{
		return completion.get(partId) == 2;
	}

	public function isEmpty():Bool
	{
		return (currentLanguage == null && bookmark == -1 && completionOrdered.length == 0);
	}

	public function toString():String
	{
		return saveStateInfos();
	}

	// Privates

	private function completionString():String
	{
		var buffer = new StringBuf();
		for(i in 0...completionOrdered.length){
			buffer.add(completion.get(completionOrdered[i]));
			if(i != completionOrdered.length - 1)
				buffer.add("-");
		}
		return buffer.toString();
	}


	private function stockedParts():String
	{
		var b:Array<String> = new Array<String>();
		for(part in GameManager.instance.game.getAllParts()){
			if (NotebookDisplay.instance.hasPart(part)) {
				b.push(part.id);
				b.push("-");
			}
		}
		b.pop();
		return b.join("");
	}
}