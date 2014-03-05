package grar.parser.localization;

import grar.model.localization.Locale;
import grar.model.localization.LocaleData;

import haxe.ds.StringMap;
import haxe.xml.Fast;

class XmlToLocale {

	///
	// API
	//

	static public function parseLangList(xml : Xml) : StringMap<Locale> {

		var f : Fast = new Fast(xml);

		var l : StringMap<Locale> = new StringMap();

		for (lang in f.node.Langs.nodes.Lang) {

            l.set( lang.att.value, { path: lang.att.folder, pic: lang.att.pic } );
        }
        return l;
	}

	static public function parseData(locale : String, xml : Xml) : LocaleData {

		var tradHash : Map<String, String>;

		if (xml.firstElement().nodeName == "Workbook") {

			tradHash = parseExcelContent(xml);

		} else {

			tradHash = parseXmlContent(xml);
		}

		return new LocaleData(locale, tradHash);
	}


	///
	// INTERNALS
	//

	static private function parseXmlContent(content : Xml) : Map<String, String> {

		var f = new Fast(content).node.Localisation;

		var tradHash : Map<String, String> = new Map();

		for (e in f.nodes.Element) {

			tradHash.set(e.node.key.innerData, e.node.value.innerData);
		}

		return tradHash;
	}

	// Can't use haxe.xml.Fast because Excel XML isn't supported

	static private function parseExcelContent(content : Xml) : Map<String, String> {

		var table : Xml = null;

		var tradHash : StringMap<String> = new StringMap<String>();

		for (element in content.firstElement().elements()) {

			if (element.nodeName == "Worksheet") {

				table = element.firstElement();
			}
		}
		for (row in table.elements()) {

			if (row.nodeName == "Row") {

				var key:String = "";
				var value:String = "";

				for (cell in row.elements()) {

					if (cell.nodeName == "Cell") {

						for (data in cell.elements()) {

							if (data.nodeName == "Data") {

								if (key != "") {

									value = StringTools.htmlUnescape(data.firstChild().toString());

								} else {

									key = data.firstChild().toString();
								}
							}
						}
					}
				}
				if (key != "" && value != "") {

					tradHash.set(key, value);
				}
			}
		}
		return tradHash;
	}
}