if (room == rmEditor){
	if (viewPir){
		if (inMouse != noone){
			var ray = raycast(editor.level, 10);
			
			shader_set(sh_smf_static);
			
			matrix_set(matrix_world, matrix_build(cm_ray_get_x(ray), cm_ray_get_y(ray), cm_ray_get_z(ray), 270, 0, 0, 1, 1, -1));
			inMouse.tempInstance.draw();
			matrix_set(matrix_world, matrix_build_identity());
			
			shader_reset();
			
			if (mouse_check_button_released(mb_left)){
				instance_create_depth(cm_ray_get_x(ray), cm_ray_get_y(ray), -1, oModel, {"z": cm_ray_get_z(ray), "model": inMouse.path});
				
				inMouse = noone;
			}
		}
	}
}
