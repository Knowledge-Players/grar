package grar.parser.layout;

import grar.view.layout.Layout;
import grar.view.KpDisplay;
import grar.view.layout.Zone;

import grar.parser.XmlToKpDisplay;

import haxe.ds.StringMap;

import haxe.xml.Fast;

class XmlToLayouts {

	static public function parse(xml : Xml) : StringMap<Layout> {

		var f : Fast = new Fast(xml).node.Layouts;

		var l : StringMap<Layout> = new StringMap();

		if (f.has.text) {

			var interfaceLocale : String = f.att.text;
			// FIXME Localiser.instance.layoutPath = interfaceLocale;
		}
		for (lay in f.elements) {

			var layout : Layout = parseLayout(lay);

			l.set(layout.name, layout);
		}

		return l;
	}

	static function parseLayout(f : Fast) : Layout {

		var content : Zone;
		var name : String;

		content = parseZone(f); // FIXME new Zone(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		// FIXME content.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
		//content.init(_fast);
		name = f.att.layoutName;

		return new Layout(zones, content, name);
	}

	static function parseZone(f : Fast) : Zone {

		var kd : KpDisplayData = XmlToKpDisplay.parse(f.x);

		var bgColor : Null<Int> = f.has.bgColor ? Std.parseInt(f.att.bgColor) : null;


	//public function init(_zone : Fast) : Void {
		
// TODO all below and more (see overrides in Zone :S)
		if (f.has.ref) {

			layers.set("ui", new TileLayer(UiFactory.tilesheet));

			ref = f.att.ref;
			dispatchEvent(new LayoutEvent(LayoutEvent.NEW_ZONE, ref, this));
			addChild(layers.get("ui").view);
			for(element in f.elements){
				createElement(element);
			}

			//layer.render();

		}
		else if(f.has.rows){
			var heights = initSize(f.att.rows, zoneHeight);
			var yOffset:Float = 0;
			var i = 0;
			for(row in f.nodes.Row){
				var zone = new Zone(zoneWidth, heights[i]);
				zone.x = 0;
				zone.y = yOffset;
				zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
				zone.init(row);
				yOffset += zone.zoneHeight;
				addChild(zone);
				i++;
			}
		}
		else if(f.has.columns){
			var widths = initSize(f.att.columns, zoneWidth);
			var xOffset:Float = 0;
			var j = 0;
			for(column in f.nodes.Column){
				var zone = new Zone(widths[j], zoneHeight);
				zone.x = xOffset;
				zone.y = 0;
				zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
				zone.init(column);
				xOffset += zone.zoneWidth;
				addChild(zone);
				j++;
			}
		}
		else{
			trace("[Zone] This zone is empty. Are you sure your XML is correct ?");
		}

		// Listeners on menu state
		if(buttonGroups.exists(groupMenu)){
		    MenuDisplay.instance.addEventListener(PartEvent.ENTER_PART, enterMenu);
		}
		if(buttonGroups.exists(groupNotebook)){
			NotebookDisplay.instance.addEventListener(PartEvent.EXIT_PART, exitNotebook);
			NotebookDisplay.instance.addEventListener(PartEvent.ENTER_PART, enterNotebook);
		}
	//}

	//private function createProgressBar(element:Fast):ProgressBar
	//{
		var progress = new ProgressBar(element);
		addChild(progress);

		return progress;
	//}


		return new Zone(kd, );
	}
}