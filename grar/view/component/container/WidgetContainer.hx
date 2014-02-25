package grar.view.component.container;

import aze.display.TileSprite;
import aze.display.TileLayer;
import aze.display.TilesheetEx;

import com.knowledgeplayers.utils.assets.AssetsStorage;

import grar.view.ElementData;
import grar.view.Display;
import grar.view.Color;
import grar.view.guide.Guide;
import grar.view.contextual.InventoryDisplay.Template;
import grar.view.element.ChronoCircle;
import grar.view.component.Widget;
import grar.view.component.Image;
import grar.view.component.TileImage;
import grar.view.component.ScaleBitmap;
import grar.view.component.container.VideoPlayer;

// FIXME import com.knowledgeplayers.grar.event.ButtonActionEvent; // FIXME

// FIXME import com.knowledgeplayers.grar.factory.UiFactory; // FIXME

import grar.util.ParseUtils;
import grar.util.DisplayUtils;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.display.Sprite;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

typedef BackgroundData = {

	var background : Null<String>;
	var color : Null<Array<String>>;
	var arrowX : Float;
	var arrowY : Float;
	var radius : Null<Array<Float>>;
	var line : Float;
	var colorLine : Int;
	var bubbleWidth : Int;
	var bubbleHeight : Int;
	var shadow : Float;
	var gap : Float;
	var bubbleX : Float;
	var bubbleY : Float;
	var resize : Bool;
}
/*
enum ElementData {

	Image(d:ImageData);
	TileImage(d:TileImageData);
	DefaultButton(d:WidgetContainerData);
	ScrollPanel(d:WidgetContainerData);
	ChronoCircle(d:WidgetContainerData);
	SimpleContainer(d:WidgetContainerData);

	// VideoPlayer only
	VideoBackground(d:VideoBackgroundData);
	VideoProgressBar(d:ProgressBarData);
	VideoSlider(d:SliderData);
}
*/
enum WidgetContainerType {

	WidgetContainer; // TODO remove ?
	SimpleContainer(? mask : Null<String>);
	BoxDisplay;
	DefaultButton(? defaultState : String, ? isToggleEnabled : Bool, ? action : Null<String>, ? group : Null<String>, ? enabled : Bool);
	DropdownMenu(? color : Color);
	ScrollPanel(? styleSheet : Null<String>, ? style : Null<String>, ? content : Null<String>, ? trim : Bool);
	SimpleBubble;
	SoundPlayer;
	ChronoCircle(? colorCircle : Null<Color>, ? minRadius : Null<Int>, ? maxRadius : Null<Int>, ? colorBackground : Null<Color>, ? centerCircle : Null<Color>);
	VideoPlayer(? controlsHidden : Bool, ? autoFullscreen : Null<Bool>);
	ProgressBar(? iconScale : Float, ? progressColor : Int, ? icon : String);
	InventoryDisplay(? guide : GuideData, ? fullscreen : WidgetContainerData, ? displayTemplates : StringMap<Template>);
	BookmarkDisplay(? animation : Null<String>, ? xOffset : Float, ? yOffset : Float);
	IntroScreen(? duration : Int);
	AnimationDisplay;
	TokenNotification(? duration : Int);
}

typedef WidgetContainerData = {

	var wd : WidgetData;
	var type : WidgetContainerType;
	var spritesheetRef : Null<String>; 
	@:optional var tilesheet : Null<TilesheetEx>; // set in a second step (instanciation)
	var contentAlpha : Float;
	var scrollBarName : String;
	var contentTransition : String;
	var scrollable : Bool;
	var grid9 : { g0 : Float, g1 : Float, g2 : Float, g3 : Float };
	var maskWidth : Null<Float>;
	var maskHeight : Null<Float>;
	var background : BackgroundData;
	var displays : StringMap<ElementData>;
	var transitionIn : Null<String>;
}

/**
 * Base for widget that can contain other widget
 **/
class WidgetContainer extends Widget {

	//private function new( ? xml : Fast, ? tilesheet : TilesheetEx ) {
	private function new( ? wcd : Null<WidgetContainerData> ) {

		if (wcd == null) {

			super();

		} else  {

			super(wcd.wd);
		}

		this.content = new Sprite();
		this.displays = new StringMap();
		this.buttonGroups = new StringMap();
		this.children = new Array();

		addChild(content);

		if (wcd != null) {

			// Default tilesheet
			if (wcd.tilesheet != null) {

			 	this.tilesheet = wcd.tilesheet;
			
			} else {
				
//FIXME 	this.tilesheet = UiFactory.tilesheet;
			}

			this.contentAlpha = wcd.contentAlpha;
			this.scrollBarName = wcd.scrollBarName;
			this.contentTransition = wcd.contentTransition;
			this.scrollable =  wcd.scrollable;

			if (wcd.grid9 != null) {

				this.grid9 = new Rectangle(wcd.grid9.g0, wcd.grid9.g1, wcd.grid9.g2, wcd.grid9.g3);
			}
			for (de in wcd.displays) {

				createElement(de);
			}
			this.maskWidth = wcd.maskWidth != null ? wcd.maskWidth : width;
			this.maskHeight = wcd.maskHeight != null ? wcd.maskHeight : height;

			content.addChildAt(layer.view, 0);

			setBackground(wcd.background);
		}

		addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		addEventListener(Event.ENTER_FRAME, checkRender);
	}

	/**
	* Background for the container. Could be an int or a src
	**/
	public var background (default, null):String;

	/**
	* Scale9Grid for the background
	**/
	public var grid9 (default, default):Rectangle;

	/**
	* Mask width
	**/
	public var maskWidth:Float;

	/**
	* Mask height
	**/
	public var maskHeight:Float;

	/**
	* Tilesheet for the container
	**/
	public var tilesheet (default, set):TilesheetEx;

	/**
	* Enable the scroll. True by default
	**/
	public var scrollable (default, default):Bool = true;

	/**
	* Content alpha
	**/
	public var contentAlpha (default, set):Float;

	/**
	* Content transition
	**/
	public var contentTransition (default, default):String;

	/**
     * Content root
     */
	public var content (default, default):Sprite;

	/**
	* Children of this container
	**/
	public var children (default, default):Array<Widget>;

	public var zIndex : Int = 0;
	public var renderNeeded : Bool = false;

	private var scrollBarName : String;
	private var scrollBar : ScrollBar;
	private var scrollNeeded : Bool;
	private var layer : TileLayer;
	private var displays : StringMap<Widget>;
	private var buttonGroups : StringMap<GenericStack<DefaultButton>>;

	public function set_contentAlpha(alpha : Float) : Float
	{
		return content.alpha = contentAlpha = alpha;
	}

	public function setBackground(b : BackgroundData) : String  {

		if (b.background != null) {

			if (Std.parseInt(b.background) != null) {

				var bkgColor = ParseUtils.parseColor(b.background);
				DisplayUtils.initSprite(this, maskWidth, maskHeight, bkgColor.color, bkgColor.alpha);
			
			} else if(b.background == "bubble") {

				var colors = new Array<Int>();
				var alphas = new Array<Float>();
				
				for (i in 0...b.color.length) {

					var c = ParseUtils.parseColor(b.color[i]);
					colors.push(c.color);
					alphas.push(c.alpha);
				}
				if (b.radius == null) {

					b.radius = [0.0, 0.0, 0.0, 0.0];
				}
				ParseUtils.formatToFour(b.radius);
                var bubble:SimpleBubble = new SimpleBubble(b.bubbleWidth!=0 ? b.bubbleWidth:maskWidth,b.bubbleHeight!=0 ? b.bubbleHeight:maskHeight,colors,b.arrowX,b.arrowY,b.radius,b.line,b.colorLine,b.shadow,b.gap,alphas,b.bubbleX,b.bubbleY);
                addChildAt(bubble,0);
            
            } else {

				if (grid9 != null) {

					var bmpData: BitmapData;
					
					if (AssetsStorage.hasAsset(b.background)) {

						bmpData = AssetsStorage.getBitmapData(b.background);
					
					} else {

						bmpData = DisplayUtils.getBitmapDataFromLayer(layer.tilesheet, b.background);
					}
					var background = new ScaleBitmap(bmpData);
					background.bitmapScale9Grid = grid9;
					background.setSize(maskWidth, maskHeight);
					background.alpha = alpha;
					addChildAt(background, 0);
				
				} else if(b.background.indexOf(".") < 0) {

					var tile = new TileSprite(layer, b.background);
					tile.alpha = alpha;
					layer.addChild(tile);
					if(b.resize){
						tile.scaleX = maskWidth / tile.width;
						tile.scaleY = maskHeight / tile.height;
					}
					tile.x = tile.width / 2;
					tile.y = tile.height / 2;
					layer.render();
				
				} else if(AssetsStorage.hasAsset(b.background)) {

					var bkg = new Bitmap(AssetsStorage.getBitmapData(b.background));
					bkg.alpha = alpha;
					addChildAt(bkg, 0);
				}
			}
		}
		return background = b.background;
	}

	public function set_tilesheet(tilesheet:TilesheetEx):TilesheetEx
	{
		if(layer == null)
			layer = new TileLayer(tilesheet);
		else
			layer.tilesheet = tilesheet;
		layer.render();
		return this.tilesheet = tilesheet;
	}

	/**
	* Empty the container
	**/
	public function clear()
	{
		removeChild(content);
		content = new Sprite();
		content.addChild(layer.view);
		content.mask = null;

		var max = (background != null && background != "") ? 1 : 0;
		while(numChildren > max)
			removeChildAt(numChildren - 1);
	}

	public function maskSprite(sprite: Sprite, maskWidth: Float = 1, maskHeight: Float = 1, maskX: Float = 0, maskY: Float = 0):Void
	{
		DisplayUtils.maskSprite(sprite, maskWidth, maskHeight, maskX, maskY);
	}

	override public function toString():String
	{
		return super.toString()+' $maskWidth x $maskHeight $background';
	}

	// Privates

	private inline function scrollToRatio(position:Float)
	{
		content.y = -position * content.height;
	}

	private inline function moveCursor(delta:Float)
	{
		scrollBar.moveCursor(delta);
	}

	private function displayContent(trim: Bool = false):Void
	{
		maskSprite(content, (trim ? content.width:maskWidth), maskHeight);


		if(maskHeight < content.height && scrollable){
			if(parent != null)
				setScrollBar();
			else
				addEventListener(Event.ADDED_TO_STAGE, setScrollBar, 10);
		}
		else{
			scrollNeeded = false;
		}

// FIXME        TweenManager.applyTransition(content, contentTransition);

		for(child in children){
            if(child.transformation != null){
// FIXME                TweenManager.applyTransition(child, child.transformation);
            }
        }
	}

	private inline function setScrollBar(?e: Event):Void
	{
		var partDisplay = parent;

		while(!Std.is(partDisplay, Display)){
			partDisplay = partDisplay.parent;
		}
		if(scrollBarName == null){
			var keyArray = [];
			for (key in cast(partDisplay, Display).scrollBars.keys()) keyArray.push(key);
			scrollBarName = keyArray[0];
		}
		scrollBar = cast(partDisplay, Display).scrollBars.get(scrollBarName);


		scrollBar.setHeight(maskHeight);
		scrollBar.set_ratio(maskHeight / content.height);
		scrollBar.x = content.x + maskWidth;
		scrollBar.y = content.y;
		scrollBar.scrolled = scrollToRatio;
		scrollNeeded = true;

		addChild(scrollBar);
	}


	private inline function render():Void
	{
		layer.render();
	}

//	public function createElement(elemNode:Fast):Widget
	public function createElement(de : ElementData) : Widget {

		switch(de) {

			case Image(d):

				var img : Image = new Image(d);
	            addElement(img);
				return img;

			case TileImage(d):

				d.layer = layer;
				d.visible = d.div = true;

	            var tileImg : TileImage = new TileImage(d);
	            addElement(tileImg);
		        return tileImg;

			case DefaultButton(d):

				return createButton(d);

			case ScrollPanel(d):

				return createText(d);

			case ChronoCircle(d):

				return createTimer(d);

			case SimpleContainer(d):

				return createSimpleContainer(d);
/* FIXME
		case "include" :
			var tmpXml = Xml.parse(DisplayUtils.templates.get(elemNode.att.ref).toString()).firstElement();
			for(att in elemNode.x.attributes()){
				if(att != "ref")
					tmpXml.set(att, elemNode.x.get(att));
			}
			createElement(new Fast(tmpXml));
*/
			default:

				return null;
		}
	}


	///
	// INTERNALS
	//

	private function createTimer(d : WidgetContainerData) : ChronoCircle {

		var timer = new ChronoCircle(d);
		addElement(timer);
        return timer;
	}

	private function createSimpleContainer(d : WidgetContainerData) : Widget {

		var div = new SimpleContainer(d);
		addElement(div);
		return div;
	}

	private function createButton(d : WidgetContainerData) : Widget {

		var button : DefaultButton = new DefaultButton(d);

		switch(d.type) {

			case DefaultButton(_, _, a, g, _):

				if (a != null) {

					setButtonAction(button, a);
				}
				if (g != null) {

					if (buttonGroups.exists(g)) {

						buttonGroups.get(g).add(button);
					
					} else {

						var stack = new GenericStack<DefaultButton>();
						stack.add(button);
						buttonGroups.set(g, stack);
					}
				}
			default: // nothing
		}
// FIXME		button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
		addElement(button);
		return button;
	}

	//private function createText(textNode : Fast) : Widget {
	private function createText(d : WidgetContainerData) : ScrollPanel {

		var text = new ScrollPanel(d);
		addElement(text);
        return text;
	}

	private function addElement(elem:Widget):Void
	{
		elem.zz = zIndex;
        displays.set(elem.ref,elem);

		content.addChild(elem);
		children.push(elem);
        zIndex++;
		dispatchEvent(new Event(Event.CHANGE));
	}

	private function setButtonAction(button : DefaultButton, action : String) : Void { }


	// Handlers

	private function onWheel(e:MouseEvent):Void
	{
		if(scrollable){
			if(e.delta > 0 && content.y + e.delta > 0){
				content.y = 0;
			}
			else if(e.delta < 0 && content.y + e.delta < -(content.height - maskHeight)){
				content.y = -(content.height - maskHeight);
			}
			else{
				content.y += e.delta;
			}
			if(scrollBar != null)
				moveCursor(e.delta);
		}
	}

	private inline function checkRender(e:Event):Void
	{
		if(renderNeeded){
			render();
			renderNeeded = false;
		}
	}
/* FIXME
	private function onButtonToggle(e:ButtonActionEvent):Void
	{
		var button = cast(e.target, DefaultButton);
		if(button.toggleState == "inactive" && button.group != null){
			for(b in buttonGroups.get(button.group)){
				if(b != button)
					b.toggle(true);
			}
		}
	}
*/
}
