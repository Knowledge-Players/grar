package com.knowledgeplayers.grar.display.style;
import nme.text.TextFieldAutoSize;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import com.knowledgeplayers.grar.display.text.UrlField;
import nme.display.Sprite;
class KpTextDownElement {

    public var content (default,default):String;
    public var style (default,default):String;

    private var width:Float;


    public function new() {
    }

    public function createSprite(_width:Float):Sprite
    {
        var styleName = style;
        var output = new Sprite();
        width = _width;
        // Image Style
        var regexImg:EReg = ~/!\[(.+)\]\((.+)\)!/;
        if(regexImg.match(content)){
            styleName += "image";
            param = regexImg.matched(1);
            var img = LoadData.instance.getElementDisplayInCache(regexImg.matched(2));
            content = regexImg.replace(content, "");
            if(regexImg.matchedLeft() != "")
                concatObjects(output, createTextField(regexImg.matchedLeft(), styleName));
            concatObjects(output, img);
            if(regexImg.matchedRight() != "")
                concatObjects(output, createTextField(regexImg.matchedRight(), styleName));
        }

        // Custom Style
        var regexStyle:EReg = ~/\[(.+)\](.+)\[\/(.+)\]/;
        if(regexStyle.match(content)){
            styleName = regexStyle.matched(1);
            content = regexStyle.replace(content, "");
            if(regexStyle.matchedLeft() != "")
                concatObjects(output, createTextField(regexStyle.matchedLeft(), styleName));
            concatObjects(output, createTextField(regexStyle.matched(2), StyleParser.getStyle(styleName)));
            content = regexStyle.matchedRight();
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
        if(style != null){
            var hasIcon = false;
            if(style.icon != null){
                setIcons(content, style, output);
                hasIcon = true;
            }
            if(style.background != null){
                setBackground(style, output, param);
            }
            if(!hasIcon)
                concatObjects(output, createTextField(content, styleName));
        }
        else if(content != ""){
            concatObjects(output, createTextField(content, styleName));
        }
        else{
            var height = StyleParser.getStyle().getSize();
            DisplayUtils.initSprite(output, 1, height, 0, 0.001);
        }

        return output;
    }

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

    static private function createTextField(content:String, ?styleName:String):StyledTextField
    {
        var style = StyleParser.getStyle(styleName);
        var tf = new StyledTextField();
        if(style != null)
            tf.style = style;

        styleName = StringTools.replace(styleName, "text", "");

        var regexBold:EReg = ~/\*([^*]+)\*/;
        var boldPos = new Array<{pos: Int, len: Int}>();
        while(regexBold.match(content)){
            boldPos.push(regexBold.matchedPos());
            content = regexBold.replace(content, regexBold.matched(1));
        }

        var regexIta:EReg = ~/_([^_]+)_/;
        var italicPos = new Array<{pos:Int, len:Int}>();
        while(regexIta.match(content)){
            italicPos.push(regexIta.matchedPos());
            content = regexIta.replace(content, regexIta.matched(1));
        }

        tf.text = content;

        tf.width = width;
        tf.wordWrap = true;
        tf.autoSize = style.getAlignment();
        tf.height += style.getPadding()[2];
        //tf.height = tf.textHeight;

        if(styleName != "")
            styleName += styleName.charAt(styleName.length - 1) == "-" ? "" : "-";
        for(matched in boldPos){
            tf.setPartialStyle(StyleParser.getStyle(styleName + "bold"), matched.pos, matched.pos + matched.len - 2);
        }
        for(matched in italicPos)
            tf.setPartialStyle(StyleParser.getStyle(styleName + "italic"), matched.pos, matched.pos + matched.len - 2);

        return tf;
    }

    static private function setIcons(content:String, styleName:String, output:Sprite):Void
    {
        var bmp = new Bitmap(style.icon);
        if(style.iconResize)
            bmp.width = bmp.height = 10;
        var tf = createTextField(content, styleName);
        switch(style.iconPosition) {
            case "before": concatObjects(output, bmp, tf);
            case "after": concatObjects(output, tf, bmp);
            case "both": concatObjects(output, bmp, tf);
                var bmpBis = new Bitmap(style.icon);
                if(style.iconResize)
                    bmpBis.width = bmpBis.height = 10;
                concatObjects(output, bmpBis);
            default: Lib.trace(style.iconPosition + ": this position is not handled");
        }

        bmp.y = StyleParser.getStyle().getSize() / 2 - bmp.height / 2;
    }

    static private function setBackground(styleName:String, output:Sprite, ?bulletChar:String):Void
    {
        var style = StyleParser.getStyle(styleName);
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
}
