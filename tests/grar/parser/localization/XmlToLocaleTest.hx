package grar.parser.localization;

import utest.Assert;
import haxe.Resource;
class XmlToLocaleTest{

	public function new(){

	}

	public function testXmlLocale():Void
	{
		var xmlLocale = Xml.parse(Resource.getString('goodXmlLocale'));
		var localeData = XmlToLocale.parseData('fr', xmlLocale);
		Assert.equals("fr", localeData.name);
		Assert.equals("QUITTER", localeData.getItem("txt_exit_button"));
		Assert.equals("RETOUR", localeData.getItem("txt_back"));
		Assert.equals("En cours", localeData.getItem("inProgress"));
		Assert.equals("MENU", localeData.getItem("title_menu"));
	}

	public function testExcelLocale():Void
	{
		var excelLocale = Xml.parse(Resource.getString('goodExcelLocale'));
		var localeData = XmlToLocale.parseData('fr', excelLocale);
		Assert.equals("fr", localeData.name);
		Assert.equals("Conclusion", localeData.getItem("conclusion"));
		Assert.equals("Merci", localeData.getItem("thanks"));
		Assert.equals("Titre de l episode", localeData.getItem("episode_title"));
	}
}