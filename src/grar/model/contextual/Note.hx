package grar.model.contextual;

import grar.model.InventoryToken;

class Note extends InventoryToken {

	static inline var TOKEN_TYPE_NOTE : String = "note";

	/**
	 * URL of the video contained in this note
	 **/
	public var video (default, default) : Null<String> = null;

	public function new(? td : Null<TokenData>, ? v : Null<String>) {

		super(td);

		this.type = TOKEN_TYPE_NOTE;
		this.video = v;
	}
}