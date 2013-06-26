package
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.structure.activity.folder.FolderElement;
import aze.display.TilesheetEx;
import haxe.xml.Fast;

/**
* Display of an popup in a folder activity
**/

class PopupDisplay extends WidgetContainer {

    public function new(?xml: Fast, ?tilesheet: TilesheetEx)
    {
        super(xml,tilesheet);

        trace("popup xml : "+xml);
    }
}
