package com.knowledgeplayers.grar.structure.part.dialog;

/**
 * Introduction to the dialog
 * @author jbrichardet
 */
class Intro {
    public var characterCard: Hash<String>;
    public var introText: String;

    public function new(introText: String = null, characterCard: Hash<String> = null)
    {
        this.introText = introText;
        this.characterCard = characterCard;
    }
}