package grar.controller;

import grar.Controller;

import grar.model.State;
import grar.model.Config;
import grar.model.Grar;
import grar.model.localization.Locale;
import grar.model.localization.LocaleData;

import grar.view.Application;

import grar.service.GameService;

class LocalizationController {

	public function new(parent : Controller, state : State, config : Config, application : Application, gameSrv : GameService) {

		this.parent = parent;

		this.config = config;
		this.state = state;

		this.application = application;

		this.gameSrv = gameSrv;

		init();
	}

	var parent : Controller;

	var config : Config;
	var state : State;

	var application : Application;

	var gameSrv : GameService;
	var localeChangeCallback: Void -> Void;

	public function setLocaleDataPath(path:String, ?onSuccess: Void -> Void):Void
	{
		state.module.currentLocaleDataPath = path;
		if(state.module.hasLocaleChanged())
			localeChangeCallback = onSuccess;
		else
			onSuccess();
	}

	function init() : Void {

		state.onCurrentLocaleChanged = function() {

				if (state.module.currentLocaleDataPath != null && state.module.localeData == null) {


					initLocaleData();
				}
			}

		state.onCurrentLocalePathChanged = function() {

				if (state.module.currentLocaleDataPath != null && state.module.currentLocale != null) {

					initLocaleData();
				}
			}
	}

	function initLocaleData() : Void {

		var fullPath: Array<String> = state.module.currentLocaleDataPath.split("/");

		var path: String = null;
		if(fullPath.length == 1)
			path = state.module.currentLocale + "/" + fullPath[0];
		else{
			var localePath : StringBuf = new StringBuf();

			localePath.add(fullPath[0] + "/");
			localePath.add(state.module.currentLocale + "/");

			for (i in 1...fullPath.length-1) {

				localePath.add(fullPath[i] + "/");
			}
			localePath.add(fullPath[fullPath.length-1]);
			path = localePath.toString();
		}

		gameSrv.fetchLocaleData(state.module.currentLocale, path, function(ld : LocaleData){

				state.module.localeData = ld;
				if(localeChangeCallback != null)
					localeChangeCallback();

			}, parent.onError);
	}

	public function setInterfaceLocaleData() : Void {

		state.module.currentLocaleDataPath = state.module.interfaceLocaleDataPath;
	}

	public function restoreLocaleData() : Void {

		state.module.restoreLocale();
	}
}