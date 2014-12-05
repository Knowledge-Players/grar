package grar;

#if (js || cocktail)
import js.html.IFrameElement;
import js.Browser;
import js.html.Event;
import js.html.EventTarget;
import js.html.Element;
#end

import grar.model.part.Part.PartInfos;
import grar.model.Config;
import grar.Controller;

@:expose("grar")
class App{

	private static var controller : Null<Controller> = null;
	private static var registeredHook: Map<String, Array<Void->Void>> = null;

	static public function main() : Void {

		if (controller == null) {
			#if (!js && cocktail)
			cocktail.api.Cocktail.boot();
			Browser.window.onload = function(_) init();
			#end
		}
	}

	///
	// Public API
	//

	public static function init(?rootId: Null<String>, ?rootUri: Null<String> = "") : Void {

		var c = new Config();
		c.parseConfigParameter("rootUri", rootUri);

		#if js
		var userAgent = Browser.navigator.userAgent;
		trace(userAgent);
		var isMobile = ~/ipad|iphone|ipod|android|mobile/i.match(userAgent);
		var navigator;
		var er = ~/(chrome|version|firefox|trident)\/(.+?)(\s.*)?$/i;
		if(er.match(userAgent)){
			var nav = er.matched(1).toLowerCase();
			if(nav == "version")
				navigator = Navigator.SAFARI;
			else if(nav == "trident")
				navigator = Navigator.IE;
			else if(nav == "chrome" || nav == "firefox")
				navigator = er.matched(1);
			else
				navigator = Navigator.OTHER;
			c.parseConfigParameter("userAgentName", navigator);
			c.parseConfigParameter("userAgentVersion", er.matched(2));
		}

		c.parseConfigParameter("isMobile", Std.string(isMobile));
		#end

		#if (js || cocktail)
		// Getting root element
		var root : IFrameElement = cast rootId != null ? Browser.document.getElementById(rootId) : null;
		if(root == null){
			root = Browser.document.createIFrameElement();
			root.setAttribute("allowfullscreen", "true");
			// Attribute for Safari
			root.setAttribute("webkitallowfullscreen", "true");
			Browser.document.body.appendChild(root);
		}
		else{
			var allowFS = false;
			for(att in root.attributes){
				if(att.nodeName.indexOf("data-grar-") == 0){
					switch(att.nodeName.substr(10).toLowerCase()){
						// WARNING: nodeValue is obsolete
						case "structure": c.parseConfigParameter( "structureUri", att.nodeValue );
						case "bitrate": c.parseConfigParameter( "bitrate", att.nodeValue );
					}
				}
				else if(att.nodeName.toLowerCase() == "allowfullscreen" && att.nodeValue.toLowerCase() == "true"){
					allowFS = true;
					// Attribute for Safari
					root.setAttribute("webkitallowfullscreen", "true");
				}
			}
			if(!allowFS)
				trace("The root iFrame doesn't allow fullscreen. If you wanted so, set 'allowfullscreen' attribute to true.");
			root.style.display = "block";
		}
		controller = new Controller(c, root);
		#else
		controller = new Controller(c, null);
		#end
		controller.sendReadyHook = function(){
			sendReadyHook();
		}
		controller.sendNewPartHook = function(){
			sendNewPartHook();
		}
		controller.sendFullscreenHook = function(){
			sendFullscreenHook();
		}
		controller.init();
	}

	public static function openMenu(ref:String):Void
	{
		controller.showMenu(ref);
	}

	public static function closeMenu(ref: String):Void
	{
		controller.hideMenu(ref);
	}

	public static function setMasterVolume(volume:Float):Void
	{
		controller.setMasterVolume(volume);
	}

	public static function getMasterVolume(): Float
	{
		return controller.getMasterVolume();
	}

	public static function validateInput(inputId:String, ?value:String, ?dragging: Bool = true):Bool
	{
		return controller.validateInput(inputId, value, dragging);
	}

	public static function getModuleId():String
	{
		return controller.getModuleId();
	}

	public static function getNumParts():Int
	{
		return controller.getNumParts();
	}

	public static function getCurrentPartIndex():Int
	{
		return controller.getCurrentPartIndex();
	}

	public static function getCurrentPartInfos():PartInfos
	{
		return controller.getCurrentPartInfos();
	}

	public static function nextPart():Void
	{
		return controller.nextPart();
	}

	///
	// Hooks
	//

	public static function register(hookType: String, callback: Void -> Void):Void
	{
		if(registeredHook == null)
			registeredHook = new Map();
		if(!registeredHook.exists(hookType))
			registeredHook[hookType] = new Array();

		registeredHook[hookType].push(callback);
	}

	private static function raiseHook(hookType:String):Void
	{
		if(registeredHook != null && registeredHook.exists(hookType)){
			var copy: Array<Void->Void> = registeredHook[hookType].copy();
			while(copy.length > 0){
				copy.shift()();
			}
		}
	}

	private static function removeHook(hookType:String, ?cb: Void -> Void):Void
	{
		if(registeredHook != null && registeredHook.exists(hookType)){
			if(cb != null){
				var i: Iterator<Void -> Void> = registeredHook[hookType].iterator();
				var val = null;
				while(i.hasNext() && val != cb)
					val = i.next();
				if(val == cb)
					registeredHook[hookType].remove(cb);
			}
			else
				registeredHook.remove(hookType);
		}
	}

	private static function removeAllHooks():Void
	{
		registeredHook = null;
	}

	private static function sendReadyHook(): Void
	{
		raiseHook("ready");
	}

	private static function sendNewPartHook(): Void
	{
		raiseHook("new_part");
	}

	private static function sendFullscreenHook(): Void
	{
		raiseHook("fullscreen");
	}
}