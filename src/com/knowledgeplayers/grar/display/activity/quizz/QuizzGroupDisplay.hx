package com.knowledgeplayers.grar.display.activity.quizz;

import nme.Lib;
import nme.display.BitmapData;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.structure.activity.quizz.QuizzGroup;
import com.knowledgeplayers.grar.util.LoadData;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.Sprite;

/**
 * Display for a group of answer in a quizz
 */
class QuizzGroupDisplay extends Sprite {
    /**
     * Model to display
     */
    public var model (default, setModel):QuizzGroup;

    private var items:Array<QuizzItemDisplay>;
    private var xOffset:Float;
    private var yOffset:Float;
    private var itemTemplates:Hash<Fast>;
    private var separator:BitmapData;
    /**
     * Constructor
     * @param	group : Model to display
     */

    public function new(xOffset:Float = 0, yOffset:Float = 0, width:Float = 0, height:Float = 0, ?separator:BitmapData, ?xml:Fast)
    {
        super();
        items = new Array<QuizzItemDisplay>();
        itemTemplates = new Hash<Fast>();
        if(xml == null){
            this.xOffset = xOffset;
            this.yOffset = yOffset;
        }
        else{
            this.xOffset = Std.parseFloat(xml.att.xOffset);
            this.yOffset = Std.parseFloat(xml.att.yOffset);
            x = Std.parseFloat(xml.att.x);
            y = Std.parseFloat(xml.att.y);
            for(elem in xml.nodes.GroupElement){
                itemTemplates.set(elem.att.ref, elem);
            }
            if(xml.hasNode.Separator){
                var layer:TileLayer;
                if(xml.node.Separator.has.spritesheet)
                    layer = new TileLayer(QuizzDisplay.instance.spritesheets.get(xml.node.Separator.att.spritesheet));
                else
                    layer = new TileLayer(UiFactory.tilesheet);
                var sep = new TileSprite(xml.node.Separator.att.id);
                layer.addChild(sep);
                layer.render();
                separator = sep.bmp.bitmapData;
            }
            if(separator != null){
                this.separator = separator;
            }
        }

    }

    /**
     * Setter of the model
     * @param	model : Model to set
     * @return the model
     */

    public function setModel(model:QuizzGroup):QuizzGroup
    {
        graphics.clear();
        this.model = model;
        updateItems();

        return model;
    }

    /**
     * Validate the answers
     */

    public function validate():Void
    {
        for(item in items){
            item.validate();
        }
    }

    /**
     * Point out the good answers
     */

    public function correct():Void
    {
        for(item in items){
            item.displayCorrection();
        }
    }

    // Private

    private function updateItems():Void
    {
        var totalYOffset:Float = 0;
        unloadItems();
        for(item in model.items){
            var itemTemplate = itemTemplates.get(item.ref);
            var itemDisplay = new QuizzItemDisplay(item);
            if(itemTemplate.has.spritesheet)
                itemDisplay.setIcon(itemTemplate.att.id, itemTemplate.att.spritesheet);
            else if(itemTemplate.has.id)
                itemDisplay.setIcon(itemTemplate.att.id);
            itemDisplay.y = totalYOffset;
            itemDisplay.x = xOffset;
            itemDisplay.text.x = Std.parseFloat(itemTemplate.att.contentX);
            itemDisplay.correction.x = Std.parseFloat(itemTemplate.att.correctionX);
            itemDisplay.checkIcon.x = Std.parseFloat(itemTemplate.att.checkX);
            totalYOffset += itemDisplay.height;

            if(itemTemplate.has.background){
                DisplayUtils.setBackground(itemTemplate.att.background, itemDisplay);
            }

            items.push(itemDisplay);
            addChild(itemDisplay);
            var sep = new Bitmap(separator);
            sep.x = itemDisplay.x;
            sep.y = totalYOffset;
            addChild(sep);
            totalYOffset += yOffset + sep.height;
        }
    }

    private function unloadItems()
    {
        while(numChildren != 0)
            removeChildAt(numChildren - 1);
    }

}