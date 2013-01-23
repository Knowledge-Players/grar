package com.knowledgeplayers.grar.structure.part.dialog.conclusion;

class ConclusionActivity {
    private function new()
    {

    }

    public function finishWithFetch(): Bool
    {
        return true;
    }

    public function getType(): ConclusionType
    {
        return null;
    }
}

enum ConclusionType {
    FETCH;
    SKETCH;
    CHECK;
    SHAKE;
}