package com.knowledgeplayers.grar.tracking;

import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.display.GameManager;

class StateInfos {
	public var currentLanguage (default, default):String;
	public var bookmark (default, default):Int = -1;
	public var checksum (default, default):Int;

	private var completion:Hash<Int>;
	private var completionOrdered:Array<String>;
	private var allItem:Array<Trackable>;

	public function new()
	{
		completion = new Hash<Int>();
		completionOrdered = new Array<String>();
		allItem = GameManager.instance.game.getAllItems();
	}

	public function loadStateInfos(state:String):Void
	{
		var stateInfosArray:Array<String> = state.split("@");
		currentLanguage = stateInfosArray[0];
		bookmark = Std.parseInt(stateInfosArray[1]);

		var trackable:Array<String> = stateInfosArray[2].split("-");
		for(i in 0...trackable.length){
			if(i < allItem.length){
				completion.set(allItem[i].id, Std.parseInt(trackable[i]));
				completionOrdered.push(allItem[i].id);
			}
		}

		checksum = Std.parseInt(stateInfosArray[3]);
	}

	public function saveStateInfos():String
	{
		var stringBuf:StringBuf = new StringBuf();
		stringBuf.add(currentLanguage);
		stringBuf.add("@");
		stringBuf.add(bookmark);
		stringBuf.add("@");
		stringBuf.add(completionString());
		stringBuf.add("@");
		stringBuf.add(checksum);

		return stringBuf.toString();
	}

	public function setPartFinished(partId:String):Void
	{
		completion.set(partId, 1);
	}

	public function isPartFinished(partId:String):Bool
	{
		return completion.get(partId) == 1;
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
}