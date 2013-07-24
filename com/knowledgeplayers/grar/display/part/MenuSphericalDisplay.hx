package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.util.Curve;
import nme.geom.Point;
import haxe.xml.Fast;

/**
 * Display of a spherical menu
 */
class MenuSphericalDisplay extends MenuDisplay {

	private var curves: Map<String, Curve>;

	public function new()
	{
		super();
		curves = new Map<String, Curve>();
	}

	override private function createMenuLevel(level:Xml):Void
	{
		if(!levelDisplays.exists(level.nodeName))
			throw "Display not specified for tag " + level.nodeName;

		var fast:Fast = levelDisplays.get(level.nodeName);

		var button = addButton(fast.node.Button, GameManager.instance.getItemName(level.get("id")));
		buttons.set(level.get("id"), button);

		var curve: Curve;
		if(curves.exists(level.nodeName)){
			curve = curves.get(level.nodeName);
		}
		else{
			curve = new Curve(new Point(fast.att.x, fast.att.y), fast.att.radius);
			if(fast.has.minAngle) curve.minAngle = fast.att.minAngle;
			if(fast.has.maxAngle) curve.maxAngle = fast.att.maxAngle;
			curves.set(level.nodeName, curve);
		}
		curve.add(button);
		addChild(button);

		for(elem in level.elements())
			createMenuLevel(elem);
	}
}