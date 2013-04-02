package com.knowledgeplayers.grar.display;

import haxe.FastList;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.display.layout.Layout;
import nme.Lib;
import nme.events.EventDispatcher;
import nme.display.Sprite;
import com.knowledgeplayers.grar.util.KeyboardManager;
import com.knowledgeplayers.grar.display.LayoutManager;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.DisplayFactory;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.events.Event;

/**
 * Display of a game
 */

class GameManager extends EventDispatcher {
    /**
    * Instance of the game manager
    **/
    public static var instance (getInstance, null):GameManager;

    /**
     * The game model
     */
    public var game (default, default):Game;

    /**
     * Queue of parts managed in the game
     */
    public var parts (default, null):FastList<PartDisplay>;

    private var layout:Layout;
    private var activityDisplay:ActivityDisplay;
    private var navByMenu:Bool = false;

    /**
    * @return the instance of the singleton
    **/

    public static function getInstance():GameManager
    {
        if(instance == null)
            instance = new GameManager();
        return instance;
    }

    /**
    * Start the game
    * @param    game : The game to start
    * @param    layout : The layout to display
    **/

    public function startGame(game:Game, layout:String = "default"):Void
    {
        this.game = game;
        changeLayout(layout);
        displayPartById(0);
    }

    public function changeLayout(layout:String):Void
    {
        if(this.layout != null)
           Lib.current.removeChild(this.layout.content);
        this.layout = LayoutManager.instance.getLayout(layout);
        Lib.current.addChild(this.layout.content);
    }

    /**
    * Display a graphic representation of the given part
    * @param part : The part to display
    **/

    public function displayPart(part:Part):Void
    {
        // Display the new part
        parts.add(DisplayFactory.createPartDisplay(part));
        if(parts.first() == null)
            dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
        else{
            parts.first().addEventListener(PartEvent.EXIT_PART, onExitPart);
            parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
            parts.first().addEventListener(PartEvent.ENTER_SUB_PART, onEnterSubPart);
            parts.first().init();
        }
    }

    public function displayActivity(activity:Activity):Void
    {
        cleanup();
        activity.addEventListener(PartEvent.EXIT_PART, onActivityEnd);
        var activityName:String = Type.getClassName(Type.getClass(activity));
        activityName = activityName.substr(activityName.lastIndexOf(".") + 1);
        activityDisplay = ActivityManager.instance.getActivity(activityName);
        activityDisplay.addEventListener(Event.COMPLETE, onActivityReady);
        activityDisplay.model = activity;


    }

    /**
    * Display a graphic representation of the part with the given ID
    * @param id : The ID of the part to display
    **/

    public function displayPartById(id:Int):Void
    {

        displayPart(game.start(id));
    }

    // Privates

    private function new()
    {
        super();
        parts = new FastList<PartDisplay>();
        // Set Keyboard Manager
        KeyboardManager.instance.game = this;
    }

    // Handlers

    private function onExitPart(event:Event):Void
    {
        parts.first().unLoad();
        displayPartById(parts.pop().part.id + 1);
    }

    private function onPartLoaded(event:PartEvent):Void
    {
        var partDisplay = cast(event.target, PartDisplay);
        partDisplay.removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
        partDisplay.startPart();
        layout.zones.get(game.ref).addChild(partDisplay);
    }

    private function onExitSubPart(event:PartEvent):Void
    {
        parts.first().unLoad();
        layout.zones.get(game.ref).removeChild(parts.pop());
        parts.first().visible = true;
        parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
    }

    public function onEnterSubPart(event:PartEvent):Void
    {
        parts.first().visible = false;
        parts.first().removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
        parts.add(DisplayFactory.createPartDisplay(event.part));
        parts.first().addEventListener(PartEvent.EXIT_PART, onExitSubPart);
        parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
        parts.first().init();
    }

    private function onActivityReady(e:Event):Void
    {
        activityDisplay.removeEventListener(Event.COMPLETE, onActivityReady);
        layout.zones.get(game.ref).addChild(activityDisplay);
        activityDisplay.startActivity();
    }

    private function onActivityEnd(e:PartEvent):Void
    {
        e.target.removeEventListener(PartEvent.EXIT_PART, onActivityEnd);
        if(activityDisplay != null && layout.zones.get(game.ref).contains(activityDisplay))
            layout.zones.get(game.ref).removeChild(activityDisplay);
        cleanup();
        if(parts != null && !navByMenu){
            parts.first().nextElement();
        }
        else
            navByMenu = false;
    }

    private function cleanup():Void
    {
        if(activityDisplay != null){
            activityDisplay.model.removeEventListener(PartEvent.EXIT_PART, onActivityEnd);
            activityDisplay.endActivity();
            navByMenu = true;
            activityDisplay = null;
        }
    }
}
