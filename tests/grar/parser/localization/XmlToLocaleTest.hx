package grar.parser.localization;

import utest.Assert;
import haxe.Resource;
class XmlToLocaleTest{

	private var xmlLocale:Xml;

	public function new(){

	}

	public function setup():Void
	{
		xmlLocale = Xml.parse(Resource.getString('goodXmlLocale'));
	}

	public function testXmlLocale():Void
	{
		var localeData = XmlToLocale.parseData('fr', xmlLocale);
		Assert.equals("fr", localeData.name);
		Assert.equals("QUITTER", localeData.getItem("txt_exit_button"));
		Assert.equals("RETOUR", localeData.getItem("txt_back"));
		Assert.equals("En cours", localeData.getItem("inProgress"));
		Assert.equals("MENU", localeData.getItem("title_menu"));
	}
}