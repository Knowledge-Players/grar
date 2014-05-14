package grar.model.contextual;

typedef LevelData = {

	var name : String;
	var id : String;
	@:optional var icon : Null<String>;
	@:optional var items : Null<Array<LevelData>>;
	@:optional var partName : String;
}

typedef MenuData = {
	var levels : Array<LevelData>;
	var ref: String;
	var title: String;
}