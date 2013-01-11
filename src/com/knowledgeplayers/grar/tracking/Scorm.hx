package com.knowledgeplayers.grar.tracking;

import nme.external.ExternalInterface;

class Scorm {
	
	private var __connectionActive:Bool = false;
	private var __debugActive:Bool = true;


	public function new() {
	
		var is_EI_available:Bool = ExternalInterface.available,
			wrapperFound:Bool = false,
			debugMsg:String = "Initializing SCORM class. Checking dependencies: ";
			
		if(is_EI_available){
			
			debugMsg += "ExternalInterface.available evaluates true. ";
			
			wrapperFound = cast (ExternalInterface.call("pipwerks.SCORM.isAvailable"), Bool);
			debugMsg += "SCORM.isAvailable() evaluates " +Std.string(wrapperFound) +". ";
			
			if(wrapperFound){
				
				debugMsg += "SCORM class file ready to go!  :) ";
			
			} else {

				debugMsg += "The required JavaScript SCORM API wrapper cannot be found in the HTML document.  Course cannot load.";
			
			}
			
		} else {
			
			debugMsg += "ExternalInterface is NOT available (this may be due to an outdated version of Flash Player).  Course cannot load.";
			
		}

		__displayDebugInfo(debugMsg);
	
	}


	
	// --- public functions --------------------------------------------- //
	

	public function setDebugMode(status:Bool) : Void {
		this.__debugActive = status;
	}

	public function getDebugMode():Bool {
		return this.__debugActive;
	}

	public function connect():Bool {
		__displayDebugInfo("pipwerks.SCORM.connect() called from class file");
		return __connect();
	}
	
	public function disconnect():Bool {
		return __disconnect();
	}
	
	public function get(param:String):String {
		var str:String = __get(param);
		__displayDebugInfo("public function get returned: " +str);
		return str;
	}
	
	public function set(parameter:String, value:String):Bool {
		
		return __set(parameter, value);
	}
	
	public function save():Bool {
		return __save();
	}
	


	// --- private functions --------------------------------------------- //
	
	
	private function __connect():Bool {
		
		var result:Bool = false;
		
		if(!__connectionActive){
			
			var eiCall:String = null;
			if(ExternalInterface.available)
				eiCall = Std.string(ExternalInterface.call("pipwerks.SCORM.init"));
			result = __stringToBool(eiCall);
			
			if (result){
				__connectionActive = true;
			} 
			else {
				var errorCode:Int = __getDebugCode();
				if(errorCode == 0){
					var debugInfo:String = __getDebugInfo(errorCode);
					__displayDebugInfo("pipwerks.SCORM.init() failed. \n"
									  +"Error code: " +errorCode +"\n"
									  +"Error info: " +debugInfo);
				} else {
					__displayDebugInfo("pipwerks.SCORM.init failed: no response from server.");
				}
			}
		} else {
			  __displayDebugInfo("pipwerks.SCORM.init aborted: connection already active.");
		}
		
		__displayDebugInfo("__connectionActive: " +__connectionActive);
		
		return result;
	}

	
	private function __disconnect():Bool {
		
		var result:Bool = false;
		if(__connectionActive){
			var eiCall:String = Std.string(ExternalInterface.call("pipwerks.SCORM.quit"));
			result = __stringToBool(eiCall);
			if (result){
				__connectionActive = false;
			} else {
				var errorCode:Int = __getDebugCode();
				var debugInfo:String = __getDebugInfo(errorCode);
				__displayDebugInfo("pipwerks.SCORM.quit() failed. \n"
								  +"Error code: " +errorCode +"\n"
								  +"Error info: " +debugInfo);
			}
		} else {
			__displayDebugInfo("pipwerks.SCORM.quit aborted: connection already inactive.");
		}
		return result;
	}
	
	
	private function __get(parameter:String):String {
	
		var returnedValue:String = "";
		
		if (__connectionActive){
			
			returnedValue = Std.string(ExternalInterface.call("pipwerks.SCORM.get", parameter));
			var errorCode:Int = __getDebugCode();

			//GetValue returns an empty string on errors
			//Double-check errorCode to make sure empty string
			//is really an error and not field value
			if (returnedValue == "" && errorCode != 0){
				var debugInfo:String = __getDebugInfo(errorCode);
				__displayDebugInfo("pipwerks.SCORM.get(" +parameter +") failed. \n"
								  +"Error code: " +errorCode +"\n"
								  +"Error info: " +debugInfo);
			}
		} else {
			__displayDebugInfo("pipwerks.SCORM.get(" +parameter +") failed: connection is inactive.");
		}		
		return returnedValue;
	}

	
	private function __set(parameter:String, value:String):Bool {
	
		var result:Bool = false;
		if (__connectionActive){
			var eiCall:String = ExternalInterface.call("pipwerks.SCORM.set", parameter, value);
			result = __stringToBool(eiCall);
			
			if(!result){
				var errorCode:Int = __getDebugCode();
				var debugInfo:String = __getDebugInfo(errorCode);
				__displayDebugInfo("pipwerks.SCORM.set(" +parameter +") failed. \n"
								  +"Error code: " +errorCode +"\n"
								  +"Error info: " +debugInfo);
			}
		} else {
			__displayDebugInfo("pipwerks.SCORM.set(" +parameter +") failed: connection is inactive.");
		}
		return result;
	}
		
		
	private function __save():Bool {
		
		var result:Bool = false;
		if(__connectionActive){
			var eiCall:String = Std.string(ExternalInterface.call("pipwerks.SCORM.save"));
			result = __stringToBool(eiCall);
			if(!result){
				var errorCode:Int = __getDebugCode();
				var debugInfo:String = __getDebugInfo(errorCode);
				__displayDebugInfo("pipwerks.SCORM.save() failed. \n"
								  +"Error code: " +errorCode +"\n"
								  +"Error info: " +debugInfo);
			}
		} else {
			__displayDebugInfo("pipwerks.SCORM.save() failed: API connection is inactive.");
		}
		return result;
	}
		

	// --- debug functions ----------------------------------------------- //
		
	private function __getDebugCode():Int {
		var code:Int = -1;
		if (ExternalInterface.available)
			code = cast (ExternalInterface.call("pipwerks.SCORM.debug.getCode"), Int);
		return code;
	}
		
	private function __getDebugInfo(errorCode:Int):String {
		var result:String = "";
		if (ExternalInterface.available)
			result = Std.string(ExternalInterface.call("pipwerks.SCORM.debug.getInfo", errorCode));
		return result;
	}
	
	private function __getDiagnosticInfo(errorCode:Int):String {
		var result:String = "";
		if (ExternalInterface.available)
			result = cast (ExternalInterface.call("pipwerks.SCORM.debug.getDiagnosticInfo", errorCode), String);
		return result;
	}

	private function __displayDebugInfo(msg:String):Void {
		if(__debugActive)
		{
			if (ExternalInterface.available)
			ExternalInterface.call("pipwerks.UTILS.trace", msg);
			//trace("msg scorm : "+msg)
		}	
			
		
	}
	
	private function __stringToBool(value:String):Bool {
		return value == "true";
	}
}