package grar.parser;

import grar.view.KpDisplay;
import grar.view.contextual.menu.MenuDisplay;
import grar.view.contextual.menu.BookmarkDisplay;

import haxe.ds.StringMap;

import haxe.xml.Fast;

typedef MenuData = {

	var kd : KpDisplayData;
	var orientation : String;
	var bookmark : Null<BookmarkDisplay> = null;
	var levelDisplays : StringMap<Fast> = new StringMap();
	var xBase : Float = 0;
	var yBase : Float = 0;
	var xOffset : Float = 0;
	var yOffset : Float = 0;
}

class XmlToMenu {

	static public function parseView(xml : Xml) : MenuData {

		var md : MenuData = { };

		var nXml : Xml;
		
		if (xml.nodeType != Xml.Document) {

            nXml = Xml.createDocument();
	        nXml.addChild(xml);
        
        } else {

            nXml = xml;
        }

		var kd : KpDisplayData = XmlToKpDisplay.parse(nXml);

		var f : Fast = new Fast(nXml);

		if (f == null) {

			f = new Fast(xml.firstElement());
		}
	    if (f.hasNode.Bookmark) {

			md.bookmark = new BookmarkDisplay(f.node.Bookmark); // FIXME
	    }

	    // note: all this below was in init()
		md.orientation = f.att.orientation;

		var regEx = ~/h[0-9]+|hr|item/i;

		for (child in f.elements) {

			if (regEx.match(child.name)) {

				md.levelDisplays.set(child.name, child);
			}
		}

		// FIXME super.createDisplay();

		if (f.has.xBase) {

			md.xBase = Std.parseFloat(f.att.xBase);
		}
		if (f.has.yBase) {

			md.yBase = Std.parseFloat(f.att.yBase);
		}

		md.xOffset += xBase;
		md.yOffset += yBase;

		// FIXME Localiser.instance.layoutPath = LayoutManager.instance.interfaceLocale;

		// FIXME addChild(layers.get("ui").view);
/* FIXME
		if (bookmark != null) {

			bookmark.updatePosition(currentPartButton.x, currentPartButton.y);
			addChild(bookmark);
		}
*/
		return md;
	}

	static public function parseContent(xml : Xml, md : MenuData) : Menu {

		// FIXME var menuXml = GameManager.instance.game.menu;


		for (elem in xml.firstElement().elements()) {

			createMenuLevel(elem);
		}


		//return new MenuDisplay(kd, orientation, bookmark, levelDisplays, xBase, yBase, xOffset, yOffset);
	}


	static function createMenuLevel( level : Xml ) : Void {

		if (!levelDisplays.exists(level.nodeName)) {

			throw "Display not specified for tag " + level.nodeName;
		}
		var fast:Fast = levelDisplays.get(level.nodeName);

		if (level.nodeName == "hr") {

			addSeparator(fast);
		
		} else {

			var partName = GameManager.instance.getItemName(level.get("id"));
			
			if (partName == null) {

				throw "[MenuDisplay] Can't find a name for '"+level.get("id")+"'.";
			}

			var button = addButton(fast.node.Button, partName, level.get("icon"));
			buttons.set(level.get("id"), button);
			setButtonState(button, level);
			buttons.set(level.get("id"), button);

            button.x += xOffset;
            button.y += yOffset;

			if (orientation == "vertical") {

				yOffset += button.height+Std.parseFloat(fast.att.yOffset);
			
			} else if(fast.has.width) {

				xOffset += xOffset+Std.parseFloat(fast.att.width);
			
			} else if(orientation == "horizontal") {

			    xOffset += button.width+Std.parseFloat(fast.att.xOffset);
			}

            addChild(button);

			if (currentPartButton == null) {

				currentPartButton = button;
			}
		}
		for (elem in level.elements()) {

			createMenuLevel(elem);
		}
	}

	private function setButtonState(button:DefaultButton, level: Xml):Void
	{
		for(part in GameManager.instance.game.getAllParts()){
			if(part.name == level.get("id")){
				if(!part.canStart())
					button.toggleState = "lock";
				else
					button.toggle(!part.isDone);
				break;
			}
		}
	}

	private function addSeparator(fast:Fast):Widget
	{
		var hasChildren = fast.elements.hasNext();
		var separator: Widget;
		if(hasChildren)
			separator = new SimpleContainer(fast);
		else{
			separator = new Image();
			if(fast.has.thickness){
				var line = new Shape();
				line.graphics.lineStyle(Std.parseFloat(fast.att.thickness), Std.parseInt(fast.att.color), Std.parseFloat(fast.att.alpha));
				var originCoord:Array<String> = fast.att.origin.split(';');
				var origin = {x: Std.parseFloat(originCoord[0]), y: Std.parseFloat(originCoord[1])};
				line.graphics.moveTo(origin.x, origin.y);
				var destCoord = fast.att.destination.split(";");
				var dest = {x: Std.parseFloat(destCoord[0]), y: Std.parseFloat(destCoord[1])};
				line.graphics.lineTo(dest.x, dest.y);

				line.x = Std.parseFloat(fast.att.x);
				line.y = Std.parseFloat(fast.att.y) + yOffset;
				separator.addChild(line);
			}
		}
		separator.addEventListener(Event.CHANGE, updateDynamicFields);
		return separator;
	}

	private function addButton(fast:Fast, text:String, iconId: String):DefaultButton
	{
		var icons = ParseUtils.selectByAttribute("ref", "icon", fast.x);
		ParseUtils.updateIconsXml(iconId, icons);
		var button:DefaultButton = new DefaultButton(fast);

		button.setText(text, "partName");
		button.buttonAction = onClick;
		button.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		button.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		button.transitionOut = transitionOut;
		button.name = text;
		buttonGroups.get(btnGroupName).add(button);

		return button;
	}

	// TODO overriding KpDisplay parsing !!!
	override private function addElement(elem:Widget, node:Fast):Void
	{
		super.addElement(elem, node);
		addChild(elem);
	}
}