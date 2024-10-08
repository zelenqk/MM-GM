while (array_length(surfaces) > 1){
	if (surface_exists(surfaces[0])) surface_free(surfaces[0]);	
	array_delete(surfaces, 0, 1);
}

var modelNames = ds_map_keys_to_array(models);
for(var i = 0; i < array_length(modelNames); i++){
	var model = models[? modelNames[i]];
	
	if (model.icon != sMissingTexture) sprite_delete(model.icon);
	
	smf_model_destroy(model.model, true);
	
	buffer_delete(model.mBuff)
}

ds_map_destroy(models)