package grar.service;

import kalturhaxe.KalturaHaxe;

class KalturaService{

	public function new(){ }

	public function createSession(pId: Int, secret: String, ?url: String = "//www.kaltura.com/", onSuccess: String -> Void):Void
	{
		var k = new KalturaHaxe(pId, url);
		k.createConnection(secret, function(success, result){
			if(!success)
				throw "Unable to connect to "+url+": "+result;

			onSuccess(result.substr(1, result.length-2));
		});
	}

	public function getUrl(entryId:String, bitrate:Float, ks:String, onSuccess:String -> Void):Void
	{
		var k = new KalturaHaxe(null, null, ks);
		k.getBitrateWiseAsset(entryId, bitrate, function(success, result){
			if(!success)
				throw "Unable to retrieve video "+entryId+": "+result;

			onSuccess(result.substr(1, result.length-2));
		});
	}
}