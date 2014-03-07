package grar.view.component.container;

import aze.display.TilesheetEx;

import grar.view.component.container.WidgetContainer;

import grar.view.style.KpTextDownElement;
import grar.view.style.Style;

import grar.parser.style.KpTextDownParser;

import grar.util.DisplayUtils;

import com.knowledgeplayers.utils.assets.AssetsStorage;

import flash.display.BitmapData;
import flash.display.Sprite;

import haxe.ds.StringMap;

/**
 * ScrollPanel to manage text overflow, with auto scrollbar
 */
class ScrollPanel extends WidgetContainer {

//  public function new(?xml: Fast, ?width:Float, ?height:Float, ?_styleSheet:String) {
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : TilesheetEx, 
							transitions : StringMap<TransitionTemplate>, ? spd : Null<WidgetContainerData>) {

		if (spd == null) {

			super(callbacks, applicationTilesheet, transitions);

		} else {

			super(callbacks, applicationTilesheet, transitions, spd);

			switch(spd.type) {

				case ScrollPanel(ss, s, c, t):

					this.styleSheetRef = ss;
					this.style = s;
//if (ref == "titreintro") trace("styleSheetRef= "+styleSheetRef+"    style= "+style);
					if (c != null) {

						setContent(onLocalizedContentRequest(c));
					}
					trim = t;

				default: // nothing
			}
		}
	}

	/**
    * Style sheet used for this panel
    **/
	public var styleSheetRef (default, default) : Null<String> = null;

	/**
	* Used to force a style on this scrollpanel
	**/
	public var style (default, default) : String;

	/**
	* If true, resize the panel to the text width
	**/
	public var trim (default, default) : Bool;

	private var styleSheet : grar.view.style.StyleSheet;


	///
	// API
	//

	/**
     * Set the text to the panel
     * @param	content : Text to set
     * @return the text
     */

	public function setContent(contentString:String):Void
	{
		clear();

		styleSheet = onStylesheetRequest(styleSheetRef); // could be passed at new()

//if (ref == "titreintro") trace("got stylesheet with id "+styleSheetRef+" => "+styleSheet);
		var offSetY : Float = 0;
		var isFirst : Bool = true;

		var maskLine = new Sprite();

		var text = new Sprite();
		var minPaddingLeft = Math.POSITIVE_INFINITY;

		for (element in KpTextDownParser.parse(contentString)) {

			element.tilesheet = tilesheet;

			if (style != null) {

				element.style = style;
			}
			element.styleSheet = styleSheet;
//trace("styleSheet = "+styleSheet);
			var st : Style = styleSheet.getStyle(element.style);
//if (ref == "titreintro") trace("element with contentString = "+contentString+"   element.style= "+element.style+"   styleSheet= "+styleSheet+"    style= "+st);
			if (st == null) {

				throw "[ScrollPanel] There is no style \"" + element.style + "\" in style sheet \"" + styleSheet.name + "\".";
			}
			var padding = st.getPadding();
			var iconOffset : Float = 0;
			
			if (st.icon != null) {

				iconOffset += st.icon.width;
			}
			if (st.iconMargin != null) {

				iconOffset += st.iconMargin[1] + st.iconMargin[3];
			}
			var item = element.createSprite(maskWidth - padding[1] - padding[3] - iconOffset, trim);
//if (ref == "titreintro") trace("created text sprite with w: "+item.width+", h: "+item.height);
			if (isFirst) {

				offSetY += padding[0];
				isFirst = false;
			}
			item.x = padding[3];

			if (padding[3] < minPaddingLeft) {

				minPaddingLeft = padding[3];
			}
			item.y = offSetY;
			offSetY += item.height + st.getLeading()[1];
			
			if (scrollable) {
//if (ref == "titreintro") trace("scrollable");
				for (i in 0...element.numLines) {

					var m = new Sprite();
					m.y = item.y + (i * element.lineHeight);
					m.x = item.x;
                    // 2px margin
					DisplayUtils.initSprite(m, element.lineWidth + 2, element.lineHeight + 2);
					maskLine.addChild(m);
				}
			}
			text.addChild(item);
		}
//if (ref == "titreintro") trace("alpha is "+contentAlpha);
		content.alpha = contentAlpha;
		content.addChild(text);
		
		if (!scrollable) {
//if (ref == "titreintro") trace("not scrollable, mask w: "+text.width+", h: "+maskHeight);
			DisplayUtils.initSprite(maskLine, text.width, maskHeight, 0, 1, minPaddingLeft);
		}
		//content.addChild(maskLine);
		//text.mask = maskLine;
		addChild(content);
		displayContent(trim);
	}
}