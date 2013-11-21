package com.knowledgeplayers.grar.display.style;

import flash.display.Shape;
import flash.display.BitmapData;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.display.text.UrlField;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.text.TextFieldAutoSize;

class KpTextDownElement {

	public var content (default, default):String;
	public var style (default, default):String;
	public var bullet (default, default):String;
	public var lineHeight (default, default):Float;
	public var numLines (default, default):Int;
	public var lineWidth (default, default):Float;

	private var width:Float;

	public function new()
	{
		// Default value for style
		style = "text";
	}

	public function createSprite(_width:Float, trim: Bool = false):Sprite
	{
		var styleName = style;
		var output = new Sprite();
		width = _width;
		// Image Style
		var regexImg:EReg = ~/!\[(.+)\]\((.+)\)!/;
		if(regexImg.match(content)){
			var img = new Bitmap(AssetsStorage.getBitmapData(regexImg.matched(2)));
			content = regexImg.replace(content, " ");
			if(regexImg.matchedLeft() != "")
				concatObjects(output, createTextField(regexImg.matchedLeft(), styleName));
			concatObjects(output, img);
			if(regexImg.matchedRight() != "")
				concatObjects(output, createTextField(regexImg.matchedRight(), styleName));
		}

		// Link style
		var regexLink:EReg = ~/@\[(.+)\]\((.+)\)@/;
		if(regexLink.match(content)){
			content = regexLink.replace(content, "");
			var url = new UrlField(regexLink.matched(2), regexLink.matched(1));
			if(regexLink.matchedLeft() != "")
				concatObjects(output, createTextField(regexLink.matchedLeft(), styleName));
			concatObjects(output, url);
			if(regexLink.matchedRight() != "")
				concatObjects(output, createTextField(regexLink.matchedRight(), styleName));
		}

		// Add background and sprite to textfield
		var style = StyleParser.getStyle(styleName);
		if(style != null){
			var hasIcon = false;
			if(style.icon != null){
				setIcons(content, styleName, output, trim);
				hasIcon = true;
			}
			if(style.background != null){
				setBackground(styleName, output);
			}
			if(!hasIcon && content != "")
				concatObjects(output, createTextField(content, styleName, trim));
			else if(content == ""){
				var height = StyleParser.getStyle().getSize();
				DisplayUtils.initSprite(output, 1, height, 0, 0.001);
			}
		}

		return output;
	}

	public function toString():String
	{
		return "{Content: " + content + ", Style: " + style + "}";
	}

	// Privates

	private function concatObjects(container:DisplayObjectContainer, objLeft:DisplayObject, ?objRight:DisplayObject):Void
	{
		if(objRight == null && container.numChildren > 0){
			var maxX:Float = 0;
			var maxWidth:Float = 0;
			for(i in 0...container.numChildren){
				if(container.getChildAt(i).x >= maxX){
					maxX = container.getChildAt(i).x;
					maxWidth = container.getChildAt(i).width;
				}
			}
			objLeft.x = maxX + maxWidth;
			container.addChild(objLeft);
		}
		else if(objRight != null){
			container.addChild(objLeft);
			objRight.x += objLeft.width;
			container.addChild(objRight);
		}
		else
			container.addChild(objLeft);
	}

	private function createTextField(content:String, ?styleName:String, trim: Bool = false, iconWidth: Float = 0):Sprite
	{
		var container = new Sprite();
		var tf = new StyledTextField();
		var modificators = new Array<{match:{pos:Int, len:Int}, offset:Int, style:String}>();

		var style:Style = StyleParser.getStyle(styleName);
		tf.style = style;

		styleName = StringTools.replace(styleName, "text", "");
		if(styleName != "")
			styleName += styleName.charAt(styleName.length - 1) == "-" ? "" : "-";

		var regexBold:EReg = ~/\*([^*]+)\*/;
		while(regexBold.match(content)){
			var boldPos:{pos:Int, len:Int};
			boldPos = regexBold.matchedPos();
			content = regexBold.replace(content, regexBold.matched(1));
			modificators.push({match: boldPos, offset: 2, style: styleName + "bold"});
		}

		var regexIta:EReg = ~/_([^_\]\[]+)_/;
		while(regexIta.match(content)){
			var italicPos:{pos:Int, len:Int};
			italicPos = regexIta.matchedPos();
			content = regexIta.replace(content, regexIta.matched(1));
			modificators.push({match: italicPos, offset: 2, style: styleName + "italic"});
		}

		// Custom Style
		var regexStyle:EReg = ~/\[(.+)\](.+)\[\/(.+)\]/;
		while(regexStyle.match(content)){
			var customPos:{pos:Int, len:Int};
			customPos = regexStyle.matchedPos();
			content = regexStyle.replace(content, regexStyle.matched(2));
			var offset = ((regexStyle.matched(1).length + 2) * 2) + 1;
			modificators.push({match: customPos, offset: offset, style: regexStyle.matched(1)});
		}

		modificators.sort(function(x, y):Int
		{
			if(x.match.pos > y.match.pos)
				return 1;
			else
				return -1;
		});

		if(style.exists("case")){
			if(style.getCase().toLowerCase() == "upper")
				tf.text = content.toUpperCase();
			else if(style.getCase().toLowerCase() == "lower")
				tf.text = content.toLowerCase();
			else if(style.getCase().toLowerCase() == "title")
				tf.text = content.substr(0,1).toUpperCase() + content.substr(1).toLowerCase();
			else
				tf.text = content;
		}
		else
			tf.text = content;

		if(!trim)
			tf.width = width;
		else
			tf.width += (iconWidth + 5);
		tf.wordWrap = true;
		#if flash
            tf.autoSize = style.getAlignment();
        #else
		tf.autoSize = switch(style.getAlignment().toLowerCase()){
			case "left": TextFieldAutoSize.LEFT;
			case "center": TextFieldAutoSize.CENTER;
			case "right": TextFieldAutoSize.RIGHT;
			default: throw "[KpTextDownElement] Unsupported alignement "+style.getAlignment()+".";
		}
		#end
		tf.height += style.getPadding()[2];

		container.addChild(tf);

		var offset:Int = 0;
		for(mod in modificators){
			var position = mod.match.pos - offset;
			offset += mod.offset;
			var style: Style = StyleParser.getStyle(mod.style);
			tf.setPartialStyle(style, position, position + mod.match.len - mod.offset);
		}
		// TODO merge highlight and ruled
		if(style.exists("highlight")){
			var currentY = 0.0;
			for(i in 0...tf.numLines){
				var textField = new StyledTextField(tf.style);
				textField.text = tf.getLineText(i);
				setHighlight(style.get("highlight"), container, Math.max(textField.textWidth, textField.width), Math.max(textField.textHeight, textField.height), 0, currentY);
				currentY += textField.textHeight;
			}
		}
		if(style.exists("ruled")){
			var currentY = 0.0;
			for(i in 0...tf.numLines){
				var textField = new StyledTextField(tf.style);
				textField.text = tf.getLineText(i);
				if(i == 0)
					currentY += textField.textHeight/2;
				var rulingLine = style.get("ruled").split(" "); // 0 is thickness in px, 1 is color/bmp
				if(rulingLine.length == 1)
					rulingLine.push("0"); // Default color
				setHighlight(rulingLine[1], container, Math.max(textField.textWidth, textField.width), Std.parseFloat(rulingLine[0]), 0, currentY, false);
				currentY += textField.textHeight;
			}
		}

		lineHeight = tf.textHeight / tf.numLines;
		numLines = tf.numLines;
		lineWidth = tf.textWidth;
		return container;
	}

	private function setHighlight(highlight:String, item: Sprite, width: Float, height: Float, x: Float = 0, y: Float = 0, withMargins: Bool = true):Void
	{
		if(highlight != null){
			if(Std.parseInt(highlight) != null){
				var highlightColor = ParseUtils.parseColor(highlight);
				if(withMargins)
				// 5px bottom margin for p/q and so on and 5px top margin for accented characters
					DisplayUtils.initSprite(item, width, (height+5), highlightColor.color, highlightColor.alpha, x, (y-5));
				else{
					var line = DisplayUtils.initSprite(width, height, highlightColor.color, highlightColor.alpha, x, y);
					item.addChild(line);
				}
			}
			else{
				var bmp: BitmapData = null;
				if(highlight.indexOf(".") < 0){
					bmp = DisplayUtils.getBitmapDataFromLayer(UiFactory.tilesheet, highlight);
				}
				else if(AssetsStorage.hasAsset(highlight)){
					bmp = AssetsStorage.getBitmapData(highlight);
				}
				if(bmp != null){
					var bitmap = new Bitmap(bmp);
					bitmap.width = width;
					bitmap.height = height;
					bitmap.x = x;
					bitmap.y = y;

					item.addChild(bitmap);
				}
			}

		}
	}

	private function setIcons(content:String, styleName:String, output:Sprite, trim: Bool = false):Void
	{
		var style = StyleParser.getStyle(styleName);
		var bmp = new Bitmap(style.icon);
		if(style.iconResize)
			bmp.width = bmp.height = 10;
		var tf: StyledTextField = cast(createTextField(content, styleName, trim, (bmp.width+style.iconMargin[1]+style.iconMargin[3])).getChildAt(0), StyledTextField);
		switch(style.iconPosition) {
			case "before": concatObjects(output, bmp, tf);
				tf.x += style.iconMargin[1];
			case "after": concatObjects(output, tf, bmp);
				bmp.x = tf.x + tf.textWidth;
				bmp.x += style.iconMargin[3];
			case "both": concatObjects(output, bmp, tf);
				var bmpBis = new Bitmap(style.icon);
				if(style.iconResize)
					bmpBis.width = bmpBis.height = 10;
				concatObjects(output, bmpBis);
			default: throw "[KpTextDownElement] Position '"+style.iconPosition+"' is not handled";
		}

		bmp.y = StyleParser.getStyle().getSize() / 2 - bmp.height / 2;
		bmp.y += style.iconMargin[0];
		var bottomMargin = DisplayUtils.initSprite(new Sprite(), 1, style.iconMargin[2], 0.001);
		bottomMargin.y = output.height;
		output.addChild(bottomMargin);
	}

	private function setBackground(styleName:String, output:Sprite):Void
	{
		var style = StyleParser.getStyle(styleName);
		#if !html
		if(style.background.opaqueBackground != null){
			if(bullet != null){
				var bullet = new StyledTextField(StyleParser.getStyle("text"));
				bullet.text = this.bullet;
				bullet.background = true;
				bullet.backgroundColor = style.background.opaqueBackground;
				output.addChild(bullet);
			}
			else{
				output.graphics.beginFill(style.background.opaqueBackground);
				output.graphics.drawRect(0, 0, output.width, output.height);
			}
		}
		else{
		#end
			if(bullet != null){
				var bullet = new StyledTextField(StyleParser.getStyle("text"));
				bullet.text = this.bullet;
				style.background.width = bullet.width;
				style.background.height = bullet.height;
				output.addChild(style.background);
				output.addChild(bullet);
			}
			else{
				style.background.width = output.width;
				style.background.height = output.height;
			}
		#if !html } #end

	}
}
