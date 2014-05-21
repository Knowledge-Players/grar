package grar.view.contextual;

typedef Element = String;

enum ItemStatus {
	TODO;
	STARTED;
	DONE;
}

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

	public function close():Void
	{}
	public function open():Void
	{}


	public function setItemStatus(itemId: String, status: ItemStatus):Void
	{}

	dynamic public function onLevelClick(l):Void
	{

	}

	public function setCurrentItem(id:String):Void
	{

	}

	public function setGameOver():Void
	{
	}

	dynamic public function onCloseMenuRequest():Void {}
	dynamic public function onOpenMenuRequest():Void {}
}