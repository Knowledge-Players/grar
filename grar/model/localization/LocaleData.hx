package grar.model.localization;

//import flash.events.EventDispatcher;

class LocaleData /* extends EventDispatcher */ {

	/**
     * Name of the localisation
     */
	public var name(default, null) : String;

	private var tradHash : Map<String, String>;

	/**
     * Constructor
     * @param	name : Name of the localisation (aka language)
     */
	public function new(name : String, tradHash : Map<String, String>) {

		//super();

		this.tradHash = tradHash;

		this.name = name;
	}

	/**
     * Get the localised text for an item
     * @param	key : key of the item
     * @return the localised text
     */
	public function getItem(key : String) : String {

		return tradHash.get(key);
	}

	public function toString() : String {

		return name + " " + tradHash.toString();
	}
}