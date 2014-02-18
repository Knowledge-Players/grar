package grar.view;

import grar.view.contextual.NotebookDisplay;
import grar.view.contextual.menu.MenuDisplay;

import grar.view.element.TokenNotification;

#if (flash || openfl)
import flash.display.BitmapData;
#end

import haxe.ds.StringMap;

class Application {
	
	public function new() {

		// note: if we were to support several instances of GRAR, 
		// we should pass here the targetted API's root element of 
		// the GRAR instance.
	}

	public var menu (default, set) : MenuDisplay;

	public var notebook (default, set) : NotebookDisplay;

	public var tokenNotification (default, set) : TokenNotification;

#if (flash || openfl)
	public var tokensImages (default, set) : StringMap<{ small : BitmapData, large : BitmapData }>;
#else
	public var tokensImages (default, set) : StringMap<{ small : String, large : String }>;
#end

	
	///
	// GETTER / SETTER
	//

	public function set_menu(v : MenuDisplay) : MenuDisplay {

		if (v == menu) {

			return menu;
		}
		menu = v;

		onMenuChanged();

		return menu;
	}

	public function set_notebook(v : NotebookDisplay) : NotebookDisplay {

		if (v == notebook) {

			return notebook;
		}
		notebook = v;

		onNotebookChanged();

		return notebook;
	}

	public function set_tokenNotification(v : TokenNotification) : TokenNotification {

		if (v == tokenNotification) {

			return tokenNotification;
		}
		tokenNotification = v;

		onTokenNotificationChanged();

		return tokenNotification;
	}

#if (flash || openfl)
	public function set_tokensImages(v : StringMap<small:BitmapData,large:BitmapData}>) : StringMap<{small:BitmapData,large:BitmapData}> {
#else
	public function set_tokensImages(v : StringMap<small:String,large:String}>) : StringMap<{small:String,large:String}> {
#end

		if (v == tokensImage) {

			return tokensImage;
		}
		tokensImage = v;

		onTokensImageChanged();

		return tokensImage;
	}


	///
	// CALLBACKS
	//

	public dynamic function onTokenNotificationChanged() : Void { }

	public dynamic function onNotebookChanged() : Void { }

	public dynamic function onMenuChanged() : Void { }

	public dynamic function onTokensImageChanged() : Void { }

}