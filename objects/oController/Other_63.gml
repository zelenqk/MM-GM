var type = async_load[? "type"];

switch (type){
case 0:	//TEXT INPUT
	var data = async_load[? "data"];
	
	if (room == rmEditor){
		switch (data){
		case "search":
		
			break;
		default:
			if (editor.selected == noone) exit;
			
			var input = get_input(0, data);
			var value = input.text
			
			try{
				value = real(value);	
			}catch(e){
				show_debug_message("couldnt set data to object");
				exit;
			}
				
			if (variable_struct_get(editor.selected, data) != value){
				insert_action("modelUpdate", editor.selected, data, variable_struct_get(editor.selected, data));	

				variable_struct_set(editor.selected, data, value);
				
				update_model(editor.selected);
				
			}
			break;
		}
	}
	break;
case 1:	//BUTTONS
	var data = async_load[? "data"];
	
	if (room == rmMainMenu){
		switch (data){
		case 0:	//GET SAVE FILE PATH
			var nameInput = get_input(0, 0);
			var pathInput = get_input(0, 1);
			
			pathInput.text = get_save_filename("", (nameInput.text == "") ? "My map" : nameInput.text);
			if ((pathInput.text) == "") exit;
			
			pathInput.text = string_split(pathInput.text, "\\", true);
			pathInput.text = string_join_ext("\\", pathInput.text, 0, array_length(pathInput.text) - 1);
			break;
		case 1:	//CREATE A MAP
			var nameInput = get_input(0, 0);
			var pathInput = get_input(0, 1);
			
			var mapFdir = (!(string_ends_with(pathInput.text, "\\") or string_ends_with(pathInput.text, "/"))) ? pathInput.text + "\\" + nameInput.text : pathInput.text + nameInput.text;
			
			if (file_exists(mapFdir)){
				if (!show_question("A map with the same name exists in this directory. Do you want to overwrite it?")) exit;
			}
			
			var index = array_length(mapList);
			mapList[index] = {
				"name": nameInput.text,
				"path": pathInput.text + "\\" + nameInput.text,
			}
			
			var mapListF = file_text_open_write(mapListFname);
			file_text_write_string(mapListF, json_stringify(mapList));
			file_text_close(mapListF);
			
			directory_create(mapFdir);
			
			projectPath = mapFdir;
			
			var mapDataF = file_text_open_write(mapFdir + "/data.json");
			var mapData = {
				"models": [],
				"objects": [],
			}
			
			file_text_write_string(mapDataF, json_stringify(mapData));
			file_text_close(mapDataF);
			
			room = rmEditor;
			break;
		}
	}else{
		switch (data){
		case "varAddValue":
			var name = get_input(0, "varName").text;
			var value = get_input(0, "varValue").text;
			
			try{	//its a number
				value = real(value);	
			}catch(e){	//its a string
				value = string(value);
			}
			
			var variable = {
				"name": name,
				"shortName": string_copy_width(name, customVarContainer.nameWidth, customVarContainer.textScale),
				"value": value,
				"shortVal": string_copy_width(value, customVarContainer.valueWidth - (string_width("\"") * 2) * customVarContainer.textScale, customVarContainer.textScale),
			}
			
			if (is_string(value)){
				variable.shortVal = "\"" + variable.shortVal + "\"";
			}
			
			try{
				editor.selected.customVariables[array_length(editor.selected.customVariables)] = variable;
			}catch(e){
				show_debug_message(e);
			}
			
			break;
		}
	}
	break;
}

ds_map_destroy(async_load);
