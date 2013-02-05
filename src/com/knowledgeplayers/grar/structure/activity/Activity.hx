package com.knowledgeplayers.grar.structure.activity;

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
     * Score for this activity
     */
    public var score (default, default): Int = 0;
    /**
     * Path to the content file
     */
    public var content (default, default): String;

    /**
     * Path to the previous content file
     */
    private var previousContent (default, default): String;

    /**
     * True if the activity has been done
     */
    private var isEnded (default, default): Bool;

    /**
     * Constructor
     * @param	content : Path to the content file
     */

    private function new(content: String)
    {
        super();
        this.content = content;
        isEnded = false;
    }

    /**
     * Load the activity. Must be done before the start
     */

    public function loadActivity(): Void
    {
        Localiser.instance.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleComplete);
        previousContent = Localiser.instance.layoutPath;
        Localiser.instance.setLayoutFile(content);
    }

    /**
     * Start the activity
     */

    public function startActivity(): Void
    {}

    /**
     * Stop the activity, set it to done
     */

    public function endActivity(): Void
    {
        isEnded = true;
        Localiser.instance.setLayoutFile(previousContent);
    }

    /**
    * @return false
**/

    public function isText(): Bool
    {
        return false;
    }

    /**
    * @return true
**/

    public function isActivity(): Bool
    {
        return true;
    }

    /**
    * @return false
**/

    public function isPattern(): Bool
    {
        return false;
    }

    // Privates

    private function onLocaleComplete(e: Event): Void
    {
        removeEventListener(LocaleEvent.LOCALE_LOADED, onLocaleComplete);
        dispatchEvent(new LocaleEvent(LocaleEvent.LOCALE_LOADED));
    }

    private function parseContent(content: Xml): Void
    {}

    // Handlers

    private function onLoadComplete(event: Event): Void
    {
        parseContent(XmlLoader.getXml(event));
    }
}
