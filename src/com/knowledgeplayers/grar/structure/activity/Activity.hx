package com.knowledgeplayers.grar.structure.activity;

import haxe.xml.Fast;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.Lib;
import nme.events.Event;
import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.events.EventDispatcher;

/**
 * Abstract activity
 */
class Activity extends EventDispatcher, implements PartElement {
    /**
    * Name of the activity
    **/
    public var name (default, default):String;
    /**
     * Score for this activity
     */
    public var score (default, default):Int = 0;
    /**
     * Path to the content file
     */
    public var content (default, default):String;

    /**
    * Part where the activity is
    **/
    public var container (default, default):Part;

    /**
    * Reference of the button which will validate the activity
    **/
    public var button (default, default):{ref:String, content:String};

    /**
    * Reference to the background for the activity
    **/
    public var background (default, default):String;

    /**
    * Localisation key for the instructions
    **/
    public var instructionContent (default, default):String;

    /**
    * Reference to the text zone where to display instructions
    **/
    public var ref (default, default):String;

    /**
    * Mode of control.
    * If end, the control is done when the activity is validated.
    **/
    public var controlMode (default, default):String;

    /**
     * True if the activity has been done
     */
    private var isEnded:Bool;

    private var token:Token;

    /**
     * Constructor
     * @param	content : Path to the content file
     */

    private function new(content:String)
    {
        super();
        this.content = content;
        isEnded = false;
    }

    /**
     * Load the activity. Must be done before the start
     */

    public function loadActivity():Void
    {
        Localiser.instance.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleComplete);
        Localiser.instance.pushLocale();
        Localiser.instance.setLayoutFile(content);
    }

    /**
     * Start the activity
     */

    public function startActivity():Void
    {}

    /**
     * Stop the activity, set it to done
     */

    public function endActivity():Void
    {
        if(!isEnded){
            isEnded = true;
            Localiser.instance.popLocale();
            dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
        }
    }

    /**
    * @return false
**/

    public function isText():Bool
    {
        return false;
    }

    /**
    * @return true
**/

    public function isActivity():Bool
    {
        return true;
    }

    /**
    * @return false
**/

    public function isPattern():Bool
    {
        return false;
    }

    /**
    * @return false
**/

    public function isPart():Bool
    {
        return false;
    }

    public function hasToken():Bool {
        return token != null;
    }

    // Privates

    private function onLocaleComplete(e:LocaleEvent):Void
    {
        Localiser.instance.removeEventListener(LocaleEvent.LOCALE_LOADED, onLocaleComplete);
        dispatchEvent(new LocaleEvent(LocaleEvent.LOCALE_LOADED));
    }

    private function parseContent(content:Xml):Void
    {
        var fast = new Fast(content.firstElement());
        if(fast.has.background)
            background = fast.att.background;
        if(fast.has.instructionContent){
            instructionContent = fast.att.instructionContent;
            ref = fast.att.ref;
        }
        if(fast.has.controlMode)
            controlMode = fast.att.controlMode.toLowerCase();
        else
            controlMode = "auto";
        var content;
        if(fast.node.Button.has.content)
            content = fast.node.Button.att.content;
        else
            content = null;
        button = {ref: fast.node.Button.att.ref, content: content};
    }

    // Handlers

    private function onLoadComplete(event:Event):Void
    {
        parseContent(XmlLoader.getXml(event));
    }
}
