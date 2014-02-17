package grar.model;

typedef TokenData = {

	var id : String;
	var ref : String;
	var type : Null<String>;
	var isActivated : Bool;
	var name : Null<String>;
	var content : String;
	var icon : String;
	var image : String;
	var fullScreenContent : Null<String>;
}

/**
 * A token that can be earned during parts or activities and stored into the inventory.
 **/
class InventoryToken {

	public function new(? td : Null<TokenData>) : Void {

		if (td != null) {

			this.id = td.id;
			this.ref = td.r;
			this.type = td.t;
			this.isActivated = td.ia;
			this.name = td.n;
			this.content = td.c;
			this.icon = td.i;
			this.image = td.p;
			this.fullScreenContent = td.fsc;
		
		} else {

			this.ref = "undefined";
			this.isActivated = false;
		}
	}

	/**
     * Unique identifier
     **/
	public var id : Null<String> (default, null) = null;

	/**
     * Reference to the display
     **/
	public var ref (default, null) : String;

	/**
     * Type of the token
     **/
	public var type (default, null) : Null<String> = null;

	/**
     * State of activation
     **/
	public var isActivated (default, default) : Bool = false;

	/**
     * Key to the name of this token
     **/
	public var name (default, default) : Null<String> = null;

	/**
     * Content of this token
     **/
	public var content (default, default) : Null<String> = null;

	/**
     * Content of this token when it's fullscreen
     **/
	public var fullScreenContent (default, default) : Null<String> = null;

	/**
     * icon of this token
     **/
	public var icon (default, default) : Null<String> = null;

	/**
     * Image to display when it's fullscreen
     **/
	public var image (default, default) : Null<String> = null;
}