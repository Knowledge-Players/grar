package com.knowledgeplayers.grar.tracking;

import com.knowledgeplayers.grar.structure.part.Identifiable;

/**
* Trackable item
**/
interface Trackable extends Identifiable {
	public var name (default, default):String;
	public var score (default, default):Int;
}
