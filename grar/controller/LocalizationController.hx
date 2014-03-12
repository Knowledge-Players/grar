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


		state.onLocaleListChanged = function() {

				// doesn't seem to be used ?
				// for each lang, flags.set(value, flagIconPath);

				// implement a loadCurrentLocale(); ?
			}

		application.onRestoreLocaleRequest = function() {

				restoreLocaleData();
			}

		application.onInterfaceLocaleDataPathRequest = function() {

				setInterfaceLocaleData();
			}

		application.onLocaleDataPathRequest = function(path : String) {

				state.module.currentLocaleDataPath = path;
			}

		application.onLocalizedContentRequest = function(k : String) : String {

				return state.module.getLocalizedContent(k);
			}
	}

	function initLocaleData() : Void {

		var fullPath = state.module.currentLocaleDataPath.split("/");

		var localePath : StringBuf = new StringBuf();

		localePath.add(fullPath[0] + "/");
		localePath.add(state.module.currentLocale + "/");
		
		for (i in 1...fullPath.length-1) {

			localePath.add(fullPath[i] + "/");
		}
		localePath.add(fullPath[fullPath.length-1]);
		
		gameSrv.fetchLocaleData(state.module.currentLocale, localePath.toString(), function(ld : LocaleData){

				state.module.localeData = ld;

			}, parent.onError);
	}

	public function setInterfaceLocaleData() : Void {

		state.module.currentLocaleDataPath = state.module.interfaceLocaleDataPath;
	}

	public function restoreLocaleData() : Void {

		state.module.restoreLocale();
	}
}