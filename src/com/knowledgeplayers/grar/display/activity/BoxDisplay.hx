package com.knowledgeplayers.grar.display.activity;

import nme.display.Sprite;
import com.knowledgeplayers.grar.structure.activity.Box;

class BoxDisplay extends Sprite
{
    private var resizeD:ResizeManager;

    public function new(box:Box):Void
    {
        super();

        resizeD = ResizeManager.getInstance();

    }

    /**
    * Construct a case
    */
    public function constructBox():Void
    {

    }



}