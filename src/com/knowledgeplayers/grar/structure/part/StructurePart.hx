package com.knowledgeplayers.grar.structure.part;

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
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import com.knowledgeplayers.grar.factory.ActivityFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.XmlLoader;

class StructurePart extends EventDispatcher, implements Part {
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
     * Array of all the activities in the part
     */
    public var activities (default, null): IntHash<Activity>;

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
     * Text items of the part
     */
    public var items (default, null): Array<Item>;

    /**
    * Characters of the part
**/
    public var characters (default, null): Hash<Character>;

    private var nbSubPartLoaded: Int = 0;
    private var nbSubPartTotal: Int = 0;
    private var itemIndex: Int = 0;
    private var partIndex: Int = 0;
    private var soundLoopChannel: SoundChannel;

    public function new()
    {
        super();
        parts = new IntHash<Part>();
        activities = new IntHash<Activity>();
        options = new Hash<String>();
        inventory = new Array<String>();
        items = new Array<Item>();
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
            var content = XmlLoader.load(file, onLoadComplete);
            #if !flash
				parseContent(content);
            #end
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
     * @return the next item in the part or null if the part is over
     */

    public function getNextElement(): Null<Dynamic>
    {
        if(activities.exists(itemIndex)){
            return activities.get(itemIndex);
        }
        if(itemIndex < items.length){
            itemIndex++;
            return items[itemIndex - 1];
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
        return Lambda.count(activities);
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
        (hasParts() ? "parts: \n" + parts.toString() : "no part") +
        " and " + (activitiesCount() != 0 ? "activities: " + activities.toString() : "no activity") +
        (items.length == 0 ? ". It has no items" : ". It's composed by " + items.toString());
    }

    /**
     * Tell if this part is a dialog
     * @return true if this part is a dialog
     */

    public function isDialog(): Bool
    {
        return false;
    }

    // Private

    private function parseContent(content: Xml): Void
    {
        var partFast: Fast = new Fast(content).node.Part;
        /*for(item in partFast.nodes.Item){
            items.push(new Item(item));
        }
        for(activity in partFast.nodes.Activity){
            activities.set(ActivityFactory.createActivityFromXml(activity));
        }*/
        var position: Int = 0;
        for(child in partFast.elements){
            switch(child.name){
                case "Item": items.push(new Item(child));
                case "Activity": activities.set(position, ActivityFactory.createActivityFromXml(child));
            }
            position++;
        }
        for(char in partFast.nodes.Character){
            characters.set(char.att.Ref, new Character(char.att.Ref));
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
