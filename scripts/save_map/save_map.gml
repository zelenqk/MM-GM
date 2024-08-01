// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function save_map(){
	var mapData = {
		"models": [],
		"objects": [],
	}
	
	try{
	
	var modelKeys = ds_map_keys_to_array(models);
	
	for(var i = 0; i < array_length(modelKeys); i++){
		array_push(mapData.models, modelKeys[i]);	
	}
	
	with (oModel){
		var object = {
			"x": x,
			"y": y,
			"z": z,
			"xRotation": xRotation,
			"yRotation": yRotation,
			"zRotation": zRotation,
			"xScale": xScale,
			"yScale": yScale,
			"zScale": zScale,
			"model": model.path,
			"customVariables": customVariables,
		}
		
		array_push(mapData.objects, object);	
	}
	
	var mapDataF = file_text_open_write(projectPath + "/data.json");
	file_text_write_string(mapDataF, json_stringify(mapData));
	file_text_close(mapDataF);
	
	header.message = ["Map successfully saved!", 100];
	editor.saved = true;
	
	for(var i = 0; i < array_length(editor.undo); i++){
		editor.undo[i].saved = false;
	}
	
	for(var i = 0; i < array_length(editor.redo); i++){
		editor.redo[i].saved = false;
	}
	
	}catch(e){
		header.message = ["Something went wrong while trying to save the map", 100];	
	}
}