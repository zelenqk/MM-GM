globalvar models, iconAABB, iconCamera, iconSurface;
models = ds_map_create();
iconAABB = [-1, -1, -1, 1, 1, 1];
iconCamera = camera_create();
iconSurface = surface_create(128, 128);

function load_model(path = noone){
	if (path == noone) path = get_open_filename("models|*.obj;*.smf*", "");
	if (path == "") return;
	
	if (!ds_map_exists(models, path)){
		var name = string_split(path, "\\", true);
		name = name[array_length(name) - 1];
		
		var name = string_split(name, "/", true);
		name = name[array_length(name) - 1];
		
		var matrix = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
		swap_axes(matrix, "y", "z");
		
		switch(filename_ext(path)){
		case ".smf":
			var model = smf_model_load(path);
			if (model = -1) return noone;
			
			var tempInstance = new smf_instance(model);
			var mBuff = cm_convert_smf(model);
			
			models[? path] = {
				"model": model,
				"tempInstance": tempInstance,
				"icon": sMissingTexture,
				"type": "smf",
				"path": path,
				"name": name,
				"mBuff": noone,
				"cm": cm_list(),
			}
			
			cm_add_buffer(models[? path].cm, models[? path].mBuff, , matrix);
			break;
		case ".obj":
			var model = smf_model_load_obj(path);
			if (model = -1) return noone;
			
			var tempInstance = new smf_instance(model);
			var mBuff = cm_convert_smf(model);

			models[? path] = {
				"model": model,
				"tempInstance": tempInstance,
				"icon": sMissingTexture,
				"type": "obj",
				"path": path,
				"name": name,
				"mBuff": mBuff,
				"cm": cm_list(),
			}
			
			cm_add_buffer(models[? path].cm, models[? path].mBuff, , matrix);
			break;
		}
		
		if (models[? path] == undefined){
			show_debug_message("couldnt load model - " + path);
			return noone;
		}
		
		assetBrowser.content[array_length(assetBrowser.content)] = models[? path];
		
		generate_model_icon(models[? path]);
	}
	
	return models[? path];
}