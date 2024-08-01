var pir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), x, y, x + width, y + height);

if (!pir){
	window_set_cursor(cr_arrow);

	if (mouse_check_button_pressed(mb_left) and selected){
		
		if (event){
			var map = ds_map_create();
			map[? "id"] = id;
			map[? "text"] = text;
			map[? "data"] = data;
			map[? "type"] = type;
			
			event_perform_async(ev_async_dialog, map);
		}
		
		selected = false;
	
		cursor = cursorOff;
		timer = cursorTimer;
	}
}