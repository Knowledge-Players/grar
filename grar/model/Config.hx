package grar.model;

/**
 * Stores the original configuration at startup.
 */
class Config {

	static inline var VARNAME_STRUCTURE_FILE_URI : String = "structureUri";
	static inline var VARNAME_BITRATE : String = "bitrate";
	static inline var VARNAME_ISMOBILE : String = "isMobile";
	static inline var VARNAME_ROOT_URI : String = "rootUri";
	static inline var VARNAME_UA_NAME: String = "userAgentName";
	static inline var VARNAME_UA_VERSION: String = "userAgentVersion";

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
	* User agen name
	**/
	public var userAgentName (default, null):String;

	/**
	* User agent version
	**/
	public var userAgentVersion (default, null):String;

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

			case VARNAME_UA_NAME:
				userAgentName = value;

			case VARNAME_UA_VERSION:
				userAgentVersion = value;

			default:

				trace("unknown config parameter: "+key);
		}
	}
}
@:enum
abstract Navigator(String) from String to String{
	var CHROME = "Chrome";
	var FIREFOX = "Firefox";
	var SAFARI = "Safari";
	var IE = "IE";
	var OTHER = "Other";
}