package com.knowledgeplayers.sample;

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
        // Load styles
        StyleParser.instance.parse(Assets.getText("xml/style.xml"));
        //Load Ui elements

        // Create a new game
        game = new KpGame();
        game.addEventListener(PartEvent.PART_LOADED, onLoadingComplete);
        game.init(Xml.parse(Assets.getText("xml/sample_structure.xml")));
    }

    private function onLoadingComplete(e: PartEvent): Void
    {
        var gameDisplay = new GameDisplay(game);
        Lib.current.addChild(gameDisplay);
    }
}
