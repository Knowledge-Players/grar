package com.knowledgeplayers.grar.display.part;

import haxe.FastList;
import Math;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.display.part.pattern.PatternDisplay;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import com.knowledgeplayers.grar.display.element.CharacterDisplay;
import com.knowledgeplayers.grar.display.ResizeManager;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.Assets;
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

    private var resizeD: ResizeManager;
    private var activityDisplay: ActivityDisplay;
    private var currentSpeaker: CharacterDisplay;
    private var previousBackground: {ref: String, bmp: Bitmap};
    private var displays: Hash<{obj: DisplayObject, z: Int}>;
    private var displaysFast: Hash<Fast>;
    private var zIndex: Int = 0;
    private var displayArea: Sprite;

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
        resizeD = ResizeManager.getInstance();
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
        var element: PartElement = part.getNextElement();
        if(element == null){
            dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
            return null;
        }
        if(element.isText()){
            setText(cast(element, TextItem));
        }
        else if(element.isActivity()){
            launchActivity(cast(element, Activity));
        }
        else if(element.isPattern()){
            startPattern(cast(element, Pattern));
        }
        return null;
    }

    /**
    * Start the part
**/

    public function startPart(): Void
    {
        nextElement();
    }

    // Private

    private function onTokenAdded(e: TokenEvent): Void
    {}

    private function parseContent(content: Xml): Void
    {
        var displayFast: Fast = new Fast(content).node.Display;
        for(child in displayFast.elements){
            switch(child.name){
                case "Background": createBackground(child);
                case "Item": createItem(child);
                case "Character": createCharacter(child);
                case "Button": createButton(child);
                case "Text": createText(child);
            }
        }
        dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
        resizeD.onResize();
    }

    private function next(event: ButtonActionEvent): Void
    {
        nextElement();
    }

    private function startPattern(pattern: Pattern): Void
    {}

    private function launchActivity(activity: Activity)
    {
        activity.addEventListener(PartEvent.EXIT_PART, onActivityEnd);
        var activityName: String = Type.getClassName(Type.getClass(activity));
        activityName = activityName.substr(activityName.lastIndexOf(".") + 1);
        if(activityDisplay != null)
            removeChild(activityDisplay);
        activityDisplay = ActivityManager.instance.getActivity(activityName);
        activityDisplay.addEventListener(Event.COMPLETE, onActivityReady);
        activityDisplay.model = activity;

    }

    private function onActivityEnd(e: PartEvent): Void
    {
        cast(e.target, Activity).removeEventListener(PartEvent.EXIT_PART, onActivityEnd);
    }

    private function onActivityReady(e: Event): Void
    {
        addChild(activityDisplay);
        activityDisplay.startActivity();
    }

    private function initDisplayObject(display: DisplayObject, node: Fast, anime: Bool = false): Void
    {

        if(anime){
            TweenManager.translate(display, new Point(0, 0), new Point(Std.parseFloat(node.att.X), Std.parseFloat(node.att.Y)));
        }
        else{
            display.x = Std.parseFloat(node.att.X);
            display.y = Std.parseFloat(node.att.Y);
        }

        if(node.has.Width)
            display.width = Std.parseFloat(node.att.Width);
        else
            display.scaleX = Std.parseFloat(node.att.ScaleX);
        if(node.has.Height)
            display.height = Std.parseFloat(node.att.Height);
        else
            display.scaleY = Std.parseFloat(node.att.ScaleY);
    }

    private function createBackground(bkgNode: Fast): Void
    {
        displaysFast.set(bkgNode.att.Ref, bkgNode);
        zIndex++;
    }

    private function createItem(itemNode: Fast): Void
    {
        var itemBmp: Bitmap = new Bitmap(Assets.getBitmapData(itemNode.att.Id));

        addElement(itemBmp, itemNode);
    }

    private function createButton(buttonNode: Fast): Void
    {
        var button: DefaultButton = UiFactory.createButtonFromXml(buttonNode);

        if(buttonNode.has.Content)
            cast(button, TextButton).setText(Localiser.instance.getItemContent(buttonNode.att.Content));
        if(buttonNode.has.Action)
            setButtonAction(cast(button, CustomEventButton), buttonNode.att.Action);
        else
            button.addEventListener("next", next);

        addElement(button, buttonNode);
    }

    private function createText(textNode: Fast): Void
    {
        var text = new ScrollPanel(Std.parseFloat(textNode.att.Width), Std.parseFloat(textNode.att.Height));
        text.background = textNode.att.Background;

        addElement(text, textNode);
    }

    private function createCharacter(character: Fast)
    {
        var bitmap = new Bitmap(Assets.getBitmapData(character.att.Id));
        var char: CharacterDisplay = new CharacterDisplay(bitmap, new Character(character.att.Ref));
        char.visible = false;
        char.origin = new Point(Std.parseFloat(character.att.X), Std.parseFloat(character.att.Y));

        addElement(char, character);
    }

    private function setButtonAction(button: CustomEventButton, action: String): Void
    {
        if(action.toLowerCase() == ButtonActionEvent.NEXT){
            button.addEventListener(action, next);
        }
        else{
            Lib.trace(action + ": this action is not supported for this part");
        }
    }

    private function setText(item: TextItem): Void
    {
        // Clean previous background
        if(previousBackground != null && previousBackground.ref != item.background){
            if(previousBackground.bmp != null)
                displayArea.removeChild(previousBackground.bmp);
        }
        // Add new background
        if(item.background != null){
            var bkg = DisplayUtils.setBackground(displaysFast.get(item.background).att.Id, displayArea);
            previousBackground = {ref: item.background, bmp: bkg};
            if(bkg != null)
                resizeD.addDisplayObjects(bkg, displaysFast.get(item.background));
        }
        // Remove text area if there is no text
        if(item.content == null){
            var toRemove = new FastList<DisplayObject>();
            for(i in 0...numChildren){
                if(Std.is(getChildAt(i), CharacterDisplay) || Std.is(getChildAt(i), ScrollPanel))
                    toRemove.add(getChildAt(i));
            }
            for(obj in toRemove)
                removeChild(obj);
        }
        else{
            // Set text and display author
            var content = Localiser.getInstance().getItemContent(item.content);
            if(item.author != null && displays.exists(item.author)){

                var char = cast(displays.get(item.author).obj, CharacterDisplay);

                if(char != currentSpeaker){

                    if(currentSpeaker != null && !Std.is(this, StripDisplay)){
                        currentSpeaker.visible = false;
                    }
                    else{
                        char.alpha = 1;
                        char.visible = true;
                    }
                    currentSpeaker = char;

                    char.visible = true;
                }
                if(item.ref != null){
                    var name = currentSpeaker.model.getName();
                    if(name != null)
                        cast(displays.get(item.ref).obj, ScrollPanel).content = KpTextDownParser.parse("*" + name + "*\n" + content);
                    else
                        cast(displays.get(item.ref).obj, ScrollPanel).content = KpTextDownParser.parse(content);
                }
            }
            else if(item.ref != null)
                cast(displays.get(item.ref).obj, ScrollPanel).content = KpTextDownParser.parse(content);

            displayPart();
        }
    }

    private function displayPart(): Void
    {
        while(numChildren > 1)
            removeChildAt(numChildren - 1);
        var array = new Array<{obj: DisplayObject, z: Int}>();
        for(key in displays.keys()){
            array.push(displays.get(key));
        }
        array.sort(sortDisplayObjects);
        for(obj in array){
            addChild(obj.obj);
        }
    }

    private function addElement(elem: DisplayObject, node: Fast): Void
    {
        initDisplayObject(elem, node);
        displays.set(node.att.Ref, {obj: elem, z: zIndex});
        displaysFast.set(node.att.Ref, node);
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
}
