package grar.parser.component;

import grar.view.component.Widget;
import grar.view.component.Image;
import grar.view.component.TileImage;

import grar.parser.component.XmlToWidget;

import grar.util.ParseUtils;

import haxe.xml.Fast;

using Lambda;

class XmlToImage {

	static public function parseTileImageData( f : Fast, ? layerRef : Null<String>, visible : Bool = true, ? div : Bool = false ) : TileImageData {

		var tid : TileImageData = cast { };

		tid.layerRef = layerRef;
		tid.visible = visible;
		tid.div = div;
		tid.tilesheetName = f.has.spritesheet ? f.att.spritesheet : null;

		tid.id = parseImageData(f);

		return tid;
	}

	static public function parseImageData( f : Fast, ? tilesheetRef : Null<String> ) : ImageData {

		var id : ImageData = cast { };

		id.wd = XmlToWidget.parseWidgetData(f);
		id.tilesheetRef = tilesheetRef;
		id.tilesheet = null;
		id.isBackground = false;
		
		if (f != null) {

			//var f : Fast = new Fast(xml);

			id.src = f.has.src ? f.att.src : null;

			if (f.has.vertices) {

				id.vertices = new List();

				ParseUtils.parseListOfValues(f.att.vertices).iter(function(vertex: String){

						var v = vertex.split(";");

						id.vertices.add({x: Std.parseFloat(v[0]), y: Std.parseFloat(v[1])});
					});

			} else {

				id.vertices = null;
			}

			id.radius = f.has.radius ? ParseUtils.parseListOfFloatValues(f.att.radius) : null;

			id.height = f.has.height ? Std.parseFloat(f.att.height) : null;
			id.width = f.has.width ? Std.parseFloat(f.att.width) : null;

			id.tile = f.has.tile ? f.att.tile : null;

            id.smoothing = f.has.smoothing ? f.att.smoothing == "true" : true;

			if (f.has.mirror) {

				id.mirror = switch (f.att.mirror.toLowerCase()) {

								case "horizontal": 1;

								case "vertical": 2;

								case _ : throw '[KpDisplay] Unsupported mirror $f.att.mirror';
							}
			} else {

				id.mirror = null;
			}

			id.clipOrigin = f.has.clip ? ParseUtils.parseListOfFloatValues(f.att.clip, ";") : null;
		}
		return id;
	}
}