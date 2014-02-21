package grar.view.component.container;

import grar.view.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.style.KpTextDownElement;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.Style;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.utils.assets.AssetsStorage;

import flash.display.BitmapData;
import flash.display.Sprite;

/**
 * ScrollPanel to manage text overflow, with auto scrollbar
 */
class ScrollPanel extends WidgetContainer {

// FIXME public function new(?xml: Fast, ?width:Float, ?height:Float, ?_styleSheet:String) {
	public function new(spd : WidgetContainerData) {

		super(spd);

		// ??? if (xml != null) {
		switch(spd.type) {

			case ScrollPanel(ss, s, c, t):

				this.styleSheet = ss;
				this.style = s;
				
				if (c != null) {

					setContent(Localiser.instance.getItemContent(c));
				}
				trim = t;

			default: // nothing
		}

		// ??? }
		// FIXME if (_styleSheet != null) {

		// FIXME 	styleSheet = _styleSheet;
		// FIXME }
	}

	/**
    * Style sheet used for this panel
    **/
	public var styleSheet (default, default):String;

	/**
	* Used to force a style on this scrollpanel
	**/
	public var style (default, default):String;

	/**
	* If true, resize the panel to the text width
	**/
	public var trim (default, default):Bool;

	/**
     * Set the text to the panel
     * @param	content : Text to set
     * @return the text
     */

	public function setContent(contentString:String):Void
	{
		clear();
		var previousStyleSheet = null;
		if(styleSheet != null){
			previousStyleSheet = StyleParser.currentStyleSheet;
			StyleParser.currentStyleSheet = styleSheet;
		}

		var offSetY:Float = 0;
		var isFirst:Bool = true;

		var maskLine = new Sprite();

		var text = new Sprite();
		var minPaddingLeft = Math.POSITIVE_INFINITY;
		for(element in KpTextDownParser.parse(contentString)){
			if(style != null)
				element.style = style;
			var style:Style = StyleParser.getStyle(element.style);
			if(style == null)
				throw "[ScrollPanel] There is no style \"" + element.style + "\" in style sheet \"" + StyleParser.currentStyleSheet + "\".";
			var padding = style.getPadding();
			var iconOffset:Float = 0;
			if(style.icon != null)
				iconOffset += style.icon.width;
			if(style.iconMargin != null)
				iconOffset += style.iconMargin[1] + style.iconMargin[3];
			var item = element.createSprite(maskWidth - padding[1] - padding[3] - iconOffset, trim);

			if(isFirst){
				offSetY += padding[0];
				isFirst = false;
			}
			item.x = padding[3];
			if(padding[3] < minPaddingLeft)
				minPaddingLeft = padding[3];
			item.y = offSetY;
			offSetY += item.height + style.getLeading()[1];
			if(scrollable){
				for(i in 0...element.numLines){
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
		content.alpha = contentAlpha;
		content.addChild(text);
		if(!scrollable)
			DisplayUtils.initSprite(maskLine, text.width, maskHeight, 0, 1, minPaddingLeft);
		content.addChild(maskLine);
		text.mask = maskLine;
		addChild(content);
		displayContent(trim);

		if(previousStyleSheet != null)
			StyleParser.currentStyleSheet = previousStyleSheet;

	}
}