// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_header(){
	draw_set_color(darkGray);
	draw_rectangle(header.x, header.y, header.x + header.width, header.y + header.height, false);
	draw_set_color(easyWhite);
	
	var headPir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), header.x, header.y, header.x + header.width, header.y + header.height);
	
	var tx = paddingS / 2;
	
	for(var i = 0; i < array_length(header.options); i++){
		var option = header.options[i];
		var width = string_width(header.options[i].name) * header.scale;
		
		var pir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), tx - paddingS / 2, header.y, tx + width + paddingS / 2, header.y + header.height);
		
		if (!headPir and mouse_check_button_pressed(mb_left)){
			header.selected = noone;
		}
		
		if (pir and mouse_check_button_pressed(mb_left)){
			header.selected = i;	
		}
		
		if (pir or header.halfSelected == i or header.selected == i){
			if (header.halfSelected != i) header.halfSelected = i;
			
			draw_set_color(easeDarkGray);
			draw_rectangle(tx - paddingS / 2, header.y, tx + width + paddingS / 2, header.y + header.height, false);	
			draw_rectangle(tx - paddingS / 2, header.y + header.height + 1, tx + option.width + paddingS / 2, header.y + header.height + option.height + 1, false);
			
			draw_set_color(easyWhite);
			
			var ty = header.y + header.height + paddingS / 2 + paddingS / 4;
			for(var u = 0; u < array_length(option.options); u++){
				var subOption = option.options[u];
				
				if (subOption != noone){
					var subPir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), tx - paddingS, ty - paddingS / 2, tx + option.width, ty + string_height(subOption.name) * header.scale + paddingS / 2)
					
					if (subPir){
						draw_set_color(lightGray);
						draw_rectangle(tx - paddingS, ty - paddingS / 4, tx + option.width + paddingS / 2, ty + string_height(subOption.name) * header.scale + paddingS / 4, false);	
						
						if (mouse_check_button_pressed(mb_left)){
							if (script_exists(subOption.func)) script_execute(subOption.func);
							
							header.selected = noone;
							header.halfSelected = noone;
						}
					}
					
					draw_set_color(easyWhite);
					draw_text_transformed(tx, ty, subOption.name, header.scale, header.scale, 0);
					
					ty += string_height(subOption.name) * header.scale + paddingS / 2;
				}else{
					draw_set_color(lightGray);
					draw_line(tx, ty + paddingS / 4, tx + option.width, ty + paddingS / 4);
					draw_set_color(easyWhite);
					
					ty += paddingS;
					
				}
			}
		}
		
		var subBgPir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), tx - paddingS / 2, header.y + header.height, tx + option.width + paddingS / 2, header.y + header.height + option.height);
		
		if (!subBgPir and !pir and header.halfSelected == i and header.selected != i){
			header.halfSelected = noone;
		}
		
		draw_text_transformed(tx, paddingS / 2, option.name, header.scale, header.scale, 0);	
		
		tx += width + paddingS;
	}
	
	if (header.message != noone){
		draw_set_halign(fa_right);
		draw_text_transformed_color(header.x + header.width - paddingS / 2, header.y + paddingS / 2, header.message[0], header.scale, header.scale, 0, easyWhite, easyWhite, easyWhite, easyWhite, header.message[1] / 10);
		draw_set_halign(fa_left);

		header.message[1] += -delta;
		
		if (header.message[1] <= 0) header.message = noone;
	}
}