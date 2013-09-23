package com.knowledgeplayers.grar.structure.activity;

import com.knowledgeplayers.utils.assets.AssetsStorage;

import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.tracking.Trackable;
import haxe.xml.Fast;
import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * Abstract activity
 */
class Activity extends EventDispatcher implements PartElement implements Trackable {
	/**
    * Name of the activity
    **/
	public var name (default, default):String;

	/**
	    * Id of the activity
	    **/
	public var id (default, default):String;
		/**
	     * Score for this activity
	     */
	public var score (default, default):Int = 0;
		/**
	     * Path to the content file
	     */
	public var content (default, default):String;

		/**
	    * Part where the activity is
	    **/
	public var container (default, default):Part;

		/**
	    * Reference of the button which will validate the activity
	    **/
	public var button (default, default):Map<String, Map<String, String>>;

		/**
	    * Reference to the background for the activity
	    **/
	public var background (default, default):String;

		/**
	    * Localisation key for the instructions
	    **/
	public var instructionContent (default, default):String;

		/**
	    * Reference to the text zone where to display instructions
	    **/
	public var ref (default, default):String;

		/**
	    * Mode of control.
	    * If end, the control is done when the activity is validated.
	    **/
	public var controlMode (default, default):String;

		/**
	    * Token won in this activity
	    **/
	public var token (default, default):String;

		/**
		* Pattern to go when the activity is over
		**/
	public var nextPattern (default, default):String;

	public var endScreen (default, null):Bool = false;

	private var thresholds:Array<{score:Int, next:String}>;

	/**
	     * True if the activity has been done
	     */
	private var isEnded:Bool;

		/**
	     * Constructor
	     * @param	content : Path to the content file
	     */

	private function new(content:String)
	{
		super();
		this.content = content;
		button = new Map<String, Map<String, String>>();
		isEnded = false;
		thresholds = new Array<{score:Int, next:String}>();

		parseContent(AssetsStorage.getXml(content));
	}

		/**
	     * Load the activity. Must be done before the start
	     */

	public function loadActivity():Void
	{
		Localiser.instance.pushLocale();
		Localiser.instance.layoutPath = content;
	}

		/**
	     * Start the activity
	     */

	public function startActivity():Void
	{}

		/**
	     * Stop the activity, set it to done
	     */

	public function endActivity():Void
	{
		if(!isEnded){
			isEnded = true;
			Localiser.instance.popLocale();
			for(threshold in thresholds){
				if(score >= threshold.score){
					nextPattern = threshold.next;
					break;
				}
			}
			dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
		}
	}

	public function addTreshold(score:String, next:String):Void
	{
		thresholds.push({score: Std.parseInt(score), next: next});
		thresholds.sort(function(x:{score:Int, next:String}, y:{score:Int, next:String}):Int
		{
			if(x.score > y.score)
				return - 1;
			else
				return 1;
		});
	}

		/**
	    * @return false
	**/

	public function isText():Bool
	{
		return false;
	}

		/**
	    * @return true
	**/

	public function isActivity():Bool
	{
		return true;
	}

		/**
	    * @return false
	**/

	public function isPattern():Bool
	{
		return false;
	}

		/**
	    * @return false
	**/

	public function isPart():Bool
	{
		return false;
	}

		/**
	    * @return false
	**/

	public function isVideo():Bool
	{
		return false;
	}

		// Privates

	private function parseContent(content:Xml):Void
	{
		var fast = new Fast(content.firstElement());
		if(fast.has.background)
			background = fast.att.background;
		if(fast.has.instructionContent){
			instructionContent = fast.att.instructionContent;
			ref = fast.att.ref;
		}
		if(fast.has.controlMode)
			controlMode = fast.att.controlMode.toLowerCase();
		else
			controlMode = "auto";
		var child = fast.node.Button;

		button.set(child.att.ref, ParseUtils.parseButtonContent(child));
		if(fast.hasNode.Token)
			token = fast.node.Token.att.ref;
	}
}
