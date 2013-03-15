package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.grar.event.PartEvent;
import nme.events.EventDispatcher;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.Game;
import nme.events.Event;
import nme.text.TextField;
import nme.display.Stage;
import com.knowledgeplayers.grar.display.layout.Layout;
import haxe.xml.Fast;
import nme.Lib;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.display.Sprite;

class LayoutManager extends EventDispatcher {
    /**
    * Instance of the manager
    **/
    public static var instance (getInstance, null):LayoutManager;

    private var layoutNode:Fast;

    private var layouts:Hash<Layout>;

    public static function getInstance():LayoutManager
    {
        if(instance == null)
            instance = new LayoutManager();
        return instance;
    }

    /**
    * @return the layout with the given ref
    **/

    public function getLayout(ref:String):Layout
    {
        return layouts.get(ref);
    }

    /**
    * Parsing du Xml
    **/

    public function parseXml(xml:Xml):Void
    {

        var fastXml = new Fast(xml);
        layoutNode = fastXml.node.Layouts;
        loadInterfaceXml(layoutNode);
    }

    public function loadInterfaceXml(_xml:Fast):Void
    {

        Localiser.instance.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleLoaded);
        Localiser.instance.setLocalisationFile(_xml.att.text);
    }

    public function onLocaleLoaded(e:Event):Void
    {
        Localiser.instance.removeEventListener(LocaleEvent.LOCALE_LOADED, onLocaleLoaded);
        for(lay in layoutNode.elements){

            var layout:Layout = new Layout(lay);

            layouts.set(layout.name, layout);
        }
        dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
    }

    /**
    * Layout Display
    **/

    private function new():Void
    {
        super();
        layouts = new Hash<Layout>();
    }
}
