package com.knowledgeplayers.grar.tracking;

import flash.external.ExternalInterface;

class Scorm {

	private var activeConnection:Bool = false;
	private var debug:Bool = true;

	public function new()
	{
	}

	// --- public functions --------------------------------------------- //

	public function setDebugMode(status:Bool):Void
	{
		this.debug = status;
	}

	public function getDebugMode():Bool
	{
		return this.debug;
	}

	public function connect():Bool
	{
		var result:Bool = false;

		#if flash
		if(!activeConnection){

			var eiCall:String = null;
			if(ExternalInterface.available)
				eiCall = Std.string(ExternalInterface.call("pipwerks.SCORM.init"));
			result = eiCall == "true";

			if(result){
				activeConnection = true;
			}
			else{
				var errorCode:Int = getDebugCode();
				if(errorCode == 0){
					var debugInfo:String = getDebugInfo(errorCode);
					displayDebugInfo("pipwerks.SCORM.init() failed. \n"
					+ "Error code: " + errorCode + "\n"
					+ "Error info: " + debugInfo);
				}
				else{
					displayDebugInfo("pipwerks.SCORM.init failed: no response from server.");
				}
			}
		}
		else{
			displayDebugInfo("pipwerks.SCORM.init aborted: connection already active.");
		}

		displayDebugInfo("__connectionActive: " + activeConnection);
		#else
		var wrapper:Dynamic = untyped __js__('pipwerks.SCORM.init()');
		result = wrapper == "true";
		#end

		return result;
	}

	public function disconnect():Bool
	{
		var result:Bool = false;
		#if flash
		if(activeConnection){
			var eiCall:String = Std.string(ExternalInterface.call("pipwerks.SCORM.quit"));
			result = eiCall == "true";
			if(result){
				activeConnection = false;
			}
			else{
				var errorCode:Int = getDebugCode();
				var debugInfo:String = getDebugInfo(errorCode);
				displayDebugInfo("pipwerks.SCORM.quit() failed. \n"
				+ "Error code: " + errorCode + "\n"
				+ "Error info: " + debugInfo);
			}
		}
		else{
			displayDebugInfo("pipwerks.SCORM.quit aborted: connection already inactive.");
		}
		#else
		var wrapper:Dynamic = untyped __js__('pipwerks.SCORM.quit()');
		result = wrapper == "true";
		#end
		return result;
	}

	public function get(param:String):String
	{
		var returnedValue:String = "";

		#if flash
		if(activeConnection){

			returnedValue = Std.string(ExternalInterface.call("pipwerks.SCORM.get", param));
			var errorCode:Int = getDebugCode();

			//GetValue returns an empty string on errors
			//Double-check errorCode to make sure empty string
			//is really an error and not field value
			if(returnedValue == "" && errorCode != 0){
				var debugInfo:String = getDebugInfo(errorCode);
				displayDebugInfo("pipwerks.SCORM.get(" + param + ") failed. \n"
				+ "Error code: " + errorCode + "\n"
				+ "Error info: " + debugInfo);
			}
		}
		else{
			displayDebugInfo("pipwerks.SCORM.get(" + param + ") failed: connection is inactive.");
		}
		#else
		returnedValue = untyped __js__('pipwerks.SCORM.get('+param+')');
		#end
		return returnedValue;
	}

	public function set(parameter:String, value:String):Bool
	{
		var result:Bool = false;
		#if flash
		if(activeConnection){
			var eiCall:String = ExternalInterface.call("pipwerks.SCORM.set", parameter, value);
			result = eiCall == "true";

			if(!result){
				var errorCode:Int = getDebugCode();
				var debugInfo:String = getDebugInfo(errorCode);
				displayDebugInfo("pipwerks.SCORM.set(" + parameter + ") failed. \n"
				+ "Error code: " + errorCode + "\n"
				+ "Error info: " + debugInfo);
			}
		}
		else{
			displayDebugInfo("pipwerks.SCORM.set(" + parameter + ") failed: connection is inactive.");
		}
		#else
		var wrapper:Dynamic = untyped __js__('pipwerks.SCORM.set('+parameter+','+value+')');
		result = wrapper == "true";
		#end
		return result;
	}

	public function save():Bool
	{
		var result:Bool = false;
		#if flash
		if(activeConnection){
			var eiCall:String = Std.string(ExternalInterface.call("pipwerks.SCORM.save"));
			result = eiCall == "true";
			if(!result){
				var errorCode:Int = getDebugCode();
				var debugInfo:String = getDebugInfo(errorCode);
				displayDebugInfo("pipwerks.SCORM.save() failed. \n"
				+ "Error code: " + errorCode + "\n"
				+ "Error info: " + debugInfo);
			}
		}
		else{
			displayDebugInfo("pipwerks.SCORM.save() failed: API connection is inactive.");
		}
		#else
		var wrapper:Dynamic = untyped __js__('pipwerks.SCORM.save()');
		result = wrapper == "true";
		#end
		return result;
	}

	// --- debug functions ----------------------------------------------- //

	private function getDebugCode():Int
	{
		var code:Int = -1;
		#if flash
		if(ExternalInterface.available)
			code = cast (ExternalInterface.call("pipwerks.SCORM.debug.getCode"), Int);
		#else
		var wrapper:Dynamic = untyped __js__('pipwerks.SCORM.debug.getCode()');
		code = Std.parseInt(wrapper);
		#end
		return code;
	}

	private function getDebugInfo(errorCode:Int):String
	{
		var result:String = "";
		#if flash
		if(ExternalInterface.available)
			result = Std.string(ExternalInterface.call("pipwerks.SCORM.debug.getInfo", errorCode));
		#else
		result = untyped __js__('pipwerks.SCORM.getInfo('+errorCode+')');
		#end
		return result;
	}

	private function __getDiagnosticInfo(errorCode:Int):String
	{
		var result:String = "";
		#if flash
		if(ExternalInterface.available)
			result = cast (ExternalInterface.call("pipwerks.SCORM.debug.getDiagnosticInfo", errorCode), String);
		#else
		result = untyped __js__('pipwerks.SCORM.getDiagnosticInfo('+errorCode+')');
		#end
		return result;
	}

	private function displayDebugInfo(msg:String):Void
	{
		if(debug){
			#if flash
			if(ExternalInterface.available)
				ExternalInterface.call("pipwerks.UTILS.trace", msg);
			#else
			untyped __js__('pipwerks.UTILS.trace('+msg+')');
			#end
		}

	}
}