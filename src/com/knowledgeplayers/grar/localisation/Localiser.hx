package com.knowledgeplayers.grar.localisation;
	
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.localisation.Localisation;
import nme.events.Event;
import nme.events.EventDispatcher;

import haxe.xml.Fast;

/*
 * Singleton manager of the locale
 */
class Localiser extends EventDispatcher
{	
	public static var instance (getInstance, null): Localiser;
	
	public var currentLocale (default, setCurrentLocale): String;
	public var localisations (default, null): Hash<String>;
	public var layoutPath (default, setLayoutFile): String;
	
	private var introId: String;
	private var outroId: String;
	private var localisation: Localisation;
	
	private function new()
	{
		super();
		localisations = new Hash<String>();
	}
	
	public static function getInstance() : Localiser
	{
		if (instance == null){
			instance = new Localiser();
		}
		return instance;
	}

	public function setLayoutFile(path: String) : String
	{
		layoutPath = path;
		setLocalisationFile(path);
		return layoutPath;
	}

	public function setCurrentLocale(locale: String) : String
	{
		currentLocale = locale;
		return currentLocale;
	}

	public function getItemContent(key: String) : Null<String>
	{
		if(localisation != null)
			return localisation.getItem(key);
		else{
			nme.Lib.trace("No locale set. Returning null");
			return null;
		}
	}

	// Private
	
	private function setLocalisationFile(path: String) : Void 
	{		
		var localePath: String = currentLocale+"/"+path;
		localisation = new Localisation(currentLocale);
		localisation.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleComplete);
		localisation.setLocaleFile(localePath);
	}
	
	private function onLocaleComplete(e: LocaleEvent) : Void 
	{
		dispatchEvent(new LocaleEvent(LocaleEvent.LOCALE_LOADED));
	}
}