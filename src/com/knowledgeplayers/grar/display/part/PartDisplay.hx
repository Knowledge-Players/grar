package com.knowledgeplayers.grar.display.part;

import aze.display.TileSprite;
import aze.display.TileLayer;
import aze.display.SparrowTilesheet;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.display.element.CharacterDisplay;
import com.knowledgeplayers.grar.display.ResizeManager;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.util.LoadData;
import com.knowledgeplayers.grar.util.SpriteSheetLoader;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.FastList;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.geom.Point;
import nme.Lib;

/**
 * Display of a part
 */
class PartDisplay extends Sprite {
    /**
     * Part model to display
     */
    public var part: Part;

    /**
    * Transition to play at the beginning of the part
    **/
    public var transitionIn (default, default): String;

    /**
    * Transition to play at the end of the part
    **/
    public var transitionOut (default, default): String;

    private var resizeD: ResizeManager;
    private var currentSpeaker: CharacterDisplay;
    private var previousBackground: {ref: String, bmp: Bitmap};
    private var displays: Hash<{obj: DisplayObject, z: Int}>;
    private var displaysFast: Hash<Fast>;
    private var spritesheets: Hash<SparrowTilesheet>;
    private var zIndex: Int = 0;
    private var displayArea: Sprite;
    private var currentElement: PartElement;
    private var displayFast: Fast;
    private var numSpriteSheetsLoaded: Int = 0;
    private var totalSpriteSheets: Int = 0;
    private var textGroups: Hash<Hash<{obj: Fast, z: Int}>>;
    private var layers: Hash<TileLayer>;

    /**
     * Constructor
     * @param	part : Part to display
     */

    public function new(part: Part)
    {
        super();
        this.part = part;

        displaysFast = new Hash<Fast>();
        displays = new Hash<{obj: DisplayObject, z: Int}>();
        textGroups = new Hash<Hash<{obj: Fast, z: Int}>>();

        resizeD = ResizeManager.getInstance();
        spritesheets = new Hash<SparrowTilesheet>();
        layers = new Hash<TileLayer>();

        displayArea = this;

        XmlLoader.load(part.display, onLoadComplete, parseContent);

        addEventListener(TokenEvent.ADD, onTokenAdded);

    }

    /**
     * Unload the display from the scene
     */

    public function unLoad(): Void
    {
        while(numChildren > 0)
            removeChildAt(numChildren - 1);
    }

    /**
    * @return the TextItem in the part or null if there is an activity or the part is over
    **/

    public function nextElement(): Void
    {
        currentElement = part.getNextElement();
        if(currentElement == null){
            dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
            return;
        }
        if(currentElement.isText()){
            var groupKey = "";
            if(textGroups != null){

                for(key in textGroups.keys()){

                    if(textGroups.get(key).exists(cast(currentElement, TextItem).ref)){

                        groupKey = key;
                    }
                }

                if(groupKey != ""){

                    var isFirst = true;
                    var textItem = null;
                    for(keyG in textGroups.get(groupKey).keys()){

                        //Lib.trace("keyG : "+keyG);
                        if(!isFirst){
                            textItem = cast(part.getNextElement(), TextItem);

                        }
                        else{
                            textItem = cast(currentElement, TextItem);
                        }

                        isFirst = false;
                        setText(cast(textItem, TextItem), true);

                    }
                }
                else{
                    setText(cast(currentElement, TextItem));
                }
            }
        }
        else if(currentElement.isActivity()){
            GameManager.instance.displayActivity(cast(currentElement, Activity));
        }
        else if(currentElement.isPattern()){
            if(Localiser.instance.layoutPath != part.file){
                Localiser.instance.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleLoaded);
                Localiser.instance.setLayoutFile(part.file);
            }
            else
                startPattern(cast(currentElement, Pattern));
        }
        else if(currentElement.isPart()){
            var event = new PartEvent(PartEvent.ENTER_SUB_PART);
            event.part = cast(currentElement, Part);
            dispatchEvent(event);
        }
    }

    /**
    * Start the part
    **/

    public function startPart(): Void
    {
        TweenManager.applyTransition(this, transitionIn);
        nextElement();
    }

    // Private

    private function onTokenAdded(e: TokenEvent): Void
    {}

    private function parseContent(content: Xml): Void
    {
        displayFast = new Fast(content).node.Display;
        if(displayFast.has.transitionIn)
            transitionIn = displayFast.att.transitionIn;
        if(displayFast.has.transitionOut)
            transitionOut = displayFast.att.transitionOut;

        totalSpriteSheets = Lambda.count(displayFast.nodes.SpriteSheet);

        if(totalSpriteSheets > 0){
            for(child in displayFast.nodes.SpriteSheet){
                var loader = new SpriteSheetLoader();
                loader.addEventListener(Event.COMPLETE, onSpriteSheetLoaded);

                loader.init(child.att.id, child.att.src);
                //Lib.trace("child.att.id : "+child.att.id);
            }
        }
        else{
            createDisplay();
        }

        resizeD.onResize();
    }

    private function createDisplay(): Void
    {
        for(child in displayFast.elements){
            switch(child.name.toLowerCase()){
                case "background": createBackground(child);
                case "item": createItem(child);
                case "character": createCharacter(child);
                case "button": createButton(child);
                case "text": createText(child);
                case "textgroup":createTextGroup(child);

            }
        }

        dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
    }

    private function next(event: ButtonActionEvent): Void
    {
        nextElement();
    }

    private function startPattern(pattern: Pattern): Void
    {
        currentElement = pattern;

    }

    private function initDisplayObject(display: DisplayObject, node: Fast, ?transition: String): Void
    {
        display.x = Std.parseFloat(node.att.x);
        display.y = Std.parseFloat(node.att.y);

        if(node.has.width)
            display.width = Std.parseFloat(node.att.width);
        else if(node.has.scaleX)
            display.scaleX = Std.parseFloat(node.att.scaleX);
        if(node.has.height)
            display.height = Std.parseFloat(node.att.height);
        else if(node.has.scaleY)
            display.scaleY = Std.parseFloat(node.att.scaleY);
    }

    private function createBackground(bkgNode: Fast): Void
    {
        displaysFast.set(bkgNode.att.ref, bkgNode);
        zIndex++;
    }

    private function createItem(itemNode: Fast): Void
    {
        if(itemNode.has.src){
            var itemBmp: Bitmap = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(itemNode.att.src), Bitmap).bitmapData);
            addElement(itemBmp, itemNode);
        }
        else{
            var itemTile = new TileSprite(itemNode.att.id);
            layers.get(itemNode.att.spritesheet).addChild(itemTile);
            addElement(layers.get(itemNode.att.spritesheet).view, itemNode);
        }

    }

    private function createButton(buttonNode: Fast): Void
    {
        var button: DefaultButton = UiFactory.createButtonFromXml(buttonNode);

        if(buttonNode.has.action)
            setButtonAction(cast(button, CustomEventButton), buttonNode.att.action);
        else
            button.addEventListener("next", next);

        addElement(button, buttonNode);
    }

    private function createText(textNode: Fast): Void
    {
        var background: String = textNode.has.background ? textNode.att.background : null;
        var spritesheet = null;
        if(background != null && background.indexOf(".") < 0)
            spritesheet = spritesheets.get(textNode.att.background);

        var scrollable: Bool;
        if(textNode.has.scrollable)
            scrollable = textNode.att.scrollable == "true";
        else
            scrollable = true;

        var text = new ScrollPanel(Std.parseFloat(textNode.att.width), Std.parseFloat(textNode.att.height), scrollable, spritesheet);
        if(spritesheet != null && background != null)
            text.background = background;

        addElement(text, textNode);
    }

    private function createTextGroup(textNode: Fast): Void
    {

        var numIndex = 0;
        var hashTextGroup = new Hash<{obj: Fast, z: Int}>();

        for(child in textNode.elements){
            if(child.name.toLowerCase() == "text"){

                //createText(child);
                var text = new ScrollPanel(Std.parseFloat(child.att.width), Std.parseFloat(child.att.height));
                text.setBackground(child.att.background);
                hashTextGroup.set(child.att.ref, {obj:child, z:numIndex});

                addElement(text, child);

                numIndex++;

            }
        }
        textGroups.set(textNode.att.ref, hashTextGroup);
    }

    private function createCharacter(character: Fast)
    {
        var char: CharacterDisplay = new CharacterDisplay(spritesheets.get(character.att.spritesheet), character.att.id, new Character(character.att.ref));
        char.visible = false;
        char.origin = new Point(Std.parseFloat(character.att.x), Std.parseFloat(character.att.y));
        addElement(char, character);

    }

    private function setButtonAction(button: CustomEventButton, action: String): Void
    {
        if(action.toLowerCase() == ButtonActionEvent.NEXT){
            button.addEventListener(action.toLowerCase(), next);
        }
    }

    private function setText(item: TextItem, ?_textGroup: Bool = false): Void
    {
        Lib.trace(item);
        // Clean previous background
        if(previousBackground != null && previousBackground.ref != item.background){
            if(previousBackground.bmp != null)
                displayArea.removeChild(previousBackground.bmp);
        }
        // Add new background

        if(item.background != null){
            var bkg = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(displaysFast.get(item.background).att.src), Bitmap).bitmapData);
            if(bkg != null){
                displayArea.addChildAt(bkg, 0);
            }

            previousBackground = {ref: item.background, bmp: bkg};
            if(bkg != null)
                resizeD.addDisplayObjects(bkg, displaysFast.get(item.background));
        }
        // Remove text area if there is no text
        if(item.content == null){
            var toRemove = new FastList<DisplayObject>();

            if(!_textGroup){

                for(i in 0...numChildren){
                    if(Std.is(getChildAt(i), CharacterDisplay) || Std.is(getChildAt(i), ScrollPanel))
                        toRemove.add(getChildAt(i));
                }
                for(obj in toRemove)
                    removeChild(obj);
            }

        }
        else{
            // Set text and display author

            var content = Localiser.getInstance().getItemContent(item.content);

            if(item.author != null && displays.exists(item.author)){

                var char = cast(displays.get(item.author).obj, CharacterDisplay);

                if(!_textGroup){
                    if(char != currentSpeaker){

                        if(currentSpeaker != null && !Std.is(this, StripDisplay)){
                            currentSpeaker.visible = false;
                        }
                        else{
                            char.alpha = 1;
                            char.visible = true;
                        }
                        currentSpeaker = char;
                        TweenManager.applyTransition(currentSpeaker, item.transition);

                        char.visible = true;
                    }

                    if(item.ref != null){
                        var name = currentSpeaker.model.getName();

                        if(displays.get(item.ref) != null){
                            if(name != null)
                                cast(displays.get(item.ref).obj, ScrollPanel).content = KpTextDownParser.parse("*" + name + "*\n" + content);
                            else
                                cast(displays.get(item.ref).obj, ScrollPanel).content = KpTextDownParser.parse(content);
                        }
                    }
                }
                else{
                    char.alpha = 1;
                    char.visible = true;
                    addChild(char);

                    var name = char.model.getName();

                    if(displays.get(item.ref) != null){
                        if(name != null)
                            cast(displays.get(item.ref).obj, ScrollPanel).content = KpTextDownParser.parse("*" + name + "*\n" + content);
                        else
                            cast(displays.get(item.ref).obj, ScrollPanel).content = KpTextDownParser.parse(content);
                    }

                    addChild(cast(displays.get(item.ref).obj, ScrollPanel));

                }

            }
            else if(item.ref != null)
                cast(displays.get(item.ref).obj, ScrollPanel).content = KpTextDownParser.parse(content);

            displayPart(_textGroup);
        }

    }

    private function displayPart(?_textGroup: Bool = false): Void
    {
        if(!_textGroup){
            while(numChildren > 1)
                removeChildAt(numChildren - 1);

            var array = new Array<{obj: DisplayObject, z: Int}>();

            for(key in displays.keys()){

                if(mustBeDisplayed(key))
                    array.push(displays.get(key));
            }

            array.sort(sortDisplayObjects);
            for(obj in array){
                addChild(obj.obj);
            }
        }
        else{
            for(key in displays.keys()){
                if(Std.is(displays.get(key).obj, TextButton)){

                    addChild(displays.get(key).obj);
                }

            }
        }

        for(layer in layers){
            layer.render();
        }
    }

    /*
        TODO: refactoriser tout ça !
     */

    private function mustBeDisplayed(key: String): Bool
    {
        var object = displays.get(key);
        var textItem: TextItem = null;

        if(currentElement.isText()){
            textItem = cast(currentElement, TextItem);
        }
        else if(currentElement.isPattern() && Std.is(object.obj, DefaultButton)){

            var pattern = cast(currentElement, Pattern);
            if(Std.is(displays.get(key).obj, TextButton)){
                if(pattern.buttons.exists(key)){
                    cast(displays.get(key).obj, TextButton).setText(Localiser.instance.getItemContent(pattern.buttons.get(key)));
                    return true;
                }
                else
                    return false;
            }
            else if(pattern.buttons.exists(key))
                return true;
            else
                return false;
        }
        if(Std.is(object.obj, ScrollPanel) && textItem != null && key != textItem.ref)
            return false;
        if(Std.is(object.obj, CharacterDisplay) && object.obj != currentSpeaker)
            return false;
        return true;
    }

    private function addElement(elem: DisplayObject, node: Fast): Void
    {
        initDisplayObject(elem, node);
        if(node.has.id && !node.has.ref){
            displays.set(node.att.id, {obj: elem, z: zIndex});
            displaysFast.set(node.att.id, node);
        }
        else if(!node.has.ref){
            displays.set(node.att.src, {obj: elem, z: zIndex});
            displaysFast.set(node.att.src, node);
        }
        else{
            displays.set(node.att.ref, {obj: elem, z: zIndex});
            displaysFast.set(node.att.ref, node);
        }
        resizeD.addDisplayObjects(elem, node);
        zIndex++;
    }

    private function sortDisplayObjects(x: {obj: DisplayObject, z: Int}, y: {obj: DisplayObject, z: Int}): Int
    {
        if(x.z < y.z)
            return -1;
        else if(x.z > y.z)
            return 1;
        else
            return 0;
    }

    // Handlers

    private function onLoadComplete(event: Event): Void
    {
        parseContent(XmlLoader.getXml(event));
    }

    private function onLocaleLoaded(ev: LocaleEvent): Void
    {
        startPattern(cast(currentElement, Pattern));
    }

    private function onSpriteSheetLoaded(ev: Event): Void
    {
        ev.target.removeEventListener(Event.COMPLETE, onSpriteSheetLoaded);
        spritesheets.set(ev.target.name, ev.target.spriteSheet);
        var layer = new TileLayer(ev.target.spriteSheet);
        layers.set(ev.target.name, layer);
        numSpriteSheetsLoaded++;
        if(numSpriteSheetsLoaded == totalSpriteSheets){
            createDisplay();
        }
    }
}
