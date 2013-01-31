package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.structure.part.Pattern;
import haxe.unit.TestCase;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.PartFactory;
import haxe.xml.Fast;
import nme.Assets;
import nme.events.EventDispatcher;
import nme.Lib;
import nme.media.Sound;
import nme.media.SoundChannel;

import nme.events.Event;

import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.factory.ActivityFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.XmlLoader;
import com.knowledgeplayers.grar.factory.PatternFactory;

class StructurePart extends EventDispatcher, implements Part {

    /**
    * Array of the patterns composing the dialog
    */
    public var patterns (default, null): Array<Pattern>;

    /**
     * Name of the part
     */
    public var name (default, default): String;

    /**
     * ID of the part
     */
    public var id (default, default): Int;

    /**
     * Path to the XML structure file
     */
    public var file (default, null): String;

    /**
     * Path to the XML display file
     */
    public var display (default, default): String;

    /**
     * True if the part is done
     */
    public var isDone (default, default): Bool;

    /**
     * Misc options for the part
     * @todo Do something with the options
     */
    public var options (default, null): Hash<String>;

    /**
     * Hash of the sub-parts
     */
    public var parts (default, null): IntHash<Part>;

    /**
     * Inventory specific to the part
     */
    public var inventory (default, null): Array<String>;

    /**
     * Sound playing during the part
     */
    public var soundLoop (default, default): Sound;

    /**
    * Elements of the part
**/
    public var elements (default, null): Array<PartElement>;

    /**
    * Characters of the part
**/
    public var characters (default, null): Hash<Character>;

    private var nbSubPartLoaded: Int = 0;
    private var nbSubPartTotal: Int = 0;
    private var partIndex: Int = 0;
    private var elemIndex: Int = 0;
    private var soundLoopChannel: SoundChannel;

    public function new()
    {
        super();
        parts = new IntHash<Part>();
        options = new Hash<String>();
        inventory = new Array<String>();
        elements = new Array<PartElement>();
        patterns = new Array<Pattern>();
        addEventListener(TokenEvent.ADD, onAddToken);
    }

    /**
     * Initialise the part with an XML node
     * @param	xml : fast node with structure infos
     * @param	filePath : path to an XML structure file (set the file variable)
     */

    public function init(xml: Fast, filePath: String = ""): Void
    {
        file = filePath;

        if(xml != null){
            parseXml(xml);
        }

        if(file != ""){
            XmlLoader.load(file, onLoadComplete, parseContent);
        }
        else
            fireLoaded();
    }

    /**
     * Start the part if it hasn't been done
     * @param	forced : true to start the part even if it has already been done
     * @return this part, or null if it can't be start
     */

    public function start(forced: Bool = false): Null<Part>
    {
        if(!isDone || forced){
            enterPart();
            return this;
        }
        else
            return null;
    }

    /**
     * @return the next element in the part or null if the part is over
     */

    public function getNextElement(): Null<PartElement>
    {
        if(elemIndex < elements.length){
            elemIndex++;
            return elements[elemIndex - 1];
        }
        else{
            exitPart();
            return null;
        }
    }

    /**
     * @return the next undone part
     */

    public function getNextPart(): Null<Part>
    {
        var part: Part = null;
        if(hasParts()){
            if(partIndex == Lambda.count(parts)){
                exitPart();
                return null;
            }
            part = parts.get(partIndex).getNextPart();
            if(part == null){
                partIndex++;
                part = getNextPart();
            }
        }
        if(part != null)
            return part.start();
        else
            return part;
    }

    /**
     * Tell if this part has sub-part or not
     * @return true if it has sub-part
     */

    public function hasParts(): Bool
    {
        return partsCount() != 0;
    }

    /**
     * @return the number of sub-part
     */

    public function partsCount(): Int
    {
        return Lambda.count(parts);
    }

    /**
     * @return the number of activities in the part
     */

    public function activitiesCount(): Int
    {
        var nbAct = 0;
        for(elem in elements){
            if(elem.isActivity())
                nbAct++;
        }
        return nbAct;
    }

    /**
     * @return all the sub-part of this part
     */

    public function getAllParts(): Array<Part>
    {
        var array = new Array<Part>();
        if(hasParts()){
            for(part in parts){
                array = array.concat(part.getAllParts());
            }
        }
        else
            array.push(this);
        return array;
    }

    /**
     * @return a string-based representation of the part
     */

    override public function toString(): String
    {
        return "Part " + name + " " + file + " has " +
        (hasParts() ? "parts: \n" + parts.toString() : "no part");
    }

    public function restart(): Void
    {
        elemIndex = 0;
    }

    /**
     * Tell if this part is a dialog
     * @return true if this part is a dialog
     */

    public function isDialog(): Bool
    {
        return false;
    }

    public function isStrip(): Bool
    {
        return false;
    }
    // Private

    private function parseContent(content: Xml): Void
    {
        var partFast: Fast = new Fast(content).node.Part;

        for(child in partFast.elements){
            switch(child.name.toLowerCase()){
                case "item": elements.push(new TextItem(child));
                case "activity": elements.push(ActivityFactory.createActivityFromXml(child));
            }
        }
        for(char in partFast.nodes.Character){
            characters.set(char.att.Ref, new Character(char.att.Ref));
        }

        for(patternNode in partFast.nodes.Pattern){
            var pattern: Pattern = PatternFactory.createPatternFromXml(patternNode, patternNode.att.Id);
            pattern.init(patternNode);
            patterns.push(pattern);
        }
        fireLoaded();
    }

    private function parseXml(xml: Fast): Void
    {
        id = Std.parseInt(xml.att.Id);
        if(xml.has.Name) name = xml.att.Name;
        if(xml.has.File) file = xml.att.File;
        if(xml.has.Display) display = xml.att.Display;

        if(xml.hasNode.Sound)
            soundLoop = Assets.getSound(xml.node.Sound.att.Content);

        if(xml.hasNode.Part){
            for(partNode in xml.nodes.Part){
                nbSubPartTotal++;
            }
            for(partNode in xml.nodes.Part){
                var part: Part = PartFactory.createPartFromXml(partNode);
                part.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
                part.addEventListener(TokenEvent.ADD, onAddToken);
                part.init(partNode);
                parts.set(Std.parseInt(partNode.att.Id), part);
            }
        }
        if(xml.has.Options){
            for(option in xml.att.Options.split(";")){
                if(option != ""){
                    var key: String = StringTools.trim(option.split(":")[0]);
                    var value: String = StringTools.trim(option.split(":")[1]);
                    options.set(key, value);
                }
            }
        }
    }

    // Handlers

    private function onLoadComplete(event: Event): Void
    {
        parseContent(XmlLoader.getXml(event));
    }

    private function enterPart(): Void
    {
        Localiser.getInstance().setLayoutFile(file);
        if(soundLoop != null)
            soundLoopChannel = soundLoop.play();
    }

    private function onPartLoaded(event: Event): Void
    {
        nbSubPartLoaded++;
        if(nbSubPartLoaded == nbSubPartTotal){
            fireLoaded();
        }
    }

    private function fireLoaded(): Void
    {
        dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
    }

    private function onAddToken(e: TokenEvent): Void
    {
        if(e.tokenTarget == "activity"){
            e.stopImmediatePropagation();
            inventory.push(e.tokenId);
        }
        else{
            var globalEvent = new TokenEvent(TokenEvent.ADD_GLOBAL, e.tokenId, e.tokenType, e.tokenTarget);
            dispatchEvent(globalEvent);
        }
    }

    private function exitPart(): Void
    {
        isDone = true;
        if(soundLoopChannel != null)
            soundLoopChannel.stop();
        dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
    }
}
