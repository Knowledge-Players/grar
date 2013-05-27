package com.knowledgeplayers.grar.display.activity.quiz;

import aze.display.TileLayer;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.quiz.QuizItem;
import com.knowledgeplayers.grar.util.DisplayUtils;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.events.MouseEvent;
import Std;

/**
 * Display for quiz propositions
 * @author jbrichardet
 */

class QuizItemDisplay extends Sprite {
	/**
     * Icon for the item
     */
	public var checkIcon (default, null):Bitmap;

	/**
     * Icon to show good answers
     */
	public var correction (default, null):Bitmap;

	/**
    * Text of the answer
    **/
	public var text (default, null):ScrollPanel;

	private var model:QuizItem;
	private var checkIconRef:String;
	private var spritesheetRef:String;

	/**
     * Construcor
     * @param	item : Model to display
     */

	public function new(item:QuizItem, ?xmlTemplate:Fast, ?width:Float, ?height:Float, ?style:String)
	{
		super();

		model = item;
		buttonMode = true;
		correction = new Bitmap();
		checkIcon = new Bitmap();
		if(width != null && height != null){
			text = new ScrollPanel(width, height, style != null ? style : (xmlTemplate.has.style ? xmlTemplate.att.style : null));
		}
		else{
			text = new ScrollPanel(Std.parseFloat(xmlTemplate.att.width), Std.parseFloat(xmlTemplate.att.height), style != null ? style : (xmlTemplate.has.style ? xmlTemplate.att.style : null));
		}

		if(xmlTemplate != null){
			if(xmlTemplate.has.spritesheet)
				setIcon(xmlTemplate.att.id, xmlTemplate.att.spritesheet);
			else if(xmlTemplate.has.id)
				setIcon(xmlTemplate.att.id);
			text.x = Std.parseFloat(xmlTemplate.att.contentX);
			correction.x = Std.parseFloat(xmlTemplate.att.correctionX);
			checkIcon.x = Std.parseFloat(xmlTemplate.att.checkX);

			if(xmlTemplate.has.background){
				DisplayUtils.setBackground(xmlTemplate.att.background, this);
			}
		}

		var content = Localiser.getInstance().getItemContent(model.content);

		text.setContent(content);

		addEventListener(MouseEvent.CLICK, onClick);

		addChild(text);
		addChild(correction);

		checkIcon.y = this.height / 2 - checkIcon.height / 2;
		addChild(checkIcon);
	}

	/**
     * Change the icon to iconCheckRight if the answer is correct
     */

	public function validate():Void
	{
		if(model.isChecked){
			if(model.isAnswer)
				checkIcon.bitmapData = QuizDisplay.instance.items.get("checkright");
			else
				checkIcon.bitmapData = QuizDisplay.instance.items.get("checkwrong");
		}
	}

	/**
     * Display the correction icon if the item is a right answer
     */

	public function displayCorrection():Void
	{
		if(model.isAnswer)
			correction.bitmapData = QuizDisplay.instance.items.get("good");
	}

	/**
    * Set the icon for the item
    * @param    id : Id of the tile used for the icon
    **/

	public function setIcon(id:String, ?spritesheet:String):Void
	{
		if(checkIconRef == null)
			checkIconRef = id;
		spritesheetRef = spritesheet;
		var layer:TileLayer;
		if(spritesheetRef != null)
			layer = new TileLayer(QuizDisplay.instance.spritesheets.get(spritesheetRef));
		else
			layer = new TileLayer(UiFactory.tilesheet);
		checkIcon.bitmapData = DisplayUtils.getBitmapDataFromLayer(layer.tilesheet, id);
	}

	// Handlers

	private function onClick(event:MouseEvent):Void
	{
		// Quizz is locked, no input accepted
		if(QuizDisplay.instance.locked)
			return;

		if(model.isChecked){
			setIcon(checkIconRef, spritesheetRef);
			model.isChecked = false;
		}
		else{
			setIcon(checkIconRef + "_active", spritesheetRef);
			model.isChecked = true;
		}
	}
}