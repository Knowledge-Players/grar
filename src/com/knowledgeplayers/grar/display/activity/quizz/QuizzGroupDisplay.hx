package com.knowledgeplayers.grar.display.activity.quizz;
import com.knowledgeplayers.grar.structure.activity.quizz.QuizzGroup;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.display.Sprite;

/**
 * ...
 * @author jbrichardet
 */

class QuizzGroupDisplay extends Sprite
{
	public var model (default, setModel): QuizzGroup;
	
	private var items: Array<QuizzItemDisplay>;

	public function new(group: QuizzGroup) 
	{
		super();
		items = new Array<QuizzItemDisplay>();
		initDisplay();
		setModel(group);
	}
	
	public function setModel(model: QuizzGroup) : QuizzGroup 
	{
		this.model = model;
		updateItems();
		
		return model;
	}

	public function initDisplay() : Void
	{
		x = QuizzDisplay.instance.groupX;
		y = QuizzDisplay.instance.groupY;
	}
	
	public function validate(): Void
	{
		for (item in items) {
			item.validate();
		}
	}
	
	public function correct() : Void 
	{
		for (item in items) {
			item.displayCorrection();
		}
	}
	
	private function updateItems() : Void 
	{
		var totalYOffset: Float = 0;
		unloadItems();
		for (item in model.items) {
			var itemDisplay = new QuizzItemDisplay(item);
			itemDisplay.x = QuizzDisplay.instance.groupXOffset;
			itemDisplay.y = totalYOffset;
			
			totalYOffset += QuizzDisplay.instance.groupYOffset;
			items.push(itemDisplay);
			addChild(itemDisplay);
		}
	}
	
	private function unloadItems() 
	{
		while (numChildren != 0)
			removeChildAt(numChildren - 1);
	}
	
}