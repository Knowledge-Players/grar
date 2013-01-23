package com.knowledgeplayers.grar.structure.part.dialog.conclusion;

import com.knowledgeplayers.grar.structure.part.dialog.conclusion.ConclusionActivity;

class Fetch extends ConclusionActivity {
    public var content (default, default): String;

    public function new(content: String)
    {
        super();

        this.content = content;
    }

    override function finishWithFetch(): Bool
    {
        return false;
    }

    override function getType(): ConclusionType
    {
        return ConclusionType.FETCH;
    }
}