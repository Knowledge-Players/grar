package grar.view;

typedef DisplayCallbacks = {

	var onQuitGameRequest : Void -> Void;


	/**
	 * PartDisplay only
	 */

	var onActivateTokenRequest : String -> Void;
}