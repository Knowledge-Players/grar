package com.knowledgeplayers.sample;

import com.knowledgeplayers.grar.util.KeyboardManager;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.display.GameDisplay;
import com.knowledgeplayers.grar.display.style.StyleParser;
import nme.Assets;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.KpGame;
import nme.Lib;

class Main {

    private var game: Game;

    public function new()
    {
        #if cpp
            new hxcpp.DebugSocket("127.0.0.1", 65333, true);
        #end

        // Create a new game
        game = new KpGame();

        game.addEventListener(PartEvent.PART_LOADED, onLoadingComplete);
        game.init(Xml.parse(Assets.getText("xml/sample_structure.xml")));

    }

    private function onLoadingComplete(e: PartEvent): Void
    {
        var gameDisplay = new GameDisplay(game);
        gameDisplay.addEventListener(GameEvent.GAME_OVER, onGameOver);
        Lib.current.addChild(gameDisplay);
    }

    private function onGameOver(ev: GameEvent): Void
    {
        for(part in game.getAllParts()){
            Lib.trace("Fini: " + part.isDone);
        }
    }
}
