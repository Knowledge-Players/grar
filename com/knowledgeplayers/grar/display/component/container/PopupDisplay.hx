package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.localisation.Localiser;
import aze.display.TilesheetEx;
import haxe.xml.Fast;


/**
* Display of an popup in a folder activity
**/

class PopupDisplay extends WidgetContainer {

    /**
    * reference for the localisation
    **/
    public var localRef:String;

    private var xml:Fast;


    public function new(?_xml: Fast, ?tilesheet: TilesheetEx)
    {
        super(_xml,tilesheet);
        xml =_xml;
    }

   public function init(_ref:String):Void
   {
       localRef = _ref;
       for (txt in xml.nodes.Text)
       {
           var localizedText = Localiser.instance.getItemContent(localRef +"_"+txt.att.ref);
           var text = cast(displays.get(txt.att.ref),ScrollPanel);
           text.setContent(localizedText);
       }
   }

    override private function setButtonAction(button:DefaultButton, action:String):Void {
        if (action =="closePopUp")
        {
            button.buttonAction = onClosePopup;
        }
    }

    private function onClosePopup(?_target:DefaultButton):Void{
        removePopup();
    }

    private function removePopup():Void{
        parent.removeChild(this);

    }

}
