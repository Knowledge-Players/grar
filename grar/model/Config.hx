package grar.model;

/**
 * Stores the original configuration at startup.
 */
class Config {

	static inline var VARNAME_STRUCTURE_FILE_URI : String = "structureUri";
	
	public function new() { }

	/**
	 * URI of the structure.xml file at launch, if any.
	 */
	public var structureFileUri(default, null) : Null<String>;

	public function parseConfigParameter(key : String, value : String) : Void {

		switch (key) {

			case VARNAME_STRUCTURE_FILE_URI:

				structureFileUri = value;

			default:

				trace("unknown config parameter: "+key);
		}
	}
}