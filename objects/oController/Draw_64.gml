switch (room){
case rmMainMenu:
	draw_map_list();
	break;
case rmEditor:
	draw_editor();
	
	if (editor.selected != noone) draw_sidebar();
	
	draw_assetbrowser();
	
	draw_header();
	
	if (inMouse != noone){
		if (!viewPir) draw_sprite_stretched(inMouse.icon, 0, device_mouse_x_to_gui(0) - inMouse.xDelta, device_mouse_y_to_gui(0) - inMouse.yDelta, inMouse.iconSize, inMouse.iconSize);
		
		if (mouse_check_button_released(mb_left)){
			inMouse = noone;	
		}
	}
	
	break;
}