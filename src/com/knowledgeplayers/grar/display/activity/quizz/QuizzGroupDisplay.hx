package com.knowledgeplayers.grar.display.activity.quizz;
import com.knowledgeplayers.grar.structure.activity.quizz.QuizzGroup;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.display.Sprite;

/**
 * Display for a group of answer in a quizz
 */
class QuizzGroupDisplay extends Sprite
{
	/**
	 * Model to display
	 */
	public var model (default, setModel): QuizzGroup;
	
	private var items: Array<QuizzItemDisplay>;

	/**
	 * Constructor
	 * @param	group : Model to display
	 */
	public function new(group: QuizzGroup) 
	{
		super();
		items = new Array<QuizzItemDisplay>();
		initDisplay();
		model = group;
	}
	
	/**
	 * Setter of the model
	 * @param	model : Model to set
	 * @return the model
	 */
	public function setModel(model: QuizzGroup) : QuizzGroup 
	{
		this.model = model;
		updateItems();
		
		return model;
	}
	
	/**
	 * Validate the answers
	 */
	public function validate(): Void
	{
		for (item in items) {
			item.validate();
		}
	}
	
	/**
	 * Point out the good answers
	 */
	public function correct() : Void 
	{
		for (item in items) {
			item.displayCorrection();
		}
	}

	// Private
	
	private function initDisplay() : Void
	{
		x = QuizzDisplay.instance.groupX;
		y = QuizzDisplay.instance.groupY;
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