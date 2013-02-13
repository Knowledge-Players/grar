package com.knowledgeplayers.grar.display.activity.quizz;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.util.LoadData;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.structure.activity.quizz.QuizzGroup;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.display.Sprite;
import nme.Lib;

/**
 * Display for a group of answer in a quizz
 */
class QuizzGroupDisplay extends Sprite {
    /**
     * Model to display
     */
    public var model (default, setModel): QuizzGroup;

    private var items: Array<QuizzItemDisplay>;
    private var xOffset: Float;
    private var yOffset: Float;
    private var itemTemplates: Hash<Fast>;

    /**
     * Constructor
     * @param	group : Model to display
     */

    public function new(xOffset: Float = 0, yOffset: Float = 0, width: Float = 0, height: Float = 0, ?xml: Fast)
    {
        super();
        items = new Array<QuizzItemDisplay>();
        itemTemplates = new Hash<Fast>();
        if(xml == null){
            this.xOffset = xOffset;
            this.yOffset = yOffset;
            graphics.beginFill(0);
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();
        }
        else{
            this.xOffset = Std.parseFloat(xml.att.xOffset);
            this.yOffset = Std.parseFloat(xml.att.yOffset);
            x = Std.parseFloat(xml.att.x);
            y = Std.parseFloat(xml.att.y);
            graphics.beginFill(0);
            graphics.drawRect(0, 0, Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height));
            graphics.endFill();
            for(elem in xml.nodes.GroupElement){
                itemTemplates.set(elem.att.ref, elem);
            }
        }

    }

    /**
     * Setter of the model
     * @param	model : Model to set
     * @return the model
     */

    public function setModel(model: QuizzGroup): QuizzGroup
    {
        graphics.clear();
        this.model = model;
        updateItems();

        return model;
    }

    /**
     * Validate the answers
     */

    public function validate(): Void
    {
        for(item in items){
            item.validate();
        }
    }

    /**
     * Point out the good answers
     */

    public function correct(): Void
    {
        for(item in items){
            item.displayCorrection();
        }
    }

    // Private

    private function updateItems(): Void
    {
        var totalYOffset: Float = 0;
        unloadItems();
        for(item in model.items){
            var itemTemplate = itemTemplates.get(item.ref);
            var itemDisplay = new QuizzItemDisplay(item);
            // Do we have to use these ?
            /*itemDisplay.width = Std.parseFloat(itemTemplate.att.width);
            itemDisplay.height = Std.parseFloat(itemTemplate.att.height);*/
            itemDisplay.y = totalYOffset;
            itemDisplay.x = xOffset;
            itemDisplay.text.x = Std.parseFloat(itemTemplate.att.contentX);
            itemDisplay.correction.x = Std.parseFloat(itemTemplate.att.correctionX);
            itemDisplay.checkIcon.x = Std.parseFloat(itemTemplate.att.checkX);
            //Lib.trace("itemTemplate.att.background : "+itemTemplate.att.background);

            if(Std.parseInt(itemTemplate.att.background) != null)
            {
                itemDisplay.graphics.beginFill(Std.parseInt(itemTemplate.att.background));
                itemDisplay.graphics.drawRect(0, 0, Std.parseFloat(itemTemplate.att.width), Std.parseFloat(itemTemplate.att.height));
                itemDisplay.graphics.endFill();
            }
            else
            {
                var bmp = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(itemTemplate.att.background),Bitmap).bitmapData);

                    itemDisplay.addChild(bmp);
            }

            //DisplayUtils.setBackground(itemTemplate.att.background, itemDisplay);

            totalYOffset += yOffset;
            items.push(itemDisplay);
            addChild(itemDisplay);
        }
    }

    private function unloadItems()
    {
        while(numChildren != 0)
            removeChildAt(numChildren - 1);
    }

}