package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.factory.ItemFactory;
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
     * Name of the part
     */
    public var name (default, default):String;

    /**
     * ID of the part
     */
    public var id (default, default):Int;

    /**
     * Path to the XML structure file
     */
    public var file (default, null):String;

    /**
     * Path to the XML display file
     */
    public var display (default, default):String;

    /**
     * True if the part is done
     */
    public var isDone (default, default):Bool;

    /**
     * Misc options for the part
     * @todo Do something with the options
     */
    public var options (default, null):Hash<String>;

    /**
     * Inventory specific to the part
     */
    public var inventory (default, null):Array<Token>;

    /**
     * Sound playing during the part
     */
    public var soundLoop (default, default):Sound;

    /**
    * Elements of the part
**/
    public var elements (default, null):Array<PartElement>;

    /**
    * Button of the part
    **/
    public var button (default, default):{ref:String, content:String};

    private var nbSubPartLoaded:Int = 0;
    private var nbSubPartTotal:Int = 0;
    private var partIndex:Int = 0;
    private var elemIndex:Int = 0;
    private var soundLoopChannel:SoundChannel;
    private var token:Token;

    public function new()
    {
        super();
        options = new Hash<String>();
        inventory = new Array<Token>();
        elements = new Array<PartElement>();
        addEventListener(TokenEvent.ADD, onAddToken);
    }

    /**
     * Initialise the part with an XML node
     * @param	xml : fast node with structure infos
     * @param	filePath : path to an XML structure file (set the file variable)
     */

    public function init(xml:Fast, filePath:String = ""):Void
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

    public function start(forced:Bool = false):Null<Part>
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

    public function getNextElement():Null<PartElement>
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
     * Tell if this part has sub-part or not
     * @return true if it has sub-part
     */

    public function hasParts():Bool
    {
        for(elem in elements){
            if(elem.isPart())
                return true;
        }
        return false;
    }

    /**
     * @return all the sub-part of this part
     */

    public function getAllParts():Array<Part>
    {
        var array = new Array<Part>();
        if(elements.length > 0)
            array.push(this);
        if(hasParts()){
            for(elem in elements){
                if(elem.isPart())
                    array = array.concat(cast(elem, Part).getAllParts());
            }
        }
        return array;
    }

    /**
    * @return all the activities of this part
    **/

    public function getAllActivities():Array<Activity>
    {
        var activities = new Array<Activity>();
        for(elem in elements){
            if(elem.isPart())
                activities = activities.concat(cast(elem, Part).getAllActivities());
            if(elem.isActivity())
                activities.push(cast(elem, Activity));
        }
        return activities;
    }

    /**
     * @return a string-based representation of the part
     */

    override public function toString():String
    {
        return "Part " + name + " " + file + " : " + elements.toString();
    }

    public function restart():Void
    {
        elemIndex = 0;
    }

    /**
     * Tell if this part is a dialog
     * @return true if this part is a dialog
     */

    public function isDialog():Bool
    {
        return false;
    }

    /**
     * Tell if this part is a strip
     * @return true if this part is a strip
     */

    public function isStrip():Bool
    {
        return false;
    }

    // Implements PartElement

    /**
    * @return false
**/

    public function isActivity():Bool
    {
        return false;
    }

    /**
    * @return false
**/

    public function isText():Bool
    {
        return false;
    }

    /**
    * @return false
**/

    public function isPattern():Bool
    {
        return false;
    }

    /**
    * @return true
**/

    public function isPart():Bool
    {
        return true;
    }

    public function hasToken():Bool
    {
        return token != null;
    }

    // Private

    private function parseContent(content:Xml):Void
    {
        var partFast:Fast = new Fast(content).node.Part;

        for(child in partFast.elements){
            switch(child.name.toLowerCase()){
                case "text":
                    elements.push(ItemFactory.createItemFromXml(child));
                case "activity":
                    elements.push(ActivityFactory.createActivityFromXml(child, this));
                case "part":
                    nbSubPartTotal++;
                    createPart(child);
                case "button":
                    button = {ref: child.att.ref, content: child.has.content ? child.att.content : null};
            }
        }
        for(elem in elements){
            if(elem.isText())
                cast(elem, TextItem).button = button;
        }
        if(nbSubPartLoaded == nbSubPartTotal)
            fireLoaded();
    }

    private function parseXml(xml:Fast):Void
    {
        id = Std.parseInt(xml.att.id);
        if(xml.has.name) name = xml.att.name;
        if(xml.has.file) file = xml.att.file;
        if(xml.has.display) display = xml.att.display;

        if(xml.hasNode.Sound)
            soundLoop = Assets.getSound(xml.node.Sound.att.content);

        if(xml.hasNode.Part){
            for(partNode in xml.nodes.Part){
                nbSubPartTotal++;
            }
            for(partNode in xml.nodes.Part){
                createPart(partNode);
            }
        }
        if(xml.has.Options){
            for(option in xml.att.options.split(";")){
                if(option != ""){
                    var key:String = StringTools.trim(option.split(":")[0]);
                    var value:String = StringTools.trim(option.split(":")[1]);
                    options.set(key, value);
                }
            }
        }
    }

    private function createPart(partNode:Fast):Void
    {
        var part:Part = PartFactory.createPartFromXml(partNode);
        part.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
        part.addEventListener(TokenEvent.ADD, onAddToken);
        part.init(partNode);
        elements.push(part);
    }

    // Handlers

    private function onLoadComplete(event:Event):Void
    {
        parseContent(XmlLoader.getXml(event));
    }

    private function enterPart():Void
    {
        if(soundLoop != null)
            soundLoopChannel = soundLoop.play();
    }

    private function onPartLoaded(event:Event):Void
    {
        nbSubPartLoaded++;
        if(nbSubPartLoaded == nbSubPartTotal){
            fireLoaded();
        }
    }

    private function fireLoaded():Void
    {
        dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
    }

    private function onAddToken(e:TokenEvent):Void
    {
        if(e.token.target == "activity"){
            e.stopImmediatePropagation();
            inventory.push(e.token);
        }
        else{
            var globalEvent = new TokenEvent(TokenEvent.ADD_GLOBAL, e.token);
            dispatchEvent(globalEvent);
        }
    }

    private function exitPart():Void
    {
        isDone = true;
        if(soundLoopChannel != null)
            soundLoopChannel.stop();
        dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
    }
}
