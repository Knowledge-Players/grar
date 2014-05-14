package grar.view.contextual;

import grar.model.contextual.MenuData;
typedef Element = String;

class MenuDisplay extends BaseDisplay{

	public var ref (default, set):String;

	private var root:Element;

	public function new(){
		super();
	}

	public function set_ref(ref: String):String
	{
		return this.ref = ref;
	}

	public function setTitle(title:String, ?ref:String = "title"):Void
	{

	}

	public function initLevels(l:Array<LevelData>):Void
	{

	}
	public function close():Void
	{}

	dynamic public function onLevelClick(l):Void
	{

	}
	dynamic public function onCloseMenuRequest():Void {}
}