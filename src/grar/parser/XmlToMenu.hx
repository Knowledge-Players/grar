package grar.parser;

import grar.view.KpDisplay;
import grar.view.contextual.menu.MenuDisplay;

class XmlToMenu {

	static public function parseView(xml : Xml) : MenuDisplay {

		var kd : KpDisplayData;
		var orientation : String;
		var bookmark : Null<BookmarkDisplay> = null;
		var levelDisplays : StringMap<Fast> = new StringMap(); // FIXME ? try to avoid parsing at runtime
		var xBase : Float = 0;
		var yBase : Float = 0;
		var xOffset : Float = 0;
		var yOffset : Float = 0;


		var nXml : Xml;
		
		if (xml.nodeType != Xml.Document) {

            nXml = Xml.createDocument();
	        nXml.addChild(xml);
        
        } else {

            nXml = xml;
        }

		kd = XmlToKpDisplay.parse(nXml);

		var f : Fast = new Fast(nXml);

		if (f == null) {

			f = new Fast(xml.firstElement());
		}
	    if (f.hasNode.Bookmark) {

			bookmark = new BookmarkDisplay(f.node.Bookmark); // FIXME
	    }

	    // note: all this below was in init()
		orientation = f.att.orientation;

		var regEx = ~/h[0-9]+|hr|item/i;

		for (child in f.elements) {

			if (regEx.match(child.name)) {

				levelDisplays.set(child.name, child);
			}
		}

		// FIXME super.createDisplay();

		if (f.has.xBase) {

			xBase = Std.parseFloat(f.att.xBase);
		}
		if (f.has.yBase) {

			yBase = Std.parseFloat(f.att.yBase);
		}

		// FIXME var menuXml = GameManager.instance.game.menu;

		xOffset += xBase;
		yOffset += yBase;

		// FIXME Localiser.instance.layoutPath = LayoutManager.instance.interfaceLocale;

		// FIXME addChild(layers.get("ui").view);
/* FIXME
		for (elem in menuXml.firstElement().elements()) {

			createMenuLevel(elem);
		}

		if (bookmark != null) {

			bookmark.updatePosition(currentPartButton.x, currentPartButton.y);
			addChild(bookmark);
		}
*/
		return new MenuDisplay(kd, orientation, bookmark, levelDisplays, xBase, yBase, xOffset, yOffset);
	}
/*
	static public function parseModel(xml : Xml) : Menu {

	}
/*
}