package com.knowledgeplayers.grar.display.activity.cards;

import com.knowledgeplayers.grar.structure.activity.cards.CardsElement;
import com.knowledgeplayers.grar.display.element.AnimationDisplay;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.PopupDisplay;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.structure.activity.Activity;
import aze.display.TileClip;
import aze.display.TileLayer;
import motion.Actuate;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.event.ButtonActionEvent;

import com.knowledgeplayers.grar.structure.activity.cards.Cards;
import com.knowledgeplayers.grar.util.Grid;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;

/**
* Display of the model activity
**/
class CardsDisplay extends ActivityDisplay {

	/**
    * Instance
    **/
	public static var instance (get_instance, null):CardsDisplay;



	/**
    * Grid to dispatch cards
    **/
	public var grids (default, null):Map<String, Grid>;


	private var flipDirection:Int;
	private var cardInProgress:CardsElementDisplay;
	private var nextCard:CardsElementDisplay;
	private var nextText:String;
	private var elementsContainer:Sprite;
	private var background:Bitmap;

	private var content:Fast;
	private var stylesheet:String;

	private var elementBackground:String;
	private var elementsArray:Array<CardsElementDisplay>;
    private var elementTemplate:Fast;
    public var popUp:PopupDisplay;

    private var btNext:DefaultButton;
    private var cardAnim:AnimationDisplay;



    private function new()
    {
        super();
        grids = new Map<String, Grid>();
        elementsArray = new Array<CardsElementDisplay>();
    }


	/**
    * @return the instance
    **/

	public static function get_instance():CardsDisplay
	{
		if(instance == null)
			instance = new CardsDisplay();
		return instance;
	}


	// Private

	override private function displayActivity():Void
	{
		super.displayActivity();
	}

	override public function set_model(model:Activity):Activity
	{    var model = super.set_model(model);

        for(elem in cast(model, Cards).elements){

			var elementDisplay = new CardsElementDisplay(elementTemplate,elem);
			elementsArray.push(elementDisplay);

			grids.get("dispatch").add(elementDisplay, false);
			addChild(elementDisplay);
		}

        displays.get("next").visible = false;

        return model;
	}

	override private function createElement(elemNode:Fast):Void
	{
		super.createElement(elemNode);
		switch(elemNode.name.toLowerCase()){
			case "target" :
				var target = new Image(elemNode);
				addElement(target, elemNode);
			case "popup" :
                var pop = new PopupDisplay(elemNode);
                popUp = pop;
                if(elemNode.has.style)stylesheet = elemNode.att.style;

			case "animationelement" :

                var tilesheet = spritesheets.get(elemNode.att.spritesheet);
                cardAnim = new AnimationDisplay(elemNode,elemNode.att.id,tilesheet);


			case "grid" :
				var grid = new Grid(Std.parseInt(elemNode.att.numRow), Std.parseInt(elemNode.att.numCol), Std.parseFloat(elemNode.att.cellWidth), Std.parseFloat(elemNode.att.cellHeight), Std.parseFloat(elemNode.att.gapCol), Std.parseFloat(elemNode.att.gapRow));
				grid.x = Std.parseFloat(elemNode.att.x);
				grid.y = Std.parseFloat(elemNode.att.y);
				grids.set(elemNode.att.ref, grid);
            case "element" :

                elementTemplate = elemNode;

        }
	}



	public function launchCard(_model:CardsElement):Void
	{
        addChild(cardAnim);
		cardAnim.visible = true;
        cardAnim.playAnimation(showPopup,[_model]);
	}


    private function showPopup(_array:Array<Dynamic>):Void
    {
        popUp.init(_array[0].content);
        addChild(popUp);
        popUp.addEventListener(Event.REMOVED_FROM_STAGE,onPopupClosed);
        checkElement();

    }

    private function onPopupClosed(e:Event):Void{
        cardAnim.playAnimationBack(closePopup,[model]);
    }

    private function closePopup(_array:Array<Dynamic>):Void{

        removeChild(cardAnim);

    }

	override private function unLoad(keepLayer:Int = 0):Void
	{
		super.unLoad(2);
		for(grid in grids){
			grid.empty();
		}
	}

    override private function setButtonAction(button:DefaultButton, action:String):Void
    {
        if(action.toLowerCase() == ButtonActionEvent.NEXT){
            btNext = button;
            btNext.buttonAction = endActivity;
        }
    }

    public function allCardsView():Void{

        displays.get("next").visible = true;
    }

    public function checkElement():Void{

        var nb:Int = 0;

        for(elem in cast(model, Cards).elements){
            if (elem.viewed)nb++;

        }
        if (nb==cast(model, Cards).elements.length)allCardsView();
    }
}