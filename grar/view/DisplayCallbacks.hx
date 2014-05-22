package grar.view;

typedef DisplayCallbacks = {

	var onQuitGameRequest : Void -> Void;

	var onSoundToLoad : String -> Void;

	var onSoundToPlay : String -> Void;

	var onSoundToStop : Void -> Void;


	/**
	 * PartDisplay only
	 */

	var onActivateTokenRequest : String -> Void;
}