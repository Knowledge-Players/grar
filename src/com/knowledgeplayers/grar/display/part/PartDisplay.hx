package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.button.CustomEventButton;
import com.knowledgeplayers.grar.display.button.DefaultButton;
import com.knowledgeplayers.grar.display.button.TextButton;
import com.knowledgeplayers.grar.display.container.ScrollPanel;
import com.knowledgeplayers.grar.display.element.Character;
import com.knowledgeplayers.grar.display.ResizeManager;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
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


class PartDisplay extends Sprite
{
	public var part: Part;
	
	private var text: ScrollPanel;
	private var characters: Hash<Character>;
	private var charactersDepth: Hash<Int>;
	private var currentSpeaker: Character;
	private var depth:Int;
	private var displayObjects:Hash<DisplayObject>;
	private var resiz:String;
	private var resizeD:ResizeManager;

	public function new(part: Part)
	{
		super();
		this.part = part;
		characters = new Hash<Character>();
		displayObjects = new Hash<DisplayObject>();
		resizeD = ResizeManager.getInstance();
		
		var display = XmlLoader.load(part.display, onLoadComplete);
		#if !flash
			parseContent(display);
		#end

		addEventListener(TokenEvent.ADD,onTokenAdded);
	}
	
	public function onTokenAdded(e: TokenEvent) : Void
	{		
		for ( p in 1...Lambda.count ( displayObjects ) + 1) {
			if (displayObjects.get(Std.string(p)) != null)
			{ 
     				addChild( displayObjects.get(Std.string(p)) );
			}
		}
	}
	
	public function unLoad() : Void 
	{
		while (numChildren > 0)
			removeChildAt(numChildren - 1);
	}

	// Private
	
	private function parseContent(content: Xml) : Void
	{
		var displayFast: Fast = new Fast(content).node.Display;

		// Background
		if(displayFast.hasNode.Background){
			createBackground(displayFast.node.Background);
		}

		// Items
		for(item in displayFast.nodes.Item) {
			createItem(item);
		}
		
		// Characters
		for (char in displayFast.nodes.Character) {
			createCharacter(char);
		}

		// Button
		for(button in displayFast.nodes.Button){
			createButton(button);
		}

		// Texts
		for(text in displayFast.nodes.Text){
			createText(text);
		}

		for ( p in 1...Lambda.count ( displayObjects ) + 1) {
			if (displayObjects.get(Std.string(p)) != null)
			{ 
     				addChild( displayObjects.get(Std.string(p)) );
			}
		}
		
		resizeD.onResize();
	}

	private function next(event: ButtonActionEvent) : Void
	{
		nextItem();
	}
	
	private function nextItem() : Null<Item>
	{
		var item: Item = part.getNextItem();
		setText(item);
		if (item != null && characters.exists(item.author)) {

			var char = characters.get(item.author);
			
			if (char != currentSpeaker) {
				
				if(currentSpeaker != null){
			//		TweenManager.fadeOut(currentSpeaker);
					currentSpeaker.visible = false;
				}
				if (!contains(char))
					addChild(char);

				else {
					char.alpha = 1;
					char.visible = true;
				}
				currentSpeaker = char;

				char.visible = true;
			}
		}
			
		return item;
	}

	private function initDisplayObject(display: DisplayObject, node: Fast, anime: Bool = false) : Void
	{
		
		if(anime){
			TweenManager.translate(display, new Point(0, 0), new Point(Std.parseFloat(node.att.X), Std.parseFloat(node.att.Y)));
		}
		else{
			display.x = Std.parseFloat(node.att.X);
			display.y = Std.parseFloat(node.att.Y);
		}

		if (node.has.Width)
			display.width = Std.parseFloat(node.att.Width);
		else
			display.scaleX = Std.parseFloat(node.att.ScaleX);
		if(node.has.Height)
			display.height = Std.parseFloat(node.att.Height);
		else
			display.scaleY = Std.parseFloat(node.att.ScaleY);
	}
	
	private function createBackground(bkgNode: Fast) : Void 
	{
		var bkgData: Bitmap = new Bitmap(Assets.getBitmapData(bkgNode.att.Id));
		
		displayObjects.set(bkgNode.att.z, bkgData);
		
		resizeD.addDisplayObjects(bkgData, bkgNode );	
	}
	
	private function createItem(itemNode: Fast) : Void 
	{
		var itemBmp: Bitmap = new Bitmap(Assets.getBitmapData(itemNode.att.Id));
		var itemSprite: Sprite = new Sprite();

		itemSprite.addChild(itemBmp);

		initDisplayObject(itemBmp, itemNode);

		displayObjects.set(itemNode.att.z, itemSprite);
		
		resizeD.addDisplayObjects(itemSprite,itemNode );
	}
	
	private function createButton(buttonNode: Fast) : Void 
	{
		var button: DefaultButton = UiFactory.createButtonFromXml(buttonNode);
		
		initDisplayObject(button, buttonNode);
		
		if (buttonNode.has.Content)
			cast(button, TextButton).setText(Localiser.instance.getItemContent(buttonNode.att.Content), buttonNode.att.Tag);
		if(buttonNode.has.Action)
			setButtonAction(cast(button, CustomEventButton), buttonNode.att.Action);
		else
			button.addEventListener("next", next);
		
		displayObjects.set(buttonNode.att.z, button);
		
		resizeD.addDisplayObjects(button,buttonNode );
	}
	
	private function createText(textNode: Fast):Void 
	{
		var text = new ScrollPanel(Std.parseFloat(textNode.att.Width), Std.parseFloat(textNode.att.Height));
		this.text = text;
		
		//text.x = Std.parseFloat(textNode.att.X);
		//text.y = Std.parseFloat(textNode.att.Y);
		
		initDisplayObject(text,textNode);
		nextItem();
		
		displayObjects.set(textNode.att.z, text);
		resizeD.addDisplayObjects(text, textNode );
	}
	
	private function createCharacter(character: Fast) 
	{
		var id = character.att.Id;
		var char: Character = new Character();
		var bitmap = new Bitmap(Assets.getBitmapData(id));
		char.addChild(bitmap);
		char.visible = false;
		char.origin = new Point(Std.parseFloat(character.att.X), Std.parseFloat(character.att.Y));
		bitmap.x = Std.parseFloat(character.att.X);
		bitmap.y = Std.parseFloat(character.att.Y);
		bitmap.width = Std.parseFloat(character.att.Width);
		bitmap.height = Std.parseFloat(character.att.Height);
		
		var length = id.indexOf(".") - id.lastIndexOf("/") - 1 ;

		characters.set(id.substr(id.lastIndexOf("/") + 1, length), char);

		displayObjects.set(character.att.z, char);

		resizeD.addDisplayObjects(char,character );
	}
	
	private function setButtonAction(button: CustomEventButton, action: String) : Void 
	{
		if(action.toLowerCase() == ButtonActionEvent.NEXT){
			button.addEventListener(action, next);
		}
		else{
			Lib.trace(action + ": this action is not supported for this part");
		}
	}
	
	private function setText(item: Item) : Void 
	{
		if (item == null)
			dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
		else {
			var content = Localiser.getInstance().getItemContent(item.content);
			text.content = KpTextDownParser.parse(content);
		}
	}
	
	// Handlers
	
	private function onLoadComplete(event: Event) : Void 
	{
		parseContent(XmlLoader.getXml(event));
	}
}
