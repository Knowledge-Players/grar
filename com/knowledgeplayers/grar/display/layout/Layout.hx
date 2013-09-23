package com.knowledgeplayers.grar.display.layout;

import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.event.LayoutEvent;
import haxe.xml.Fast;
import flash.Lib;

/**
* Layout of the application
**/
class Layout {
	/**
    * All the child zones of this layout
    **/
	public var zones:Map<String, Zone>;

	/**
    * Content of the layout
    **/
	public var content (get_content, null):Zone;

	/**
    * Name of this layout
    **/
	public var name:String;

	/**
    * Constructor
    * @param    name : Name of the layout
    * @param    content : Content of the layout
    * @param    fast : XML description of the layout
    **/

	public function new(?_name:String, ?_content:Zone, ?_fast:Fast):Void
	{

		zones = new Map<String, Zone>();

		if(_fast != null){
			content = new Zone(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
			content.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
			content.init(_fast);
			name = _fast.att.layoutName;
		}
		else{
			name = _name;
			content = _content;
		}
	}

	public function get_content():Zone
	{
		return content;
	}

	public function updateDynamicFields():Void
	{
		for(zone in zones){
			for(field in zone.dynamicFields){
				field.field.setContent(Localiser.instance.getItemContent(field.content.substr(1)));
				field.field.updateX();
			}
		}
	}

	// Handlers

	private function onNewZone(e:LayoutEvent):Void
	{
		zones.set(e.ref, e.zone);
	}
}
