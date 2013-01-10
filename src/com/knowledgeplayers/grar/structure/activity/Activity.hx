package com.knowledgeplayers.grar.structure.activity;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.XmlLoader;
import flash.events.Event;

/**
 * @author jbrichardet
 */
class Activity extends XmlLoader
{
	public var content: String;
	
	private var previousContent: String;
	private var isEnded: Bool;

	private function new(?content: String) 
	{
		super();
		this.content = content;
		isEnded = false;
	}
	
	public function loadActivity() : Void 
	{
		Localiser.instance.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleComplete);
		previousContent = Localiser.instance.layoutPath;
		Localiser.instance.setLayoutFile(content);
	}
	
	private function onLocaleComplete(e:Event):Void 
	{
		if (isEnded)
			dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
		else
			dispatchEvent(new LocaleEvent(LocaleEvent.LOCALE_LOADED));
	}
	
	public function startActivity(): Void {}

	public function endActivity(): Void 
	{
		isEnded = true;
		Localiser.instance.setLayoutFile(previousContent);
	}
}
