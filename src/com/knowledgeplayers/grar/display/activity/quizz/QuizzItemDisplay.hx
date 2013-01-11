package com.knowledgeplayers.grar.display.activity.quizz;

import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.quizz.QuizzItem;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.display.container.ScrollPanel;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.Lib;


/**
 * Display for quizz propositions
 * @author jbrichardet
 */

class QuizzItemDisplay extends Sprite
{
	public var icon: Bitmap;
	public var correction: Bitmap;
	
	private var textS:ScrollPanel;
	private var model: QuizzItem;

	
	public function new(item: QuizzItem) 
	{
		super();
		
		model = item;
		
		buttonMode = true;
		
		var content  = Localiser.getInstance().getItemContent(model.content);
		var contentParsed = KpTextDownParser.parse(content);

		textS = new ScrollPanel(contentParsed.width,50);
		
		textS.content = contentParsed;
		
		textS.x = QuizzDisplay.instance.itemXOffset;
		
		correction = new Bitmap();
		correction.x = QuizzDisplay.instance.correctionXOffset;
		correction.x = textS.x+textS.width+5;
		
		icon = new Bitmap(QuizzDisplay.instance.iconUncheck);

		

		addEventListener(MouseEvent.CLICK, onClick);
		
		addChild(icon);
		addChild(textS);
		addChild(correction);
	}
	
	public function validate() : Int 
	{
		var checkedNumber = 0;
		if(model.isChecked){
			if(model.isAnswer)
				icon.bitmapData = QuizzDisplay.instance.iconCheckRight;
			else
				icon.bitmapData = QuizzDisplay.instance.iconCheckFalse;
		}
		
		return checkedNumber;
	}

	public function displayCorrection() : Void 
	{
		if(model.isAnswer)
			correction.bitmapData = QuizzDisplay.instance.correction;
	}
	
	// Handlers

	private function onClick(event: MouseEvent) : Void
	{
		// Quizz is locked, no input accepted
		if (QuizzDisplay.instance.locked)
			return;
			
		if(model.isChecked){
			icon.bitmapData = QuizzDisplay.instance.iconUncheck;
			model.isChecked = false;
		}
		else{
			icon.bitmapData = QuizzDisplay.instance.iconCheck;
			model.isChecked = true;
		}
	}	
}