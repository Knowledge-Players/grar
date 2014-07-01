package grar;

#if (js || cocktail)
import js.html.IFrameElement;
import js.Browser;
#end

import grar.model.Config;
import grar.Controller;

@:expose("grar")
class App {

	static private var controller : Null<Controller> = null;

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
}