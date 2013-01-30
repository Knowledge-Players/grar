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
    public var currentPart: PartDisplay;

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
    * Display the next part in the game
**/

    public function displayNextPart(): Void
    {
        currentPart.unLoad();
        displayPart(game.start(currentPart.part.id + 1));
    }

    private function displayMenu()
    {
        menu = new MenuDisplay(game);
        menu.launchPart = launchPart;
        addChild(menu);
    }

    private function launchPart(part: Part): Void
    {
        removeChild(menu);
        displayPart(part.start(true));
    }

    private function displayPart(part: Part): Void
    {
        currentPart = DisplayFactory.createPartDisplay(part);
        if(currentPart == null)
            dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
        else{
            currentPart.addEventListener(PartEvent.EXIT_PART, onExitPart);
            TweenManager.fadeIn(currentPart);
            addChild(currentPart);
        }
    }

    // Handlers

    private function onExitPart(event: Event): Void
    {
        displayNextPart();
    }

}
