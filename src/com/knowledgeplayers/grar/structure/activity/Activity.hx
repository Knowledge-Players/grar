package com.knowledgeplayers.grar.structure.activity;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.XmlLoader;
import flash.events.Event;
import nme.events.EventDispatcher;

/**
 * Abstract activity
 * @author jbrichardet
 */
class Activity extends EventDispatcher
{
	/**
	 * Score for this activity
	 */
	public var score (default, default): Int = 0;
	/**
	 * Path to the content file
	 */
	public var content (default, default): String;
	
	/**
	 * Path to the previous content file
	 */
	private var previousContent (default, default): String;
	
	/**
	 * True if the activity has been done
	 */
	private var isEnded (default, default): Bool;

	
	/**
	 * Constructor
	 * @param	content : Path to the content file
	 */
	private function new(?content: String) 
	{
		super();
		this.content = content;
		isEnded = false;
	}
	
	/**
	 * Load the activity. Must be done before the start
	 */
	public function loadActivity() : Void 
	{
		Localiser.instance.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleComplete);
		previousContent = Localiser.instance.layoutPath;
		Localiser.instance.setLayoutFile(content);
	}
	
	/**
	 * Start the activity
	 */
	public function startActivity(): Void {}

	/**
	 * Stop the activity, set it to done
	 */
	public function endActivity(): Void 
	{
		isEnded = true;
		Localiser.instance.setLayoutFile(previousContent);
	}
	
	// Privates
	
	private function onLocaleComplete(e:Event):Void 
	{
		if (isEnded)
			dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
		else
			dispatchEvent(new LocaleEvent(LocaleEvent.LOCALE_LOADED));
	}
}
