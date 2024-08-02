// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_sidebar(){
	//draw_rectangle(sidebar.x, sidebar.y, sidebar.x + sidebar.width, sidebar.y + sidebar.height, 1);
	draw_rectangle(modelViewer.x, modelViewer.y, modelViewer.x + modelViewer.width, modelViewer.y + modelViewer.height, 1);
	
	var localPadding = (modelViewer.height - modelViewer.iconSize) / 2;
	
	draw_sprite_stretched(editor.selected.model.icon, 0, modelViewer.x + localPadding, modelViewer.y + localPadding, modelViewer.iconSize, modelViewer.iconSize);

	draw_text_transformed(modelViewer.x + localPadding * 2 + modelViewer.iconSize, modelViewer.y + localPadding, editor.selected.model.name, modelViewer.textScale, modelViewer.textScale, 0);

	draw_rectangle(customVarContainer.x, customVarContainer.y, customVarContainer.x + customVarContainer.width, customVarContainer.y + customVarContainer.height, 1);
	
	if (surface_exists(customVarContainer.surface)){
		surface_set_target(customVarContainer.surface){
			draw_clear_alpha(c_black, 0);
			var tx = paddingS;
			var ty = paddingS;
			
			var vars = editor.selected.customVariables
			
			for(var i = 0; i < array_length(vars); i++){
				draw_sprite_stretched_ext(sBG, 0, tx, ty, customVarContainer.nameWidth, customVarContainer.varHeight, easeDarkGray, 1)
				draw_sprite_stretched_ext(sBG, 0, tx + paddingS + customVarContainer.nameWidth, ty, customVarContainer.valueWidth, customVarContainer.varHeight, easeDarkGray, 1)
				
				draw_text_transformed(tx, ty + paddingS / 4, vars[i].shortName, customVarContainer.textScale, customVarContainer.textScale, 0);
				draw_text_transformed(tx + paddingS + customVarContainer.nameWidth, ty + paddingS / 4, vars[i].shortVal, customVarContainer.textScale, customVarContainer.textScale, 0);
				
				var delPir = point_in_rectangle(device_mouse_x_to_gui(0) - customVarContainer.x, device_mouse_y_to_gui(0) - customVarContainer.y, tx + paddingS * 2 + customVarContainer.nameWidth + customVarContainer.valueWidth, ty, tx + paddingS * 2 + customVarContainer.nameWidth + customVarContainer.valueWidth + customVarContainer.varHeight, ty + customVarContainer.varHeight);
				if (mouse_check_button_pressed(mb_left) and delPir){
					array_delete(vars, i, 1);	
				}
				
				draw_sprite_stretched_ext(sBin, delPir, tx + paddingS * 2 + customVarContainer.nameWidth + customVarContainer.valueWidth, ty, customVarContainer.varHeight, customVarContainer.varHeight, easyWhite, 1)
				
				ty += customVarContainer.varHeight + paddingS;
			}
			
			surface_reset_target();
			draw_surface(customVarContainer.surface, customVarContainer.x, customVarContainer.y)
		}
	}else if (window_has_focus()){
		customVarContainer.surface = surface_create_c(customVarContainer.width, customVarContainer.height);
	}

}