// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_editor(){
	if (mouse_check_button_pressed(mb_right) and point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), view.x, view.y, view.x + view.width, view.y + view.height)){
        view.enabled = true;
        window_mouse_set_locked(true);
    }
	
	if (mouse_check_button_released(mb_right)){
		view.enabled = false;
        window_mouse_set_locked(false);
	}
	
	view.spd += (keyboard_check(vk_up) - keyboard_check(vk_down) * delta) / 10;
	
	if (view.enabled){
		view.lookDir -= window_mouse_get_delta_x() / 10;
		view.lookDir = (view.lookDir % 360);
		
        view.lookPitch -= window_mouse_get_delta_y() / 10;
        view.lookPitch = clamp(view.lookPitch, -90, 90);
        
		view.spd += (mouse_wheel_up() - mouse_wheel_down()) * delta;
		view.spd = clamp(view.spd, 0, view.spd + 1)
		
		var forwardX = dcos(view.lookDir);
		var forwardY = dsin(view.lookDir);
		var forwardZ = dsin(view.lookPitch);
		
		var rightX = dcos(view.lookDir + 90);
		var rightY = dsin(view.lookDir + 90);
		
        var strafeSpeed = view.spd * (keyboard_check(ord("A")) - keyboard_check(ord("D")));
        var moveSpeed = view.spd * (keyboard_check(ord("S")) - keyboard_check(ord("W"))) * (!keyboard_check(vk_control));
        var elevateSpeed = view.spd * (keyboard_check(vk_space) - keyboard_check(vk_shift));
        
		// Apply movement based on calculated vectors
        view.camX += (moveSpeed * forwardX - strafeSpeed * rightX) * delta;
        view.camY += (moveSpeed * forwardY - strafeSpeed * rightY) * delta;
        view.camZ += (elevateSpeed) * delta;
		
		var xTo = view.camX - forwardX * dcos(view.lookPitch);
		var yTo = view.camY - forwardY * dcos(view.lookPitch);
		var zTo = view.camZ + forwardZ;
		
		var salting = (view.lookPitch <= -90) - (view.lookPitch >= 90);
		
		upX = dcos(view.lookDir) * salting;
		upY = dsin(view.lookDir) * salting;
		upZ = -1;
		
		camera_set_view_mat(view_camera[0], matrix_build_lookat(view.camX, view.camY, view.camZ, xTo, yTo, zTo, upX, upY, upZ));
	}
	
	if (surface_exists(view_surface_id[0])){
		
		if (!surface_exists(editor.surface) and window_has_focus()) editor.surface = surface_create_c(view.width, view.height);
		if (!surface_exists(editor.selectedSurf) and window_has_focus()) editor.selectedSurf = surface_create_c(view.width, view.height);

		surface_set_target(editor.surface){
			matrix_set(matrix_view, camera_get_view_mat(view_camera[0]));
			matrix_set(matrix_projection, camera_get_proj_mat(view_camera[0]));
			
			draw_clear_alpha(c_black, 0);
			
			if (array_length(editor.selected) > 0) draw_editor_gizmos();
			
			surface_reset_target();
		}
		
		surface_set_target(editor.selectedSurf){
			matrix_set(matrix_view, camera_get_view_mat(view_camera[0]));
			matrix_set(matrix_projection, camera_get_proj_mat(view_camera[0]));
			
			draw_clear_alpha(c_black, 0);
			
			for(var j = 0; j < array_length(editor.selected); j++){
				var selMdl = editor.selected[j];
				
				with (selMdl){
					// Before drawing your SMF object, set the texture size as a uniform
					shader_set(sh_smf_static);
					
					// Draw the instance
					modelMat = matrix_build(x, y, z, xRotation, yRotation, zRotation, xScale, yScale, -zScale);
					
					matrix_set(matrix_world, modelMat);
					model.tempInstance.draw();
					matrix_set(matrix_world, matrix_build_identity());
					
					shader_reset();
				}
			}
			
			surface_reset_target();
		}
		
		// Draw the main surface first (if needed)
		draw_surface(view_surface_id[0], view.x, view.y);
		
		// Check if the selected surface exists and is valid
		if (surface_exists(editor.selectedSurf) and editor.selected != noone) {
		    shader_set(shdSobel);
		    shader_set_uniform_f(shader_get_uniform(shdSobel, "texSize"), surface_get_width(editor.selectedSurf), surface_get_height(editor.selectedSurf));
		    
		    draw_surface(editor.selectedSurf, view.x, view.y);
			
		    shader_reset();
		}
		
		if (surface_exists(editor.surface) and editor.selected != noone) draw_surface(editor.surface, view.x, view.y);
	}else if (window_has_focus()){
		view_surface_id[0] = surface_create_c(view.width, view.height);
	}
}