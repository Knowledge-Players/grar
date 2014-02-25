package grar.view;

import grar.view.Display;
import grar.view.component.Image;
import grar.view.component.TileImage;
import grar.view.component.CharacterDisplay;
import grar.view.component.container.WidgetContainer;
import grar.view.component.container.VideoPlayer;

import haxe.ds.StringMap;

enum ElementData {

	TextGroup(d : StringMap<{ obj : ElementData, z : Int }>);
	Image(i : ImageData);
	TileImage(ti : TileImageData);
	Character(c : CharacterData);
	DefaultButton(d : WidgetContainerData);
	ScrollPanel(d : WidgetContainerData);
	VideoPlayer(d : WidgetContainerData);
	SoundPlayer(d : WidgetContainerData);
	ScrollBar(d : { width : Float, bgColor : Null<String>, cursorColor : Null<String>, bgTile : Null<String>, tile : String, tilesheet : Null<String>, cursor9Grid : Array<Float>, bg9Grid : Null<Array<Float>> });
	SimpleContainer(d : WidgetContainerData);
	ChronoCircle(d : WidgetContainerData);
	Template(d : { data : ElementData, validation : Null<String> });

	// PartDisplay only
	InventoryDisplay(d : WidgetContainerData);
	IntroScreen(d : WidgetContainerData);

	// Zone only
	Menu(d : DisplayData);
	ProgressBar(d : WidgetContainerData);
	DropdownMenu(d : WidgetContainerData);

	// Strip only
	BoxDisplay(d : WidgetContainerData);

	// VideoPlayer only
	VideoBackground(d:VideoBackgroundData);
	VideoProgressBar(d:ProgressBarData);
	VideoSlider(d:SliderData);
}