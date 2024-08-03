function export_map(){
    save_map();
    
    var path = get_save_filename(".zip", "");    
    
    var zip = zip_create();
    
    var objects = [];
    var modelsArr = [];
    
    var modelNames = ds_map_create();
    var modelsKeys = ds_map_keys_to_array(models);
    
    // First, let's create the models array
    for (var i = 0; i < array_length(modelsKeys); i++){
        var modelKey = modelsKeys[i];
        var model = models[? modelKey];
        
        var u = 0;
        var next = "";
        
        while (ds_map_exists(modelNames, model.name)){
            u++;
            next = " (" + string(u) + ")";
        }
        
        var filenamePath = string_replace(filename_name(model.path), filename_ext(model.path), "");
        filenamePath = filename_path(model.path) + "\\" + filenamePath;
        
        var modelName = string_replace(model.name, filename_ext(model.name), "");
        
        zip_add_file(zip, "models\\" + modelName + next + "\\" + modelName + filename_ext(model.name), model.path);
        if file_exists(filenamePath + ".mtl") zip_add_file(zip, "models\\" + modelName + next + "\\" + modelName + ".mtl", filenamePath + ".mtl");
        if file_exists(filenamePath + ".png") zip_add_file(zip, "models\\" + modelName + next + "\\" + modelName + ".png", filenamePath + ".png");
        if file_exists(filenamePath + ".jpg") zip_add_file(zip, "models\\" + modelName + next + "\\" + modelName + ".jpg", filenamePath + ".jpg");
        if file_exists(filenamePath + ".jpeg") zip_add_file(zip, "models\\" + modelName + next + "\\" + modelName + ".jpeg", filenamePath + ".jpg");
        
        modelNames[? model.path] = array_length(modelsArr); // Store index in the models array
        modelsArr[array_length(modelsArr)] = {
            "name": model.name,
            "path": "models\\" + modelName + next
        };
    }
    
    // Now process the objects
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
        };
        
        for(var u = 0; u < array_length(customVariables); u++){
            variable_struct_set(object.customVariables, customVariables[u].name, customVariables[u].value);
        }
        
        if (ds_map_exists(modelNames, self.model.path)){
            object.model = modelNames[? self.model.path]; // Store model's index
        }
        
        objects[array_length(objects)] = object;
    }
    
    // Create the final JSON structure
    var data = {
        "models": modelsArr,
        "objects": objects
    };
    
    var dataFile = file_text_open_write("temp");
    file_text_write_string(dataFile, json_stringify(data));
    file_text_close(dataFile);
    
    zip_add_file(zip, "data.json", "temp");
    
    var ext = filename_ext(path) == ".zip" ? "" : ".zip";
    
    zip_save(zip, path + ext);
}
