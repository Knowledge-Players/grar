package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.display.button.CustomEventButton;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.dialog.DialogPart;
import com.knowledgeplayers.grar.structure.part.dialog.item.ChoiceItem;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import haxe.xml.Fast;
import nme.Assets;
import nme.display.Bitmap;
import nme.events.Event;
import nme.Lib;

/**
 * ...
 * @author jbrichardet
 */

class DialogDisplay extends PartDisplay
{
	private var verticalButton: CustomEventButton;
	private var tokens: Hash<Bitmap>;
	private var displayedToken: Bitmap;
	private var activityDisplay: ActivityDisplay;
	

	public function new(part: DialogPart) 
	{
		tokens = new Hash<Bitmap>();
		resizeD = ResizeManager.getInstance();
		super(part);
	}
	
	public function vertical(event: ButtonActionEvent) : Void
	{
		var item: Item = cast(part, DialogPart).getNextVerticalIndex();
		if (item != null)
		{
			setText(item);
		
			if (item.hasVerticalFlow() && cast(item, ChoiceItem).hasToken()) 
			{
				var token: Bitmap = tokens.get(cast(item, ChoiceItem).tokenId);
				if(token != null)
				{
					displayedToken = token;
					for ( p in 1...Lambda.count ( displayObjects ) + 1)
					{
						if (displayObjects.get(Std.string(p)) != null)
						{
							displayObjects.get(Std.string(p)).visible = true;
			     		}
					}
				}
			}	
			else
			{
				Lib.trace("Token's ID is not referenced in the display");
			}
		}		
	}
	
	override private function setButtonAction(button: CustomEventButton, action: String) : Void 
	{
		var listener: ButtonActionEvent -> Void = null;
		switch(action.toLowerCase()) {
			case ButtonActionEvent.NEXT: 			listener = next;
			case ButtonActionEvent.VERTICAL_FLOW:   listener = vertical;
													verticalButton = button;
													verticalButton.enabled = false;
			default: Lib.trace(action + ": this action is not supported for this part");
		}
		
		button.addEventListener(action.toLowerCase(), listener);
	}
	
	override private function nextItem() : Null<Item>
	{
		if(displayedToken != null){
			removeChild(displayedToken);
			displayedToken = null;
		}
		var item = super.nextItem();
		if (item == null)
			return item;
			
		if(item.hasVerticalFlow())
			verticalButton.enabled = true;
		else
			verticalButton.enabled = false;
		if (item.hasActivity()) {
			launchActivity(cast(item, RemarkableEvent).activity);
		}
			
		return item;
	}
	
	private function launchActivity(activity: Activity) 
	{
		visible = false;
		
		activity.addEventListener(PartEvent.EXIT_PART, onActivityEnd);
		var activityName: String = Type.getClassName(Type.getClass(activity));
		activityName = activityName.substr(activityName.lastIndexOf(".")+1);
		activityDisplay = ActivityManager.instance.getActivity(activityName);
		activityDisplay.addEventListener(Event.COMPLETE, onActivityReady);
		activityDisplay.model = activity;
		
		parent.addChild(activityDisplay);
	}
	
	private function onActivityEnd(e:PartEvent):Void 
	{
		cast(e.target, Activity).removeEventListener(PartEvent.EXIT_PART, onActivityEnd);
		nextItem();
		visible = true;
	}
	
	private function onActivityReady(e:Event):Void 
	{
		activityDisplay.startActivity();		
	}
	
	override private function parseContent(content: Xml) : Void 
	{
		super.parseContent(content);
		
		var displayFast: Fast = new Fast(content).node.Display;
		for (tokenNode in displayFast.nodes.Token) {
			var token: Bitmap = new Bitmap(Assets.getBitmapData(tokenNode.att.Id));
			token.visible =false;
			initDisplayObject(token, tokenNode);

			resizeD.addDisplayObjects(token, tokenNode );
			displayObjects.set(tokenNode.att.z, token);
			tokens.set(tokenNode.att.Name, token);
			
			dispatchEvent(new TokenEvent(TokenEvent.ADD, true));
		}
	}
}