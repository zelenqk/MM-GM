delta = (delta_time / 1000000) / targetDelta;

if (room = rmEditor){
	viewPir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), view.x, view.y, view.x + view.width, view.y + view.height)
	
	if (keyboard_check_pressed(ord("S")) and keyboard_check(vk_control)) save_map();
	if (keyboard_check_pressed(ord("Z")) and keyboard_check(vk_control)) undo();
	if (keyboard_check_pressed(ord("Y")) and keyboard_check(vk_control)) redo();
	if (keyboard_check_pressed(ord("C")) and keyboard_check(vk_control)) copy();
	if (keyboard_check_pressed(ord("V")) and keyboard_check(vk_control)) paste();

	if (keyboard_check_pressed(vk_delete) and array_length(editor.selected) > 0){
		instance_destroy(editor.selected[0]);
		editor.selected = [];
		
		for(var i = 0; i < array_length(sidebar.content); i++){
			sidebar.content[i].visible = (array_length(editor.selected) > 0);
		}
	}

	if (viewPir and view.enabled == false){
		if (mouse_check_button_pressed(mb_left)){
			var object = 0;
			
			if (array_length(editor.selected) > 0){
				var type = variable_struct_get(editor.gizmos, editor.gizmos.type);
				var ray = raycast(type.base.cm);
				
				var object = cm_ray_get_hit_object(ray);
				if (object != 0){
					editor.gizmos.lock = [				
						cm_custom_parameter_get(object),
						cm_ray_get_x(ray),
						cm_ray_get_y(ray),
						cm_ray_get_z(ray),
					];
					
					//undo(); stuff
					var variable = editor.gizmos.lock[0] + (editor.gizmos.type != "pos" ? string_upper(string_copy(editor.gizmos.type, 1, 1)) + string_copy(editor.gizmos.type, 2, string_length(editor.gizmos.type) - 1) : "");
					
					insert_action("modelUpdate", editor.selected[0], variable, variable_struct_get(editor.selected[0], variable));
				}
			}
			
			if (object == 0){
				var ray = raycast(editor.level);
				
				var object = cm_ray_get_hit_object(ray);
				
				if (object != 0){
					object = cm_custom_parameter_get(object);
					editor.selected = [];
					editor.selected[array_length(editor.selected)]= object.id;
					editor.gizmos.type = "pos";
				}else{
					editor.selected = [];
				}
				
				for(var i = 0; i < array_length(sidebar.content); i++){
					sidebar.content[i].visible = (array_length(editor.selected) > 0);
					
					if (array_length(editor.selected) > 0 and variable_struct_exists(editor.selected[0], sidebar.content[i].data)) sidebar.content[i].text = string(variable_struct_get(editor.selected[0], sidebar.content[i].data));
				}
			}
		}
	}
	
	
	if (editor.gizmos.lock != noone and (array_length(editor.selected) > 0)){
		for(var j = 0; j < array_length(editor.selected); j++){
		var selMdl = editor.selected[j];
		var type = variable_struct_get(editor.gizmos, editor.gizmos.type);
		
		var ray = raycast_lock(cm_list(), 
			editor.gizmos.lock[0] == "x" ? noone : editor.gizmos.lock[1],	//lock X
			editor.gizmos.lock[0] == "y" ? noone : editor.gizmos.lock[2],	//lock Y
			editor.gizmos.lock[0] == "z" ? noone : editor.gizmos.lock[3],	//lock Z
			1000
		)
		
		var newX = cm_ray_get_x(ray);
		var newY = cm_ray_get_y(ray);
		var newZ = cm_ray_get_z(ray);

		if (mouse_check_button_pressed(mb_left)){
			switch (editor.gizmos.lock[0]) {
			case "x":
				editor.gizmos.lock[1] = newX;
				break;
			case "y":
				editor.gizmos.lock[2] = newY;
				break;
			case "z":
				editor.gizmos.lock[3] = newZ;
				break;
			}	
		}

		switch (editor.gizmos.lock[0]) {
		case "x":
			if (editor.gizmos.type == "pos") selMdl.x += (newX - editor.gizmos.lock[1]) / 100;
			if (editor.gizmos.type == "scale") selMdl.xScale += (newX - editor.gizmos.lock[1]) / 100;
			if (editor.gizmos.type == "rotation") selMdl.xRotation -= window_mouse_get_delta_x();
			
			editor.gizmos.lock[1] = newX;
			break;
		case "y":
			if (editor.gizmos.type == "pos") selMdl.y += (newY - editor.gizmos.lock[2]) / 100;
			if (editor.gizmos.type == "scale") selMdl.yScale += (newY - editor.gizmos.lock[2]) / 100;
			if (editor.gizmos.type == "rotation") selMdl.yRotation -= window_mouse_get_delta_x();
			
			editor.gizmos.lock[2] = newY;
			break;
		case "z":
			if (editor.gizmos.type == "pos") selMdl.z += (newZ - editor.gizmos.lock[3]) / 100;
			if (editor.gizmos.type == "scale") selMdl.zScale += (newZ - editor.gizmos.lock[3]) / 100;
			if (editor.gizmos.type == "rotation") selMdl.zRotation -= window_mouse_get_delta_x();
			
			editor.gizmos.lock[3] = newZ;
			break;
		}
		
		//UPDATE TEXT INPUT BOXES
		for(var i = 0; i < array_length(sidebar.content); i++){
			if (variable_struct_exists(selMdl, sidebar.content[i].data)) sidebar.content[i].text = string(variable_struct_get(selMdl, sidebar.content[i].data));
		}
		
		lock_mouse();
		}
	}
	
	if (mouse_check_button_released(mb_left)){
		if (editor.gizmos.lock != noone and array_length(editor.selected) > 0){
			
			if (array_length(editor.undo) > 0 and editor.undo[0].oldValue == variable_struct_get(editor.undo[0].model, editor.undo[0].variable)){
				array_delete(editor.undo, 0, 1);
				editor.saved = true;
			}
			
			for(var j = 0; j < array_length(editor.selected); j++){
				var selMdl = editor.selected[j];
				update_model(selMdl);
			}
			
			editor.gizmos.lock = noone;
			
			gui.mx = 0;
			gui.my = 0;
		}
	}
}