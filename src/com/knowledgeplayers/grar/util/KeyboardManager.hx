package com.knowledgeplayers.grar.util;

import com.knowledgeplayers.grar.display.GameDisplay;
import nme.events.KeyboardEvent;
import nme.Lib;
import nme.ui.Keyboard;

/**
 * Utility class to manage Keyboard inputs
 */
class KeyboardManager {
    public static var instance (getInstance, null): KeyboardManager;

    public var game (default, default): GameDisplay;

    public static function getInstance(): KeyboardManager
    {
        if(instance == null)
            instance = new KeyboardManager();
        return instance;
    }

    private function new()
    {
        init();
    }

    private function init(): Void
    {
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
    }

    // Handlers

    private function keyDownHandler(ev: KeyboardEvent): Void
    {
        if(ev.charCode < 58 && ev.charCode > 47){
            // charCode - 49 map 0 to 1, 1 to 2, etc
            game.displayPartById(ev.charCode - 49);
            return;
        }

        switch(ev.keyCode){
            //case Keyboard.SPACE: game.currentPart.activityDisplay.showDebrief();
            case Keyboard.TAB: // Défiler DynBubble;
            case Keyboard.RIGHT: if(game.currentPart != null)
                game.currentPart.nextElement();
            case Keyboard.D: for(part in game.game.getAllParts()){
                part.isDone = true;
            }
        }
    }

    private function keyUpHandler(ev: KeyboardEvent): Void
    {

    }
}
