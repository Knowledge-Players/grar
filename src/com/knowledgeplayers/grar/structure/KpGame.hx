package com.knowledgeplayers.grar.structure;

import haxe.FastList;
import com.knowledgeplayers.grar.display.GameManager;
import com.eclecticdesignstudio.motion.Actuate;
import nme.events.TimerEvent;
import nme.utils.Timer;
import nme.Assets;
import com.knowledgeplayers.grar.display.LayoutManager;
import nme.Assets;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.PartFactory;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.tracking.Connection;
import com.knowledgeplayers.grar.tracking.StateInfos;
import com.knowledgeplayers.grar.util.LoadData;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.events.Event;
import nme.events.EventDispatcher;
import nme.Lib;
import nme.net.URLLoader;

/**
 * KP inmplentation of a game
 */
class KpGame extends EventDispatcher, implements Game {
    /**
     * Connection mode
     */
    public var mode (default, default):Mode;

    /**
     * Game title
     */
    public var title (default, default):String;

    /**
     * State of the game
     */
    public var state (default, default):String;

    /**
     * Global inventory
     */
    public var inventory (default, null):Array<Token>;

    /**
    * Flag for the loading of UI
    **/
    public var uiLoaded (default, default):Bool = false;

    /**
    * Reference for the layout
    **/
    public var ref (default, default):String;

    /**
    * Index of the current part
    **/
    private var partIndex:Int = 0;
    private var structureXml:Fast;
    private var languages:Hash<String>;
    private var stateInfos:StateInfos;
    private var flags:Hash<String>;
    private var parts:IntHash<Part>;
    private var connection:Connection;
    private var nbPartsLoaded:Int = 0;
    private var layoutLoaded:Bool = false;
    private var numStyleSheet:Int = 0;
    private var numStyleSheetLoaded:Int = 0;
    private var activitiesWaiting:FastList<Xml>;

    /**
    * Constructor.
    * Register the game to the GameManager
    **/

    public function new()
    {
        super();
        languages = new Hash<String>();
        flags = new Hash<String>();
        parts = new IntHash<Part>();
        inventory = new Array<Token>();
        activitiesWaiting = new FastList<Xml>();

        GameManager.instance.game = this;

        Lib.current.stage.addEventListener(Event.DEACTIVATE, onExit);
        LayoutManager.instance.addEventListener(PartEvent.PART_LOADED, onPartLoaded);

    }

    /**
     * Initialize the game with a xml structure
     * @param	xml : the structure
     */

    public function init(xml:Xml):Void
    {
        structureXml = new Fast(xml);

        #if flash
            LoadData.getInstance().addEventListener("DATA_LOADED",onDisplayLoaded);
            LoadData.getInstance().loadDisplayXml(xml);
        #else
        onDisplayLoaded();
        #end
    }

    /**
     * Start the game
     * @param	partId : the ID of the part to start.
     * @return 	the part with id partId or null if this part doesn't exist
     */

    public function start(partId:Int = 0):Null<Part>
    {
        for(part in getAllParts()){
            if(part.id == partId)
                return part.start(true);
        }
        return null;
    }

    /**
     * Add a part to the game at partIndex
     * @param	partIndex : position of the part in the game
     * @param	part : the part to add
     */

    public function addPart(partIndex:Int, part:Part):Void
    {
        part.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
        part.addEventListener(PartEvent.EXIT_PART, onPartComplete);
        part.addEventListener(TokenEvent.ADD_GLOBAL, onGlobalTokenAdd);
        parts.set(partIndex, part);
    }

    /**
     * Add a language to the game
     * @param	value : name of the language
     * @param	path : path to the localisation folder
     * @param	flagIconPath : path to the flag for this language
     */

    public function addLanguage(value:String, path:String, flagIconPath:String):Void
    {
        Localiser.getInstance().localisations.set(value, path);
        flags.set(value, flagIconPath);
    }

    /**
     * @return a string-based representation of the game
     */

    override public function toString():String
    {
        return title + " - " + mode + " - " + state + ". Parts: \n\t" + parts.toString();
    }

    /**
     * Start the tracking
     * @param	mode : tracking mode (SCORM/AICC)
     */

    public function initTracking(?mode:Mode):Void
    {
        connection = new Connection();
        if(mode != null)
            this.mode = mode;
        connection.initConnection(this.mode);
        stateInfos = connection.revertTracking();
        if(stateInfos.isEmpty()){
            stateInfos.loadStateInfos(state);
        }
    }

    /**
     * Get the state of loading of the game
     * @return a float between 0 (nothing loaded) and 1 (everything's loaded)
     */

    public function getLoadingCompletion():Float
    {
        return nbPartsLoaded / getAllParts().length;
    }

    /**
     * @return all the parts of the game
     */

    public function getAllParts():Array<Part>
    {
        var array = new Array<Part>();
        for(part in parts){
            array = array.concat(part.getAllParts());
        }

        return array;
    }

    /**
    * @return all the activities of the game
    **/

    public function getAllActivities(_all:Bool=true):Array<Activity>
    {
        var activities = new Array<Activity>();
        for(part in parts){
            activities = activities.concat(part.getAllActivities(_all));
        }

        return activities;
    }

    // Privates

    private function checkIntegrity():Void
    {
        if(stateInfos.checksum != getAllParts().length){
            throw "Invalid checksum (" + getAllParts().length + " part(s) found instead of " + stateInfos.checksum + "). The structure file must be corrupt";
        }
    }

    private function addPartFromXml(partIndex:Int, partXml:Fast):Void
    {
        var part:Part = PartFactory.createPartFromXml(partXml);
        addPart(partIndex, part);
        part.init(partXml);
    }

    private function initLangs(xml:Xml):Void
    {
        var languagesXml:Fast = new Fast(xml);
        for(lang in languagesXml.node.Langs.nodes.Lang){
            addLanguage(lang.att.value, lang.att.folder, lang.att.pic);
        }
        Localiser.instance.setCurrentLocale(stateInfos.currentLanguage);

        // Load Layout
        LayoutManager.instance.parseXml(Xml.parse(Assets.getText(structureXml.node.Grar.node.Parameters.node.Layout.att.file)));
    }

    private function initActivities(xml:Xml):Void
    {
        if(numStyleSheetLoaded != numStyleSheet)
            activitiesWaiting.add(xml);
        else
            ActivityManager.instance.getActivity(xml.firstElement().nodeName).parseContent(xml);
    }

    // Handlers

    private function onDisplayLoaded(e:Event = null):Void
    {
        var displayNode:Fast = structureXml.node.Grar.node.Display;
        var parametersNode:Fast = structureXml.node.Grar.node.Parameters;
        var displayNode:Fast = structureXml.node.Grar.node.Display;

        mode = Type.createEnum(Mode, parametersNode.node.Mode.innerData);
        title = parametersNode.node.Title.innerData;
        state = parametersNode.node.State.innerData;

        // Start Tracking
        initTracking();

        // Load styles
        for(stylesheet in displayNode.nodes.Style){
            numStyleSheet++;
            XmlLoader.load(stylesheet.att.file, function(e:Event)
            {
                onStyleLoaded(XmlLoader.getXml(e));
            }, onStyleLoaded);
        }

        // Load Languages
        XmlLoader.load(parametersNode.node.Languages.att.file, onLanguagesComplete, initLangs);

        // Load UI
        UiFactory.setSpriteSheet(displayNode.node.Ui.att.display);

        // Load Transition
        if(displayNode.hasNode.Transitions)
            TweenManager.loadTemplate(displayNode.node.Transitions.att.display);

        // Load Activities displays
        for(activity in displayNode.nodes.Activity){
            var activityXml = XmlLoader.load(activity.att.display, onActivityComplete, initActivities);
        }

        // Load Parts
        var structureNode:Fast = structureXml.node.Grar.node.Structure;
        ref = structureNode.att.ref;
        for(part in structureNode.nodes.Part){
            addPartFromXml(Std.parseInt(part.att.id), part);
        }
    }

    private function onStyleLoaded(styleSheet:Xml):Void
    {
        StyleParser.parse(styleSheet.toString());
        numStyleSheetLoaded++;
        if(numStyleSheet == numStyleSheetLoaded){
            while(!activitiesWaiting.isEmpty())
                initActivities(activitiesWaiting.pop());
        }
        checkLoading();
    }

    private function onActivityComplete(event:Event):Void
    {
        var loader:URLLoader = cast(event.currentTarget, URLLoader);
        initActivities(Xml.parse(loader.data));
    }

    private function onLanguagesComplete(event:Event):Void
    {
        var loader:URLLoader = cast(event.currentTarget, URLLoader);
        initLangs(Xml.parse(loader.data));
    }

    private function onPartLoaded(event:PartEvent):Void
    {
        if(event.target == LayoutManager.instance)
            layoutLoaded = true;
        else
            nbPartsLoaded++;
        checkLoading();
    }

    private function checkLoading():Void
    {
        if(getLoadingCompletion() == 1 && uiLoaded && layoutLoaded && (numStyleSheet == numStyleSheetLoaded)){
            checkIntegrity();
            for(part in getAllParts())
                part.isDone = stateInfos.activityCompletion[part.id];
            dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
        }
    }

    private function onPartComplete(event:PartEvent):Void
    {
        stateInfos.activityCompletion[cast(event.target, Part).id] = true;
    }

    private function onGlobalTokenAdd(e:TokenEvent):Void
    {
        inventory.push(e.token);
    }

    private function onExit(e:Event):Void
    {
        Lib.exit();
    }
}
