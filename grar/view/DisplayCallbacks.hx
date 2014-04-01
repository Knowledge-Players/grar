package grar.view;

typedef DisplayCallbacks = {

	var onContextualDisplayRequest : grar.view.Application.ContextualType -> Bool -> Void;

	var onContextualHideRequest : grar.view.Application.ContextualType -> Void;

	var onQuitGameRequest : Void -> Void;

	var onSoundToLoad : String -> Void;

	var onSoundToPlay : String -> Void;

	var onSoundToStop : Void -> Void;


	/**
	 * PartDisplay only
	 */

	var onActivateTokenRequest : String -> Void;
}