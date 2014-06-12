package grar.model.part.item;

import grar.model.part.Part.ImageData;
import haxe.ds.GenericStack;
import haxe.ds.StringMap;

typedef ItemData = {

	var id : String;
	var content : String;
	var author: Null<String>;
	var background : Null<String>;
	var button : Null<List<ButtonData>>;
	var ref : Null<String>;
	var tokens : GenericStack<String>;
	var images : List<ImageData>;
	var endScreen : Bool;
	var videoData: VideoData;
	var soundData: SoundData;
}

typedef SubtitleData ={
	var src:String;
	var lang:String;
}

typedef VideoData = {
	/**
	 * Autostart the video
	 **/
	var autoStart: Bool;

	/**
	 * Autofullscreen the video
	 **/
	var fullscreen: Bool;

	/**
	 * Loop the video
	 **/
	var loop: Bool;

	/**
	 * Default volume. 0 = mute, 1 = max volume
	 **/
	var defaultVolume: Float;

	/**
	 * Time to capture an image for the thumbnail
	 **/
	var capture: Float;

	/**
	* Map of subtitles by language
	**/
	var subtitles: Map<String, SubtitleData>;
}

typedef SoundData = {
	/**
	 * Autostart the sound
	 **/
	var autoStart: Bool;

	/**
	 * Loop the sound
	 **/
	var loop: Bool;

	/**
	 * Default volume. 0 = mute, 1 = max volume
	 **/
	var defaultVolume: Float;
}

class Item{

	public function new(o : ItemData) {

		this.id = o.id;
		this.content = o.content;
		this.author = o.author;
		this.background = o.background;
		this.button = o.button;
		this.ref = o.ref;
		this.tokens = o.tokens;
		this.images = o.images;
		this.endScreen = o.endScreen;
		this.videoData = o.videoData;
		this.soundData = o.soundData;
	}

	/**
	 * @inherits
	 **/
	public var id (default, null) : String;

	/**
     * Content of the item
     */
	public var content (default, default) : String;

	/**
     * Background when the item is displayed
     **/
	public var background (default, default) : String;

	/**
     * ID of the button that will appear with this item
     **/
	public var button (default, default) : Null<List<ButtonData>>;

	/**
     * Unique ref that will match the display
     **/
	public var ref (default, default) : String;

	/**
     * Reference to the tokens in this item
     **/
	public var tokens (default, null) : GenericStack<String>;

	/**
     * Graphicals items associated with this item
     **/
	public var images (default, default) : List<ImageData>;

	/**
     * Character who says this text
     */
	public var author (default, default) : String;

	/**
     * Sound to play during this item
     **/
	public var sound (default, default) : String;

	/**
	 * Introduction screen to show before this item
	 **/
	public var introScreen (default, default) : {ref:String, content:StringMap<String>};

	public var endScreen (default, null) : Bool = false;

	public var videoData (default, default):VideoData;

	public var soundData (default, default):SoundData;
}
