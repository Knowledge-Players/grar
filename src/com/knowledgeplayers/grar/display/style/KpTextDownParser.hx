package com.knowledgeplayers.grar.display.style;

import com.knowledgeplayers.grar.util.LoadData;
import nme.text.TextFieldAutoSize;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.display.text.UrlField;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.Lib;

/**
 * Parser for the KP MarkUp language
 */
class KpTextDownParser extends Sprite {
    private static var specialRegEx:EReg = ~/[#*_>.!@+-]+/g;
    private static var widthTF:Float = 0;
    /**
     * Parse the string for MarkUp
     * @param	text : text to parse
     * @return a sprite with well-formed text
     */

    public static function parse(text:String, ?widthText:Float = 0):Sprite
    {

        var sprite = new Sprite();

        if(text != null && text != ""){
            // Standardize line endings
            var lineEnding:EReg = ~/(\r)(\n)?|(&#13;)|(&#10;)|(<br\/>)/g;
            var uniformedText = lineEnding.replace(text, "\n");

            var yOffset:Float = 0;
            for(line in uniformedText.split("\n")){
                var formattedLine = parseLine(line);
                formattedLine.y = yOffset;
                yOffset += formattedLine.height;
                sprite.addChild(formattedLine);
            }
            sprite.graphics.beginFill(0x000000, 0.001);
            sprite.graphics.drawRect(0, 0, sprite.width, sprite.height);
            sprite.graphics.endFill();

        }
        widthTF = widthText;

        return sprite;
    }

    private static function parseLine(line:String):Sprite
    {
        var styleName = "";
        var substring:String = line;
        var level = 1;
        var param:String = null;
        var output:Sprite = new Sprite();

        while(substring.charAt(0) == " "){
            level++;
            substring = substring.substr(1);
        }

        switch(substring.charAt(0)) {
            // Bigger Style
            case "+": styleName += "big-";
                substring = substring.substr(1);
            // Smaller Style
            case "-": styleName += "small-";
                substring = substring.substr(1);
            // Title style
            case "#": styleName += "title";
                substring = substring.substr(1);
                while(substring.charAt(0) == "#"){
                    level++;
                    substring = substring.substr(1);
                }
                styleName += Std.string(level);
            // Quote Style
            case ">": styleName += "quote";
                substring = substring.substr(1);
            // Lists Style
            case "*": if(substring.charAt(1) == " " || substring.substr(1).indexOf("*") == -1){
                styleName += "list" + level;
                substring = substring.substr(1);
            }
            // Default Style
            default: substring = line;
        }

        if(styleName == "" && substring.charAt(1) == "."){
            styleName += "ordered" + level;
            param = substring.charAt(0);
            substring = substring.substr(2);
        }

        substring = StringTools.ltrim(substring);

        var style = StyleParser.getStyle(styleName);

        // Image Style
        var regexImg:EReg = ~/!\[(.+)\]\((.+)\)!/;
        if(regexImg.match(substring)){
            styleName += "image";
            param = regexImg.matched(1);
            var img = LoadData.instance.getElementDisplayInCache(regexImg.matched(2));
            substring = regexImg.replace(substring, "");
            if(regexImg.matchedLeft() != "")
                concatObjects(output, createTextField(regexImg.matchedLeft(), style));
            concatObjects(output, img);
            if(regexImg.matchedRight() != "")
                concatObjects(output, createTextField(regexImg.matchedRight(), style));
        }

        // Custom Style
        var regexStyle:EReg = ~/\[(.+)\](.+)\[\/(.+)\]/;
        if(regexStyle.match(substring)){
            styleName = regexStyle.matched(1);
            substring = regexStyle.replace(substring, "");
            if(regexStyle.matchedLeft() != "")
                concatObjects(output, createTextField(regexStyle.matchedLeft(), style));
            concatObjects(output, createTextField(regexStyle.matched(2), StyleParser.getStyle(styleName)));
            substring = regexStyle.matchedRight();
        }

        // Link style
        var regexLink:EReg = ~/@\[(.+)\]\((.+)\)@/;
        if(regexLink.match(substring)){
            substring = regexLink.replace(substring, "");
            var url = new UrlField(regexLink.matched(2), regexLink.matched(1));
            if(regexLink.matchedLeft() != "")
                concatObjects(output, createTextField(regexLink.matchedLeft(), style));
            concatObjects(output, url);
            if(regexLink.matchedRight() != "")
                concatObjects(output, createTextField(regexLink.matchedRight(), style));
        }

        // Add background and sprite to textfield
        if(style != null){
            var hasIcon = false;
            if(style.icon != null){
                setIcons(substring, style, output);
                hasIcon = true;
            }
            if(style.background != null){
                setBackground(style, output, param);
            }
            if(!hasIcon)
                concatObjects(output, createTextField(substring, style));
        }
        else if(substring != ""){
            concatObjects(output, createTextField(substring, style));
        }

        return output;
    }

    private static function concatObjects(container:DisplayObjectContainer, objLeft:DisplayObject, ?objRight:DisplayObject):Void
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

    static private function createTextField(substring:String, ?style:Style):StyledTextField
    {
        var tf = new StyledTextField();

        if(style != null)
            tf.style = style;

        var styleName:String = tf.style.name;
        styleName = StringTools.replace(styleName, "text", "");

        var regexBold:EReg = ~/\*(.+)\*/;
        var hasBold = regexBold.match(substring);
        if(hasBold){
            substring = regexBold.matchedLeft() + regexBold.matched(1) + regexBold.matchedRight();
        }

        var regexIta:EReg = ~/_(.+)_/;
        var hasItalic = regexIta.match(substring);
        if(hasItalic){
            substring = regexIta.matchedLeft() + regexIta.matched(1) + regexIta.matchedRight();
        }

        tf.text = substring;

        if(hasBold){
            if(styleName != "")
                styleName += styleName.charAt(styleName.length - 1) == "-" ? "" : "-";
            tf.setPartialStyle(StyleParser.getStyle(styleName + "bold"), regexBold.matchedPos().pos, regexBold.matchedPos().pos + regexBold.matchedPos().len - 2);
        }
        if(hasItalic)
            tf.setPartialStyle(StyleParser.getStyle(styleName + "-italic"), regexIta.matchedPos().pos, regexIta.matchedPos().pos + regexIta.matchedPos().len - 2);

        return tf;
    }

    static private function setIcons(substring:String, style:Style, output:Sprite):Void
    {
        var bmp = new Bitmap(style.icon);
        bmp.width = bmp.height = 10;
        var tf = createTextField(substring, style);
        switch(style.iconPosition) {
            case "before": concatObjects(output, bmp, tf);
            case "after": concatObjects(output, tf, bmp);
            case "both": concatObjects(output, bmp, tf);
                var bmpBis = new Bitmap(style.icon);
                bmpBis.width = bmpBis.height = 10;
                concatObjects(output, bmpBis);
            default: Lib.trace(style.iconPosition + ": this position is not handled");
        }

        var regexList:EReg = ~/list/;
        if(regexList.match(style.name)){
            bmp.y = output.height / 2 - bmp.height / 2;
        }
    }

    static private function setBackground(style:Style, output:Sprite, ?bulletChar:String):Void
    {
        if(style.background.opaqueBackground != null){
            if(bulletChar != null){
                var bullet = new StyledTextField(StyleParser.getStyle("text"));
                bullet.text = bulletChar;
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
            if(bulletChar != null){
                var bullet = new StyledTextField(StyleParser.getStyle("text"));
                bullet.text = bulletChar;
                style.background.width = bullet.width;
                style.background.height = bullet.height;
                output.addChild(style.background);
                output.addChild(bullet);
            }
            else{
                style.background.width = output.width;
                style.background.height = output.height;
            }
        }

    }

    private function new()
    {
        super();
    }
}