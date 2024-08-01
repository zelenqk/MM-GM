switch (room){
case rmMainMenu:
	mapList = [];
	
	if (file_exists(mapListFname)){
		var mapListF = file_text_open_read(mapListFname);
		mapList = file_text_read_string(mapListF);
		mapList = json_parse(mapList);
		file_text_close(mapListF);
	}else{
		var mapListF = file_text_open_write(mapListFname);
		file_text_write_string(mapListF, json_stringify(mapList));
		file_text_close(mapListF);
	}
	
	initiate_ui();
	
	for(var i = 0 ; i < array_length(mapList); i++){
		var map = mapList[i];
		
		map.nameShort = (string_width(map.name) * mapListContainerSegment.nameScale > mapListContainerSegment.width - 8) ? (string_copy_width(map.name, mapListContainerSegment.width - 8 - string_width("...") * mapListContainerSegment.nameScale, mapListContainerSegment.nameScale) + "...") : map.name;
		map.pathShort = (string_width(map.path) * mapListContainerSegment.pathScale > mapListContainerSegment.width - 8) ? (string_copy_width(map.path, mapListContainerSegment.width - 8 - string_width("...") * mapListContainerSegment.pathScale, mapListContainerSegment.pathScale) + "...") : map.path;
		
		mapList[i] = map;
	}
	
	break;
case rmEditor:
	viewPir = false;
	
	editor = {
		"selected": noone,
		"level": cm_octree(128),
		"saved": true,
		"undo": [],
		"redo": [],
		"viewCam": {
			"x": 0,
			"y": 0,
			"z": 0,
			"lookPitch": 0,
			"lookDir": 0,
			"view": 0
		},
	}
	
	initiate_ui();

	var mapDataF = file_text_open_read(projectPath + "/data.json");
	var mapData = json_parse(file_text_read_string(mapDataF));
	file_text_close(mapDataF);
	
	for(var i = 0; i < array_length(mapData.models); i++){
		var model = mapData.models[i];
		
		load_model(model);
	}
	
	for(var i = 0; i < array_length(mapData.objects); i++){
		var object = mapData.objects[i];
		
		instance_create_depth(object.x, object.y, -1, oModel, object);
	}

	window_set_cursor(cr_arrow);
	break;
}