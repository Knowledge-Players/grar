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
            TweenManager.fadeIn(currentPart);
            addChild(currentPart);
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

}
