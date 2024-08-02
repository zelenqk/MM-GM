#macro darkGray #151515
#macro easeDarkGray #252525
#macro easyWhite #E2E2E2
#macro lightGray #505050
#macro paddingS 12
#macro paddingM 32
#macro paddingX 82

function initiate_ui(){
	
	switch (room){
	case rmMainMenu:
		//#MAIN MENU UI
		main = {
			"x": display_get_gui_width() / 2,
			"y": display_get_gui_height() / 2,
		}
		
		//Map list menu
		mainMenuHeader = {
			"text": "My maps",
			"height": display_get_gui_height() / 12,
			"width": display_get_gui_width() / 3,
		
		}
		mainMenuHeader.scale = mainMenuHeader.height / string_height(mainMenuHeader.text);
		
		mapListContainer = {
			"width": display_get_gui_width() / 3,
			"height": display_get_gui_height() - mainMenuHeader.height,
			"x": 0,
			"y": mainMenuHeader.height,
		}
		
		mapListContainerSegment = {
			"width": mapListContainer.width - (paddingS * 2),
			"height": (mapListContainer.height + paddingS) / 8 - paddingS,
		}
		
		mapListContainerSegment.nameScale = (mapListContainerSegment.height / 2) / string_height("NAME")
		mapListContainerSegment.pathScale = ((mapListContainerSegment.height / 2) / 2) / string_height("NAME")
		
		mapListContainerSlider = {
			"width": paddingM - paddingS,
			"height": mapListContainer.height - paddingS,
			"sliderY": 0,
			"deltaY": noone,
			"draw": !(mapListContainer.height > mapListContainerSegment.height * array_length(mapList)),
			"scale": clamp(map_value(mapListContainer.height - paddingS, 0, (mapListContainerSegment.height + paddingS) * array_length(mapList), 0, 1), 0, 1),
		}
		mapListContainerSegment.width -= paddingM * mapListContainerSlider.draw;
		
		//Map create menu
		mapCreateContainer = {
			"width": display_get_gui_width() / 4,
			"height": display_get_gui_height() / 2.5,
		}
		
		mapCreateContainer.x = mapListContainer.x + mapListContainer.width + paddingX;
		mapCreateContainer.y = display_get_gui_height() / 2 - (mapCreateContainer.height / 2);
		
		mapListContainerSlider.x = mapListContainer.x + mapListContainer.width - (paddingM);
		mapListContainerSlider.y = mapListContainer.y + paddingS / 2;
		
		var nameInput = {
			"name": "Map's name",
			"data": 0,
			"width": mapCreateContainer.width,
			"height": sprite_get_height(sBG) / 2,
			"preText": "My map",
		}
		
		instance_create_depth(mapCreateContainer.x, mapCreateContainer.y, -1, oInput, nameInput);
		
		var pathInput = {
			"name": "Map's path",
			"data": 1,
			"width": mapCreateContainer.width - 4 - sprite_get_height(sBG) / 2,
			"height": sprite_get_height(sBG) / 2,
			"preText": game_save_id,
		}
		
		instance_create_depth(mapCreateContainer.x, mapCreateContainer.y + nameInput.height * 1.75, -1, oInput, pathInput);
		
		var pathInputButton = {
			"sprite": sFileExplorer,
			"data": 0,
			"type": 1,
			"xscale": pathInput.height / sprite_get_height(sFileExplorer),
			"yscale": pathInput.height / sprite_get_height(sFileExplorer)
		}
		
		instance_create_depth(mapCreateContainer.x + pathInput.width + 4, mapCreateContainer.y + nameInput.height * 1.75, -1, oInput, pathInputButton);
		
		var mapCreateButton = {
			"data": 1,
			"type": 1,
			"text": "CREATE",
			"width": mapCreateContainer.width,
			"height": sprite_get_height(sFileExplorer) * 2.75,
			"scale": (sprite_get_height(sFileExplorer) * 2.75) / string_height("CREATE"),
		}
		
		instance_create_depth(mapCreateContainer.x, mapCreateContainer.y + nameInput.height * 3.5, -1, oInput, mapCreateButton);
		break;
	case rmEditor:
		//#MAP EDITOR UI
		gui = {
			"mx": 0,
			"my": 0,
		}
		
		inMouse = noone;
		
		//HEADER
		header = {
			"width": display_get_gui_width(),
			"height": display_get_gui_height() / 40 + paddingS,
			"x": 0,
			"y": 0,
			"message": noone,
			"halfSelected": noone,
			"selected": noone,
			"options": [{
				"name": "FILE",
				"options": [{
					"name": "Export map",
					"func": export_map,
				}, noone, {
					"name": "Import object",
					"func": import_model,
				}, noone, {
					"name": "Save map",
					"func": save_map,
				}]
			}]
		}
		header.scale = (header.height - paddingS) / string_height("A");
		
		for(var i = 0; i < array_length(header.options); i++){
			var option = header.options[i];
			option.width = 0;
			option.height = paddingS - paddingS / 4;
			
			for(var u = 0; u < array_length(option.options); u++){
				if (option.options[u] != noone){
					var width = string_width(option.options[u].name) * header.scale;
					
					if (width > option.width) option.width = width;
					option.height += string_height(option.options[u].name) * header.scale + paddingS / 2;
				}else{
					option.height += paddingS;	
				}
			}
		}
		
		//SIDEBAR
		sidebar = {
			"x": 0,
			"y": header.y + header.height,
			"width": display_get_gui_width() / 3,
			"height": display_get_gui_height() - header.height,
			"content": [],
		}
		
		//Side bar stuff
		modelViewer = {
			"x": paddingM,
			"y": paddingM + header.y + header.height,
			"width": sidebar.width - paddingM * 2,
			"height": sidebar.height / 7,
			"text": "",
			"icon": noone,
		}
		modelViewer.iconSize = modelViewer.height - paddingS
		modelViewer.textScale = (modelViewer.iconSize / 3) / string_height("A");
		modelViewer.textWidth = modelViewer.width - paddingS * 2 - modelViewer.iconSize;

		var fieldW = (sidebar.width - paddingM * 4) / 3; 
		var fieldH = sidebar.height / 24;
		
		//Position input fields
		var xField = {
			"x": sidebar.x + paddingM,
			"y": modelViewer.y + modelViewer.height + paddingM,
			"width": fieldW,
			"height": fieldH,
			"name": "x",
			"range": "0-9,.,-",
			"data": "x",
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(xField.x, xField.y, 0, oInput, xField));
		
		var yField = {
			"x": xField.x + xField.width + paddingM,
			"y": xField.y,
			"width": fieldW,
			"height": fieldH,
			"name": "y",
			"range": "0-9,.,-",
			"data": "y",
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(yField.x, yField.y, 0, oInput, yField));
		
		var zField = {
			"x": yField.x + yField.width + paddingM,
			"y": xField.y,
			"width": fieldW,
			"height": fieldH,
			"name": "z",
			"range": "0-9,.,-",
			"data": "z",
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(zField.x, zField.y, 0, oInput, zField));
		
		//scale input fields
		var xScaleField = {
			"x": xField.x,
			"y": xField.y + xField.height + paddingM,
			"width": fieldW,
			"height": fieldH,
			"name": "x scale",
			"range": "0-9,.,-",
			"data": "xScale",
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(xScaleField.x, xScaleField.y, 0, oInput, xScaleField));
		
		var yScaleField = {
			"x": xScaleField.x + xScaleField.width + paddingM,
			"y": xScaleField.y,
			"width": fieldW,
			"height": fieldH,
			"name": "y scale",
			"range": "0-9,.,-",
			"data": "yScale",
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(yScaleField.x, yScaleField.y, 0, oInput, yScaleField));
		
		var zScaleField = {
			"x": yScaleField.x + yScaleField.width + paddingM,
			"y": xScaleField.y,
			"width": fieldW,
			"height": fieldH,
			"name": "z scale",
			"range": "0-9,.,-",
			"data": "zScale",
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(zScaleField.x, zScaleField.y, 0, oInput, zScaleField));
		
		//Rotationation input fields
		var xRotField = {
			"x": xField.x,
			"y": xScaleField.y + xScaleField.height + paddingM,
			"width": fieldW,
			"height": fieldH,
			"name": "x Rotation",
			"range": "0-9,.,-",
			"data": "xRotation",
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(xRotField.x, xRotField.y, 0, oInput, xRotField));
		
		var yRotField = {
			"x": xRotField.x + xRotField.width + paddingM,
			"y": xRotField.y,
			"width": fieldW,
			"height": fieldH,
			"name": "y Rotation",
			"range": "0-9,.,-",
			"data": "yRotation",
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(yRotField.x, yRotField.y, 0, oInput, yRotField));
		
		var zRotField = {
			"x": yRotField.x + yRotField.width + paddingM,
			"y": yRotField.y,
			"width": fieldW,
			"height": fieldH,
			"name": "z Rotation",
			"range": "0-9,.,-",
			"data": "zRotation",
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(zRotField.x, zRotField.y, 0, oInput, zRotField));
		
		var varNameInput = {
			"x": xField.x,
			"y": yRotField.y + yRotField.height + paddingX,
			"width": fieldW,
			"height": fieldH,
			"name": "Variable name",
			"data": "varName",
			"event": false,
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(zRotField.x, zRotField.y, 0, oInput, varNameInput));
		
		var varValueInput = {
			"x": varNameInput.x + varNameInput.width + paddingM,
			"y": varNameInput.y,
			"width": fieldW,
			"height": fieldH,
			"name": "Variable value",
			"data": "varValue",
			"event": false,
			"visible": false,
		}
		array_push(sidebar.content, instance_create_depth(zRotField.x, zRotField.y, 0, oInput, varValueInput));
		
		var addVarBtn = {
			"type": 1,
			"x": varValueInput.x + varValueInput.width + paddingM,
			"y": varNameInput.y,
			"width": fieldW,
			"text": "Add var",
			"height": fieldH,
			"data": "varAddValue",
			"visible": false,
			
		}
		array_push(sidebar.content, instance_create_depth(addVarBtn.x, addVarBtn.y, 0, oInput, addVarBtn));
		
		customVarContainer = {
			"x": xField.x,
			"y": addVarBtn.y + addVarBtn.height + paddingS,
			"width": sidebar.width - paddingM * 2,
			"height": (display_get_gui_height() - (addVarBtn.y + addVarBtn.height + paddingS)) - paddingM,
			"surface": noone,
		}
		
		
		customVarContainer.varHeight = (customVarContainer.height / 8)
		customVarContainer.textScale = (customVarContainer.varHeight - paddingS / 2) / string_height("a");

		customVarContainer.nameWidth = (customVarContainer.width - paddingS * 2) / 3
		customVarContainer.valueWidth = (customVarContainer.width - paddingS * 3) - customVarContainer.nameWidth - customVarContainer.varHeight
		
		//ASSET BROWSER
		assetBrowser = {
			"x": sidebar.x + sidebar.width,
			"width": display_get_gui_width() - sidebar.width,
			"height": display_get_gui_height() / 3,
			"content": [],
		}
		assetBrowser.y = display_get_gui_height() - assetBrowser.height;
		assetBrowser.slotSize = (assetBrowser.height - paddingM) / 3;
		
		assetBrowser.textScale = (assetBrowser.slotSize / 5) / string_height("|");
		
		var assetBrowserSearchField = {
			"width": assetBrowser.width,
			"height": assetBrowser.height / 8,
			"data": "search",
			"preText": "Search for asset",
		}
		
		instance_create_depth(assetBrowser.x, assetBrowser.y, 0, oInput, assetBrowserSearchField);
		
		//EDITOR 3D VIEW
		view = {
			"x": sidebar.x + sidebar.width,
			"y": header.y + header.height,
			"width": display_get_gui_width() - sidebar.width,
			"height": sidebar.height - assetBrowser.height,
			"camX": 0,
			"camY": 0,
			"camZ": 32,
			"lookDir": 45,
			"lookPitch": 0,
			"enabled": false,
			"spd": 4,
		}
		
		view_visible[0] = true;
		
		view_wport[0] = view.width
		view_hport[0] = view.height
		
		//create camera
		camera_set_view_mat(view_camera[0], matrix_build_lookat(view.camX, view.camY, view.camZ, view.camX - dcos(view.lookDir) * dcos(view.lookPitch), view.camY - dsin(view.lookDir) * dcos(view.lookPitch), view.camZ, 0, 0, -1));
		camera_set_proj_mat(view_camera[0], matrix_build_projection_perspective_fov(60, display_get_gui_width() / display_get_gui_height(), 1, -1));
		camera_apply(view_camera[0]);
		
		view_surface_id[0] = surface_create_c(view.width, view.height);
		
		assetBrowser.y += assetBrowserSearchField.height;
		assetBrowser.height -= assetBrowserSearchField.height;
		
		//LOAD PRIMITIVE 3D OBJECTS
		var file = file_find_first("PRIMITIVES/*", fa_none);
		
		while (file != ""){
			load_model("PRIMITIVES/" + file);
			
			var file = file_find_next();
		}
		
		//Load gizmos
		editor.gizmos = {
			"lock": noone,
			"type": "pos",
			"pos": {
				"base": {
					"smf": smf_model_load("EDITOR/arrow.obj"),
					"col": cm_load_obj("EDITOR/arrow.obj"),
					"cm": cm_list(),
				}
			},
			"scale": {
				"base": {
					"smf": smf_model_load("EDITOR/scaler.obj"),
					"col": cm_load_obj("EDITOR/scaler.obj"),
					"cm": cm_list(),
				}
			},
			"rotation": {
				"base": {
					"smf": smf_model_load("EDITOR/torus.obj"),
					"col": cm_load_obj("EDITOR/torus.obj"),
					"cm": cm_list(),
				}
			}
		}
		
		editor.gizmos.pos.base.model = new smf_instance(editor.gizmos.pos.base.smf);
		
		var xMat = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, -1);
		var yMat = matrix_build(0, 0, 0, 0, 0, 90, 1, 1, -1);
		var zMat = matrix_build(0, 0, 0, 0, 270, 0, 1, 1, -1);
		
		editor.gizmos.pos.x = cm_add(editor.gizmos.pos.base.cm, cm_dynamic(editor.gizmos.pos.base.col, xMat, true, CM_GROUP_SOLID));
		editor.gizmos.pos.y = cm_add(editor.gizmos.pos.base.cm, cm_dynamic(editor.gizmos.pos.base.col, yMat, true, CM_GROUP_SOLID));
		editor.gizmos.pos.z = cm_add(editor.gizmos.pos.base.cm, cm_dynamic(editor.gizmos.pos.base.col, zMat, true, CM_GROUP_SOLID));
		
		cm_custom_parameter_set(editor.gizmos.pos.x, "x");
		cm_custom_parameter_set(editor.gizmos.pos.y, "y");
		cm_custom_parameter_set(editor.gizmos.pos.z, "z");
		
		editor.gizmos.scale.base.model = new smf_instance(editor.gizmos.scale.base.smf);
		
		var xMat = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, -1);
		var yMat = matrix_build(0, 0, 0, 0, 0, 90, 1, 1, -1);
		var zMat = matrix_build(0, 0, 0, 0, 270, 0, 1, 1, -1);
		
		editor.gizmos.scale.x = cm_add(editor.gizmos.scale.base.cm, cm_dynamic(editor.gizmos.scale.base.col, xMat, true, CM_GROUP_SOLID));
		editor.gizmos.scale.y = cm_add(editor.gizmos.scale.base.cm, cm_dynamic(editor.gizmos.scale.base.col, yMat, true, CM_GROUP_SOLID));
		editor.gizmos.scale.z = cm_add(editor.gizmos.scale.base.cm, cm_dynamic(editor.gizmos.scale.base.col, zMat, true, CM_GROUP_SOLID));
		
		cm_custom_parameter_set(editor.gizmos.scale.x, "x");
		cm_custom_parameter_set(editor.gizmos.scale.y, "y");
		cm_custom_parameter_set(editor.gizmos.scale.z, "z");
		
		editor.gizmos.rotation.base.model = new smf_instance(editor.gizmos.rotation.base.smf);
		
		var xMat = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, -1);
		var yMat = matrix_build(0, 0, 0, 0, 0, 90, 1, 1, -1);
		var zMat = matrix_build(0, 0, 0, 0, 270, 0, 1, 1, -1);
		
		editor.gizmos.rotation.x = cm_add(editor.gizmos.rotation.base.cm, cm_dynamic(editor.gizmos.rotation.base.col, xMat, true, CM_GROUP_SOLID));
		editor.gizmos.rotation.y = cm_add(editor.gizmos.rotation.base.cm, cm_dynamic(editor.gizmos.rotation.base.col, yMat, true, CM_GROUP_SOLID));
		editor.gizmos.rotation.z = cm_add(editor.gizmos.rotation.base.cm, cm_dynamic(editor.gizmos.rotation.base.col, zMat, true, CM_GROUP_SOLID));
		
		cm_custom_parameter_set(editor.gizmos.rotation.x, "x");
		cm_custom_parameter_set(editor.gizmos.rotation.y, "y");
		cm_custom_parameter_set(editor.gizmos.rotation.z, "z");
	}
}