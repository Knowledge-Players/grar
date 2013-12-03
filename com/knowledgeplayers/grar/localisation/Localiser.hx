package com.knowledgeplayers.grar.localisation;

import com.knowledgeplayers.grar.display.style.StyleParser;

import com.knowledgeplayers.grar.localisation.Localisation;
import haxe.ds.GenericStack;
import flash.events.EventDispatcher;

/**
 * Singleton manager of the localisation
 */
class Localiser extends EventDispatcher {
	/**
     * Instance of the singleton
     */
	public static var instance (get_instance, null):Localiser;

	/**
     * Current locale
     */
	public var currentLocale (default, set_currentLocale):String;

	/**
     * Hash of all the localisations registred in the localiser
     */
	public var localisations (default, null):Map<String, String>;

	/**
     * Path of the structure file that describes the layout
     */
	public var layoutPath (default, set_layoutPath):String;

	private var introId:String;
	private var outroId:String;
	private var localisation:Localisation;
	private var stashedLocale:GenericStack<Localisation>;
	private var sameLocale:Bool;

	private function new()
	{
		super();
		localisations = new Map<String, String>();
		stashedLocale = new GenericStack<Localisation>();
	}

	/**
     * @return the instance of the singleton
     */

	public static function get_instance():Localiser
	{
		if(instance == null){
			instance = new Localiser();
		}
		return instance;
	}

	/**
     * Setter of the layout file
     * @param	path : Path to the file
     * @return the path
     */

	public function set_layoutPath(path:String):String
	{
		if(path != null){
			if(layoutPath != path){
				pushLocale();
				layoutPath = path;
				setLocalisationFile(path);
				sameLocale = false;
			}
			else
				sameLocale = true;
		}
		else
			layoutPath = path;
		return layoutPath;
	}

	/**
     * Setter of the current locale
     * @param	locale : name of the current locale
     * @return the name of the current locale
     */

	public function set_currentLocale(locale:String):String
	{
		currentLocale = locale;
		StyleParser.currentLocale = currentLocale;
		return currentLocale;
	}

	/**
     * Get the localised text for the specified item
     * @param	key : key of the item
     * @return the localised text
     */

	public function getItemContent(key:String):Null<String>
	{
		if(localisation != null){
			var content = localisation.getItem(key);
			if(content == null)
				content = "UNKNOWN LOCALISATION KEY";
			return content;
		}
		else{
			trace("No locale set. Returning null for key '"+key+"'.");
			return null;
		}
	}

	/**
    * Set File of localisation
    **/

	private function setLocalisationFile(path:String):Void
	{
		var fullPath = path.split("/");

		var localePath:StringBuf = new StringBuf();
		localePath.add(fullPath[0] + "/");
		localePath.add(currentLocale + "/");
		for(i in 1...fullPath.length-1){
			localePath.add(fullPath[i] + "/");
		}
		localePath.add(fullPath[fullPath.length-1]);
		localisation = new Localisation(currentLocale);
		localisation.setLocaleFile(localePath.toString());
	}

	/**
    * Restore the previously stored locale
    **/
	public function popLocale():Void
	{
		if(!sameLocale && !stashedLocale.isEmpty()){
			localisation = stashedLocale.pop();
			layoutPath = null;
		}
	}

	/**
    * Store the current locale
    **/
	private function pushLocale():Void
	{
		if(localisation != null)
			stashedLocale.add(localisation);
	}
}