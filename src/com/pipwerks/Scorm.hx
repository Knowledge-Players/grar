/*
ActionScript 3.0 SCORM API wrapper (v1.1.1) 

Copyright (c) 2008 Philip Hutchison
MIT-style license. Full license text can be found at 
http://www.opensource.org/licenses/mit-license.php

Created by Philip Hutchison, January 2008
http://pipwerks.com

FLAs published using this file must be published using AS3.
SWFs will only work in Flash Player 9 or higher.

This wrapper is designed to be SCORM version-neutral (it works
with SCORM 1.2 and SCORM 2004). It also requires the pipwerks 
SCORM API JavaScript wrapper in the course's HTML file. The 
wrapper can be downloaded from http://github.com/pipwerks/scorm-api-wrapper/

This class uses ExternalInterface. Testing in a local environment
will FAIL unless you set your Flash Player settings to allow local
SWFs to execute ExternalInterface commands.

Change your security settings using this link:
http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html

Use at your own risk! This class is provided as-is with no implied warranties or guarantees.
*/

package com.pipwerks;

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
	

	
} // end SCORM class