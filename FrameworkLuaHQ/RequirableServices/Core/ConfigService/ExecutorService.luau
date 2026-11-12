local SPACE = {
	ACTOR_FOLDER_NAME = "ActorFolder",
	BOOT_MODULE_NAME = "BootModule",
	MAIN_FUNCTION_NAME = "Main",  --// DO NOT CHANGE, will brick many scripts.
	
	PREMATURE_CALL = "Tried To Call Function While No BootModule Is Present! ",
	
	INITIALIZATION_FAILED_COUNT = "Initialization Failed! Attempt Count Exceeded. ",
	INITIALIZATION_FAILED_CLEAR = "Initialization Failed! Runtime Instance Must Be Clear. ",
	
	RUNTIME_ACTOR_NIL = "Runtime Initialization Failed! Actor Is Nil. ",
	
	MAIN_FAILURE = "Runtime Initialization Failed! Main Funtion Failed. ",
	
	CALL_ON_NONE_TABLE = "Tried To Call A Non Table! ",
	CALL_ON_NIL = "No Index Found In Main Return! ",
	CALL_ON_NONE_FUNCTION = "Called Index Was Not A Function! ",
	
	MAX_INITIALIZATION_ATTEMPS = 60,
	
}

return SPACE
