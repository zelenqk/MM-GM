// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function export_map(){
	save_map();
	
	var path = get_save_filename(".zip", "");	
	
	var zip = zip_create();
	
	var objects = [];
	var modelArr = [];
	
	var modelNames = ds_map_create();
	var modelsArr = ds_map_keys_to_array(models);
	
	for(var i = 0; i < array_length(modelsArr); i++){
		var model =	models[? modelsArr[i]];
		
		var u = 0;
		var next = "";
		
		while (ds_map_exists(modelNames, model.name)){
			u++
			next = " (" + string(u) + ")";
		}
		
		var filenamePath = string_replace(filename_name(model.path), filename_ext(model.path), "");
		filenamePath = filename_path(model.path) + "\\" + filenamePath;
		
		var modelName = string_replace(model.name, filename_ext(model.name), "");
		
		zip_add_file(zip, "models\\" + modelName + next +"\\" + modelName + filename_ext(model.name), model.path);
		if file_exists(filenamePath + ".mtl") zip_add_file(zip, "models\\" + modelName + next + "\\" + modelName + ".mtl", filenamePath + ".mtl");
		if file_exists(filenamePath + ".png") zip_add_file(zip, "models\\" + modelName + next + "\\" + modelName + ".png", filenamePath + ".png");
		if file_exists(filenamePath + ".jpg") zip_add_file(zip, "models\\" + modelName + next + "\\" + modelName + ".jpg", filenamePath + ".jpg");
		if file_exists(filenamePath + ".jpeg") zip_add_file(zip, "models\\" + modelName + next + "\\" + modelName + ".jpeg", filenamePath + ".jpg");
		
		modelNames[? model.name] = true;
		modelNames[? model.path] = {
			"name": model.name,
			"path": "/models/" + model.name + next
		};
		
		modelArr[array_length(modelArr)] = modelNames[? model.path];
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
			"customVariables": {},
			"model": noone,
		}
		
		for(var u = 0; u < array_length(customVariables); u++){
			variable_struct_set(object.customVariables, customVariables[i].name, customVariables[i].value);
		}
		
		if (ds_map_exists(modelNames, model.path)){
			object.model = modelNames[? model.path];
		}
		
		objects[array_length(objects)] = object;
	}
	
	var data = file_text_open_write("temp");
	file_text_write_string(data, json_stringify(objects));
	file_text_close(data);
	
	zip_add_file(zip, "data.json", "temp");
	
	var ext = filename_ext(path) == ".zip" ? "" : ".zip";
	
	zip_save(zip, path + ext);
}