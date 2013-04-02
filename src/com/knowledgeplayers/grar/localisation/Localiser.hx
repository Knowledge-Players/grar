package com.knowledgeplayers.grar.localisation;

import nme.Lib;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.localisation.Localisation;
import nme.events.Event;
import nme.events.EventDispatcher;

import haxe.xml.Fast;

/**
 * Singleton manager of the localisation
 */
class Localiser extends EventDispatcher {
    /**
     * Instance of the singleton
     */
    public static var instance (getInstance, null):Localiser;

    /**
     * Current locale
     */
    public var currentLocale (default, setCurrentLocale):String;

    /**
     * Hash of all the localisations registred in the localiser
     */
    public var localisations (default, null):Hash<String>;

    /**
     * Path of the structure file that describes the layout
     */
    public var layoutPath (default, setLayoutFile):String;

    private var introId:String;
    private var outroId:String;
    private var localisation:Localisation;
    private var stashedLocale:Localisation;

    private function new()
    {
        super();
        localisations = new Hash<String>();
    }

    /**
     * @return the instance of the singleton
     */

    public static function getInstance():Localiser
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

    public function setLayoutFile(path:String):String
    {
        layoutPath = path;
        setLocalisationFile(path);
        return layoutPath;
    }

    /**
     * Setter of the current locale
     * @param	locale : name of the current locale
     * @return the name of the current locale
     */

    public function setCurrentLocale(locale:String):String
    {
        currentLocale = locale;
        return currentLocale;
    }

    /**
     * Get the localised text for the specified item
     * @param	key : key of the item
     * @return the localised text
     */

    public function getItemContent(key:String):Null<String>
    {
        if(localisation != null)
            return localisation.getItem(key);
        else{
            nme.Lib.trace("No locale set. Returning null");
            return null;
        }
    }

    /**
    * Set File of localisation
    **/

    public function setLocalisationFile(path:String):Void
    {
        var fullPath = path.split("/");

        var localePath:StringBuf = new StringBuf();
        for(i in 0...fullPath.length - 1){
            localePath.add(fullPath[i] + "/");
        }
        localePath.add(currentLocale + "/");
        localePath.add(fullPath[fullPath.length - 1]);
        localisation = new Localisation(currentLocale);
        localisation.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleComplete);
        localisation.setLocaleFile(localePath.toString());
    }

    /**
    * Store the current locale
    **/

    public function popLocale():Void
    {
        if(stashedLocale != null){
            localisation = stashedLocale;
            stashedLocale = null;
        }
        else
            throw "The localiser has no stashed locale";
    }

    /**
    * Restore the previously stored locale
    **/

    public function pushLocale():Void
    {
        stashedLocale = localisation;
    }

    // Private

    private function onLocaleComplete(e:LocaleEvent):Void
    {
        dispatchEvent(new LocaleEvent(LocaleEvent.LOCALE_LOADED));
    }
}