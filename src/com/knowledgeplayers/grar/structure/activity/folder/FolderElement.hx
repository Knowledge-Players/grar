package com.knowledgeplayers.grar.structure.activity.folder;

class FolderElement {
    public var content (default, default): String;
    public var isAnswer (default, default): Bool;

    public function new(content: String, isAnswer: Bool = false)
    {
        this.content = content;
        this.isAnswer = isAnswer;
    }
}
