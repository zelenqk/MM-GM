// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function generate_model_icon(model){
	if (!surface_exists(iconSurface)) iconSurface = surface_create(128, 128);
	
	surface_set_target(iconSurface){
		draw_clear_alpha(c_black, 0);
		
		matrix_set(matrix_view, matrix_build_lookat(2.25, 2.25, -2.25, 0, 0, 0, 0, 0, -1));
		matrix_set(matrix_projection, matrix_build_projection_perspective_fov(60, 128 / 128, 1, -1));
		
		var bbox = cm_get_aabb(model.cm);
		
		var aabbMap = map_aab(iconAABB, bbox);
		
		shader_set(sh_smf_static);

		// Draw the instance
		modelMat = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, -1);
		
		matrix_set(matrix_world, modelMat);
		model.tempInstance.draw();
		matrix_set(matrix_world, matrix_build_identity());
		
		// Reset the shader
		shader_reset();
		
		try{
			model.icon = sprite_create_from_surface(iconSurface, 0, 0, 128, 128, true, false, 0, 0);
			//surface_save(iconSurface, "D:\\GMSP\\MM-GM\\datafiles\\PRIMITIVES\\" + model.name + ".png");

			show_debug_message("succesfully generated icon for model - " + model.name);
		}catch(e){
			model.icon = sMissingTexture;
			show_debug_message(e);
		}
		
		surface_reset_target();
		
		surface_free(iconSurface);
		
	}	
}