package com.knowledgeplayers.grar.display.activity.cards;

import com.knowledgeplayers.grar.structure.activity.cards.CardsElement;import com.knowledgeplayers.grar.display.component.container.PopupDisplay;
import com.knowledgeplayers.grar.structure.activity.cards.CardsElement;
import aze.display.TilesheetEx;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.localisation.Localiser;
import flash.display.Sprite;
import flash.events.MouseEvent;

/**
* Display of an element in a folder activity
**/
class CardsElementDisplay extends WidgetContainer {

/**
    * Model
    **/
    public var model (default, null):CardsElement;

    private var popUp:PopupDisplay;

	public function new(?xml: Fast, ?tilesheet: TilesheetEx,?model:CardsElement)
	{
		super(xml,tilesheet);
		buttonMode = true;
        this.model = model;
      //  trace('ref : '+model.ref);
      //  trace('model.content  : '+model.content );
        var text = cast(displays.get(model.ref),ScrollPanel);

        var localizedText = Localiser.instance.getItemContent(model.content + "_front");
      //  trace("localizedTrxt : "+localizedText);

        text.setContent(localizedText);

		addEventListener(MouseEvent.CLICK, onClick);
	}

	public function blockElement():Void
	{
		removeEventListener(MouseEvent.CLICK, onClick);
		buttonMode = false;
	}

    private function onClick(e:MouseEvent):Void
    {
        var cd = cast(parent, CardsDisplay);
        model.viewed = true;
        cd.launchCard(model);
    }




}
