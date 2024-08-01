globalvar models;
models = ds_map_create();

function load_model(path = noone){
	if (path == noone) path = get_open_filename("models|*.obj;*.smf*", "");
	if (path == "") return;
	
	var name = string_split(path, "\\", true);
	name = name[array_length(name) - 1];
	
	var name = string_split(name, "/", true);
	name = name[array_length(name) - 1];
	
	if (!ds_map_exists(models, path)){
		var type = string_split(path, ".");
		type = string_lower(type[array_length(type) - 1]);
		
		switch(type){
		case "smf":
			var model = smf_model_load(path);
			if (model = -1) return noone;
			
			var tempInstance = new smf_instance(model);
			
			models[? path] = {
				"model": model,
				"tempInstance": tempInstance,
				"icon": sMissingTexture,
				"type": "smf",
				"path": path,
				"name": name,
				"cm": cm_list(),
			}
			
			cm_add_smf(models[? path].cm, model);
			
			assetBrowser.content[array_length(assetBrowser.content)] = models[? path];
			break;
		case "obj":
			var model = smf_model_load_obj(path);
			if (model = -1) return noone;
			
			var tempInstance = new smf_instance(model);
			
			models[? path] = {
				"model": model,
				"tempInstance": tempInstance,
				"icon": sMissingTexture,
				"type": "obj",
				"path": path,
				"name": name,
				"cm": cm_load_obj(path),
			}
			
			assetBrowser.content[array_length(assetBrowser.content)] = models[? path];
			break;
		}
	}
	
	return models[? path];
}