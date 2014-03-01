package grar.view;

typedef DisplayCallbacks = {

	var onContextualDisplayRequested : grar.view.Application.ContextualType -> Bool -> Void;

	var onContextualHideRequested : grar.view.Application.ContextualType -> Void;

	var onQuitGameRequested : Void -> Void;

	var onTransitionRequested : Dynamic -> String -> Float -> motion.actuators.GenericActuator.IGenericActuator;

	var onStopTransitionRequested : Dynamic -> Null<Dynamic> -> Bool -> Bool -> Void;

	var onRestoreLocaleRequest : Void -> Void;

	var onLocalizedContentRequest : String -> String;

	var onLocaleDataPathRequest : String -> Void;

	var onStylesheetRequest : Null<String> -> grar.view.style.StyleSheet;

	var onFiltersRequest : Array<String> -> Array<flash.filters.BitmapFilter>;
}