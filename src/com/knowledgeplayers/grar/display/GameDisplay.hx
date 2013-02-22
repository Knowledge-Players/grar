package com.knowledgeplayers.grar.display;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;
import com.knowledgeplayers.grar.display.part.MenuDisplay;

import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.DisplayFactory;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.EventDispatcher;
import nme.Lib;
import com.knowledgeplayers.grar.display.LayoutDisplay;

/**
 * Display of a game
 */

class GameDisplay extends Sprite {
    /**
     * The game model
     */
    public var game: Game;

    /**
     * Part currently displayed
     */
    public var currentPart (default, null): PartDisplay;

    /**
     * Menu of the game
     */
    private var menu: MenuDisplay;

    private var layout: LayoutDisplay;

    /**
     * Constructor
     * @param	game : the model to display
     */

    public function new(game: Game)
    {
        super();
        this.game = game;
        displayMenu();
    }

    /**
    * Display a graphic representation of the given part
    * @param part : The part to display
**/

    public function displayPart(part: Part): Void
    {
        // Cleanup
        if(currentPart != null){
            currentPart.unLoad();
            removeChild(currentPart);
        }
        if(contains(menu))
            removeChild(menu);

        // Display the new part
        currentPart = DisplayFactory.createPartDisplay(part);
        if(currentPart == null)
            dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
        else{
            currentPart.addEventListener(PartEvent.EXIT_PART, onExitPart);
            currentPart.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
            currentPart.addEventListener(PartEvent.ENTER_SUB_PART, onEnterSubPart);
        }
    }

    /**
    * Display a graphic representation of the part with the given ID
    * @param id : The ID of the part to display
**/

    public function displayPartById(id: Int): Void
    {
        displayPart(game.start(id));
    }

    // Private

    private function displayMenu()
    {
        game.layout.init(this);

        menu = new MenuDisplay(game);
        menu.launchPart = launchPart;
        addChild(menu);

    }

    private function launchPart(part: Part): Void
    {
        displayPart(part.start(true));
    }

    // Handlers

    private function onExitPart(event: Event): Void
    {
        displayPartById(currentPart.part.id + 1);
    }

    private function onPartLoaded(event: PartEvent): Void
    {
        var partDisplay = cast(event.target, PartDisplay);
        partDisplay.startPart();
        addChild(partDisplay);
    }

    private function onExitSubPart(event: PartEvent): Void
    {
        var subPart = cast(event.target, PartDisplay);
        subPart.unLoad();
        removeChild(subPart);
        currentPart.visible = true;
    }

    public function onEnterSubPart(event: PartEvent): Void
    {
        currentPart.visible = false;
        var subPart: PartDisplay = DisplayFactory.createPartDisplay(event.part);
        subPart.addEventListener(PartEvent.EXIT_PART, onExitSubPart);
        subPart.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
    }
}
