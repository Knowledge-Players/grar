package grar.view;

typedef DisplayCallbacks = {

	var onContextualDisplayRequest : grar.view.Application.ContextualType -> Bool -> Void;

	var onContextualHideRequest : grar.view.Application.ContextualType -> Void;

	var onQuitGameRequest : Void -> Void;

	var onTransitionRequest : Dynamic -> String -> Float -> motion.actuators.GenericActuator.IGenericActuator;

	var onStopTransitionRequest : Dynamic -> Null<Dynamic> -> Bool -> Bool -> Void;

	var onRestoreLocaleRequest : Void -> Void;

	var onLocalizedContentRequest : String -> String;

	var onLocaleDataPathRequest : String -> Void;

	var onStylesheetRequest : Null<String> -> grar.view.style.StyleSheet;

	var onFiltersRequest : Array<String> -> Array<flash.filters.BitmapFilter>;

	var onPartDisplayRequest : grar.model.part.Part -> Void;

	var onSoundToLoad : String -> Void;

	var onSoundToPlay : String -> Void;

	var onSoundToStop : Void -> Void;


	/**
	 * PartDisplay only
	 */

	var onActivateTokenRequest : String -> Void;


	/**
	 * Layout only
	 */
	var onNewZone : grar.view.layout.Zone -> Void;
}