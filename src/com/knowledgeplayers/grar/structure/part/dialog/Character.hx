package com.knowledgeplayers.grar.structure.part.dialog;

import com.knowledgeplayers.grar.localisation.Localiser;
class Character {

    public var ref (default, default): String;

    public function new(?ref: String)
    {
        this.ref = ref;
    }

    public function getName(): String
    {
        return Localiser.instance.getItemContent(ref);
    }
}
