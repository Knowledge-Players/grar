package com.knowledgeplayers.grar.structure.part.dialog.item;

import com.knowledgeplayers.grar.factory.ActivityFactory;
import com.knowledgeplayers.grar.structure.activity.Activity;
import haxe.xml.Fast;
import nme.Lib;

class RemarkableEvent extends TextItem {
	/**
     * Activity to start when this item is reached
     */
	private var activity:Fast;

	/**
     * Constructor
     * @param	xml : fast xml node with structure infos
     */

	public function new(?xml:Fast)
	{
		super(xml);
		activity = xml.node.Activity;
		token = xml.node.Activity.hasNode.Token ? xml.node.Activity.node.Token.att.ref : null;
	}

	/**
	* @return the activity
	**/

	public function getActivity():Null<Activity>
	{
		return ActivityFactory.createActivityFromXml(activity);
	}

	override public function hasActivity():Bool
	{
		return true;
	}
}