package grar.model;

/**
 * Stores the original configuration at startup.
 */
class Config {

	static inline var VARNAME_STRUCTURE_FILE_URI : String = "structureUri";
	static inline var VARNAME_BITRATE : String = "bitrate";
	static inline var VARNAME_ISMOBILE : String = "isMobile";
	static inline var VARNAME_ROOT_URI : String = "rootUri";

	public function new() { }

	/**
	 * URI of the structure.xml file at launch, if any.
	 */
	public var structureFileUri(default, null) : String = "structure.xml";

	/**
	* Bitrate of the client. Use mostly by video player
	**/
	public var bitrate(default, null) : Float = 350;

	/**
	* Whether the app is on mobile or not
	**/
	public var isMobile (default, null): Bool = false;

	/**
	* URI of the module. Default is the same as the iframe.
	**/
	public var rootUri (default, null):String;

	public function parseConfigParameter(key : String, value : String) : Void {

		switch (key) {

			case VARNAME_STRUCTURE_FILE_URI:

				structureFileUri = value;

			case VARNAME_BITRATE:

				bitrate = Std.parseFloat(value);

			case VARNAME_ISMOBILE:
				isMobile = value == "true";

			case VARNAME_ROOT_URI:
				rootUri = value;

			default:

				trace("unknown config parameter: "+key);
		}
	}
}