package com.knowledgeplayers.grar.structure;

import com.knowledgeplayers.grar.structure.contextual.Notebook;
import com.knowledgeplayers.grar.display.FilterManager;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.display.LayoutManager;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.PartFactory;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.tracking.Connection;
import com.knowledgeplayers.grar.tracking.StateInfos;
import com.knowledgeplayers.grar.tracking.Trackable;
import haxe.ds.GenericStack;
import haxe.xml.Fast;
import nme.Assets;
import nme.events.Event;
import nme.events.EventDispatcher;
import nme.Lib;

/**
 * KP inmplentation of a game
 */
class KpGame extends EventDispatcher implements Game {
	/**
     * Connection mode
     */
    public var mode (default, default):Mode;

    /**
     * State of the game
     */
    public var state (default, default):String;

	/**
     * Global inventory
     */
    public var inventory (default, null):Array<Token>;

	/**
    * Reference for the layout
    **/
    public var ref (default, default):String;

	/**
    * Xml describing the menu
    **/
    public var menu (default, default):Xml;

	/**
	* Tracking infos
	**/
    public var stateInfos (default, null):StateInfos;

	/**
	* Connection with the LMS
	**/
    public var connection (default, null):Connection;

    /**
    * Index of the current part
    **/
    private var partIndex:Int = 0;
    private var structureXml:Fast;
    private var languages:Map<String, String>;
    private var flags:Map<String, String>;
    private var parts:Array<Part>;
    private var numParts:Int = 0;
    private var nbPartsLoaded:Int = 0;
    private var layoutLoaded:Bool = false;
    private var numStyleSheet:Int = 0;
    private var numStyleSheetLoaded:Int = 0;
    private var activitiesWaiting:GenericStack<Xml>;

	/**
    * Constructor.
    * Register the game to the GameManager
    **/
    public function new()
    {
        super();
        languages = new Map<String, String>();
        flags = new Map<String, String>();
        parts = new Array<Part>();
        inventory = new Array<Token>();
        activitiesWaiting = new GenericStack<Xml>();

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

        var displayNode:Fast = structureXml.node.Grar.node.Display;
        var parametersNode:Fast = structureXml.node.Grar.node.Parameters;
        var displayNode:Fast = structureXml.node.Grar.node.Display;

        mode = Type.createEnum(Mode, parametersNode.node.Mode.innerData);
        state = parametersNode.node.State.innerData;

    	// Start Tracking
        initTracking();

    	// Load UI
        UiFactory.setSpriteSheet(displayNode.node.Ui.att.display);

    	// Load styles
        for(stylesheet in displayNode.nodes.Style){
            var fullPath = stylesheet.att.file.split("/");

            var localePath:StringBuf = new StringBuf();
            for(i in 0...fullPath.length - 1){
                localePath.add(fullPath[i] + "/");
            }
            localePath.add(Localiser.instance.currentLocale + "/");
            localePath.add(fullPath[fullPath.length - 1]);
            StyleParser.parse(AssetsStorage.getXml(localePath.toString()));
        }

        // Load Languages
        initLangs(AssetsStorage.getXml(parametersNode.node.Languages.att.file));

        // Load Transition
        if(displayNode.hasNode.Transitions)
            TweenManager.loadTemplate(displayNode.node.Transitions.att.display);

        // Load filters
        if(displayNode.hasNode.Filters)
            FilterManager.loadTemplate(displayNode.node.Filters.att.display);

        // Load Activities displays
        for(activity in displayNode.nodes.Activity){
            initActivities(AssetsStorage.getXml(activity.att.display));
        }

		// Load contextual
		var structureNode:Fast = structureXml.node.Grar.node.Structure;
		for(contextual in structureNode.nodes.Contextual){
			var display = AssetsStorage.getXml(contextual.att.display);
			switch(contextual.att.type.toLowerCase()){
				case "notebook": Notebook.instance.init(contextual.att.file);
								NotebookDisplay.instance.parseContent(display);
				/*case "glossary": Glossary.instance.fillWithXml(content);
				case "bibliography": Bibliography.instance.fillWithXml(content);*/
			}
		}

        // Load Parts
        if(structureNode.has.inventory)
            GameManager.instance.loadTokens(structureNode.att.inventory);
        if(structureNode.has.menu){
            menu = AssetsStorage.getXml(structureNode.att.menu);
        }
        ref = structureNode.att.ref;
        // Count parts
        for(part in structureNode.nodes.Part){
            numParts++;
        }
        // Load them
        for(part in structureNode.nodes.Part){
            addPartFromXml(part.att.id, part);
        }
    }

	/**
     * Start the game
     * @param	partId : the ID of the part to start.
     * @return 	the part with id partId or null if this part doesn't exist
     */
    public function start(?partId:String):Null<Part>
    {
        var nextPart:Part = null;
        if(partId == null){
            do{
                nextPart = parts[partIndex].start();
                partIndex++;
            }
            while(nextPart == null && partIndex < parts.length);
        }
        else if(partId != null){
            var i:Int = 0;
            while(i < getAllParts().length && getAllParts()[i].id != partId){
                i++;
            }
            nextPart = getAllParts()[i].start(true);
            var j = 0;
            var k = 0;
            while(j <= i){
                if(getAllParts()[j] == parts[k] && j > 0)
                    k++;
                j++;
            }
            partIndex = k + 1;
        }
        return nextPart;
    }

	/**
     * Add a part to the game at partIndex
     * @param	partId : ID of the part
     * @param	part : the part to add
     */
    public function addPart(partId:String, part:Part):Void
    {
        part.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
        parts.push(part);
    }

    /**
     * Add a language to the game
     * @param	value : name of the language
     * @param	path : path to the localisation folder
     * @param	flagIconPath : path to the flag for this language
     */
    public function addLanguage(value:String, path:String, flagIconPath:String):Void
    {
        Localiser.get_instance().localisations.set(value, path);
        flags.set(value, flagIconPath);
    }

    /**
     * @return a string-based representation of the game
     */
    override public function toString():String
    {
        return mode + " - " + state + ". Parts: \n\t" + parts.toString();
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
        Localiser.instance.currentLocale = stateInfos.currentLanguage;
    }

    /**
     * Get the state of loading of the game
     * @return a float between 0 (nothing loaded) and 1 (everything's loaded)
     */
    public function getLoadingCompletion():Float
    {
        return nbPartsLoaded / numParts;
    }

	/**
     * @return all the parts of the game
     */
    public function getAllParts():Array<Part>
    {
        var array = new Array<Part>();
        for(part in parts){
            array = array.concat(part.getAllParts());
            array.push(part);
        }

        return array;
    }

	/**
    * @return all trackable items of the game
    **/
    public function getAllItems():Array<Trackable>
    {
        var activities = new Array<Trackable>();
        for(part in parts){
            activities = activities.concat(part.getAllItems());
        }

        return activities;
    }

	/**
    * @param    id : Id of the item
    * @return the name of the item
    **/
    public function getItemName(id:String):Null<String>
    {
        var i = 0;
        var name:String = null;
        while(i < parts.length && name == null){
            name = parts[i].getItemName(id);
            i++;
        }
        return name;
    }

	/**
	* @param    id : Id of the part
	* @return the part with the given id
	**/
    public function getPart(id:String):Null<Part>
    {
        var i = 0;
        while(i < getAllParts().length && getAllParts()[i].id != id)
            i++;
        return i == getAllParts().length ? null : getAllParts()[i];
    }

    // Privates

    private function checkIntegrity():Void
    {
        if(stateInfos.checksum != getAllParts().length){
            throw "Invalid checksum (" + getAllParts().length + " part(s) found instead of " + stateInfos.checksum + "). The structure file must be corrupt";
        }
    }

    private function addPartFromXml(partIndex:String, partXml:Fast):Void
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
    }

    private function initActivities(xml:Xml):Void
    {
        if(numStyleSheetLoaded != numStyleSheet)
            activitiesWaiting.add(xml);
        else
            ActivityManager.instance.getActivity(xml.firstElement().nodeName).parseContent(xml);
    }

    // Handlers

    private function createMenuXml(xml:Xml, part:Part, level:Int = 1):Void
    {
        var child = Xml.createElement("h" + level);
        child.set("id", part.id);
        xml.addChild(child);
        for(elem in part.elements){
            if(elem.isPart() && cast(elem, Part).hasParts()){
                createMenuXml(child, cast(elem, Part), level++);
            }
            else if(Std.is(elem, Trackable)){
                var item = Xml.createElement("item");
                item.set("id", cast(elem, Trackable).id);
                child.addChild(item);
            }
        }
    }

    private function onStyleLoaded(styleSheet:Xml):Void
    {
        StyleParser.parse(styleSheet);
        numStyleSheetLoaded++;
        if(numStyleSheet == numStyleSheetLoaded){
            while(!activitiesWaiting.isEmpty())
                initActivities(activitiesWaiting.pop());
        }
        checkLoading();
    }

    private function onPartLoaded(event:PartEvent):Void
    {
        if(event.target == LayoutManager.instance)
            layoutLoaded = true;
        else{
            nbPartsLoaded++;
        }
        checkLoading();
    }

    private function checkLoading():Void
    {
        if(getLoadingCompletion() == 1 && (numStyleSheet == numStyleSheetLoaded)){
        	//checkIntegrity();
        	// Menu hasn't been set, creating the default
            if(menu == null){
                var menuXml = Xml.createElement("menu");
                for(part in parts){
                    createMenuXml(menuXml, part);
                }
                menu = menuXml;
            }
            if(!layoutLoaded){
                for(part in getAllParts())
                    part.isDone = stateInfos.isPartFinished(part.id);
                // Load Layout
                LayoutManager.instance.parseXml(AssetsStorage.getXml(structureXml.node.Grar.node.Parameters.node.Layout.att.file));
            }
            else{
                dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
            }
        }
    }

    private function onExit(e:Event):Void
    {
        Lib.exit();
    }
}