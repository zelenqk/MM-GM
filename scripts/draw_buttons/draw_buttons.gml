// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_buttons(){
	var pir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), x, y, x + width, y + height);
	
	if (pir){
		window_set_cursor(cr_handpoint);
	
		if(mouse_check_button_pressed(mb_left)){
			var map = ds_map_create();
			map[? "type"] = type;
			map[? "data"] = data;
			
			event_perform_async(ev_dialog_async, map);
		}
	}
	
	if (sprite != noone) draw_sprite_ext(sprite, 0, x, y, xscale, yscale, 0, c_white, 1);
	else{
		draw_set_color(c_black);
		draw_set_alpha(0.4);
		draw_rectangle(x, y, x + width, y + height, false);
		draw_set_color(easyWhite);
		draw_set_alpha(1);
		
		draw_set_halign(fa_center);
		draw_set_valign(fa_center);
		draw_text_transformed(x + width / 2, y + height / 2, text, scale, scale, 0);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		draw_set_color(c_white);
	}
}