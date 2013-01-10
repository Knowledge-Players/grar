package com.knowledgeplayers.grar.dialog.dialogmodel.conclusion;

class ConclusionActivity 
{
	private function new()
	{
		
	}

	public function finishWithFetch() : Bool
	{
		return true;
	}

	public function getType() : ConclusionType 
	{
		return null;
	}
}

enum ConclusionType 
{
	FETCH;
	SKETCH;
	CHECK;
	SHAKE;
}