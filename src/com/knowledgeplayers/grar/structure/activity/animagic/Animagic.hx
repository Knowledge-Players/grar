
package com.knowledgeplayers.grar.structure.activity.animagic;

import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.events.Event;

class Animagic extends Activity 
{

	public function new(?content: String) 
	{
		super(content);
		
		var xml = XmlLoader.load(content,onLoadComplete);
		#if !flash
			parseContent(xml);
		#end
	}

	override public function startActivity(): Void 
	{
	
	}

	private function onLoadComplete(event: Event) : Void
	{
		
	}



}