function draw_text_input(){
	draw_set_color(c_black);
	draw_set_alpha(0.4);
	draw_rectangle(x, y, x + width, y + height, 0);
	draw_set_alpha(1);
	draw_set_color(c_white);
	
	var pir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), x, y, x + width, y + height);
	
	if (pir){
		window_set_cursor(cr_beam);
		
		if (mouse_check_button_pressed(mb_left)){
			selected = true;
			cursor = "|"
		}
	}
	
	draw_set_valign(fa_bottom);
	if (name != noone) draw_text_transformed(x, y, name, scale / 1.5, scale / 1.5, 0);
	draw_set_valign(fa_top);
	
	if (surface_exists(surface)){
		surface_set_target(surface){
			draw_clear_alpha(c_black, 0);
			
			if (text != "" or selected) draw_text_transformed(0, 0, text + cursor, scale, scale, 0);
			else if (preText != noone){
				draw_set_alpha(0.4);
				draw_text_transformed(0, 0, preText, scale, scale, 0);
				draw_set_alpha(1);
			}
			
			surface_reset_target()
			
			draw_surface(surface, x, y);
		}
	}else if (window_has_focus()){
		if (surface != undefined) surface_free(surface);
		surface = surface_create_c(width, height);
	}
	
	if (selected){
		timer -= delta;
		
		if (timer <= 0){
			cursor = toggle_cursor(cursor);
			timer = cursorTimer;
		}
		
		if (keyboard_check_pressed(ord("V")) and keyboard_check(vk_control) and allowPaste){
				text = string_insert(clipboard_get_text(), text, string_length(text) + 1);
				
				cursor = cursorOn;
				timer = cursorTimer;
				keyboard_lastchar = "";
		}
		
		if ((keyboard_check_pressed(vk_anykey) or keyboard_check(vk_anykey))){
			if (is_in_range(keyboard_lastchar, range)){
				
				text = string_insert(keyboard_lastchar, text, string_length(text) + 1);
				
				cursor = cursorOn;
				timer = cursorTimer;
				keyboard_lastchar = "";
			}else{
				switch(keyboard_lastkey){
				case vk_backspace:
					text = string_delete(text, string_length(text), 1);
					
					cursor = cursorOn;
					timer = cursorTimer;
					break;
				case vk_enter:
					self.selected = false;
					
					if (event == 1){
						var map = ds_map_create();
						map[? "id"] = id;
						map[? "text"] = text;
						map[? "data"] = data;
						map[? "type"] = type;
						
						event_perform_async(ev_async_dialog, map);
					}
					break;
				}
				
				keyboard_lastkey = vk_nokey;
			}	
		}
	}
	
	
}