// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_map_list(){
	draw_set_color(c_black);
	draw_set_alpha(0.4);
	draw_rectangle(mapListContainer.x, mapListContainer.y, mapListContainer.x + mapListContainer.width, mapListContainer.y + mapListContainer.height, false);
	draw_set_alpha(1);
	draw_set_color(easyWhite);
	
	var selection = false
	
	for(var i = 0; i < array_length(mapList); i++){
		var map = mapList[i];
		
		var segmentX = 12;
		var segmentY =  mapListContainer.y + (mapListContainerSegment.height + 12) * i + 12 - (mapListContainerSlider.sliderY / mapListContainerSlider.scale);
		
		var pir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), segmentX, segmentY, segmentX + mapListContainerSegment.width, segmentY + mapListContainerSegment.height);
		
		draw_sprite_stretched_ext(sBG, 0, segmentX, segmentY, mapListContainerSegment.width, mapListContainerSegment.height, c_black, 0.4)
		
		draw_text_transformed(segmentX + 4, segmentY, map.nameShort, mapListContainerSegment.nameScale, mapListContainerSegment.nameScale, 0);
		draw_set_valign(fa_bottom);
		draw_text_transformed(segmentX + 4, segmentY - 2 + mapListContainerSegment.height, map.pathShort, mapListContainerSegment.pathScale, mapListContainerSegment.pathScale, 0);
		draw_set_valign(fa_top);
		
		if (pir){
			window_set_cursor(cr_handpoint);
			selection = true;
			
			if (mouse_check_button_pressed(mb_left)){
				projectPath = map.path;
				room = rmEditor;
			}
		}
		
	}
	
	if (!selection and !mapListContainerSlider.draw) window_set_cursor(cr_arrow);
	
	if (mapListContainerSlider.draw){
		draw_roundrect(mapListContainerSlider.x, mapListContainerSlider.y, mapListContainerSlider.x + mapListContainerSlider.width, mapListContainerSlider.y + mapListContainerSlider.height, 1);
		draw_roundrect(mapListContainerSlider.x, mapListContainerSlider.y + mapListContainerSlider.sliderY, mapListContainerSlider.x + mapListContainerSlider.width, mapListContainerSlider.y + mapListContainerSlider.sliderY + mapListContainerSlider.height * mapListContainerSlider.scale, 0);
		
		pir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), mapListContainerSlider.x, mapListContainerSlider.y + mapListContainerSlider.sliderY, mapListContainerSlider.x + mapListContainerSlider.width, mapListContainerSlider.y + mapListContainerSlider.sliderY + mapListContainerSlider.height * mapListContainerSlider.scale)
		
		if (!selection and !pir) window_set_cursor(cr_arrow);
		
		if (pir){
			window_set_cursor(cr_handpoint);
			
			if (mouse_check_button_pressed(mb_left)) mapListContainerSlider.deltaY = (device_mouse_y_to_gui(0) - mapListContainerSlider.y) - mapListContainerSlider.sliderY;
			
		}
		
		if (mouse_check_button(mb_left) and mapListContainerSlider.deltaY != noone){
			mapListContainerSlider.sliderY = (device_mouse_y_to_gui(0) - mapListContainerSlider.y) - mapListContainerSlider.deltaY;
			mapListContainerSlider.sliderY = clamp(mapListContainerSlider.sliderY, 0, mapListContainerSlider.height - (mapListContainerSlider.height * mapListContainerSlider.scale));
		}
		
		if (mouse_check_button_released(mb_left) and mapListContainerSlider.deltaY != noone) mapListContainerSlider.deltaY = noone;
	}
	
	draw_set_color(make_color_rgb(10, 10, 10));
	draw_rectangle(0, 0, mapListContainer.width, mainMenuHeader.height, false);
	draw_set_color(easyWhite);

	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	draw_text_transformed(mapListContainer.width / 2, mainMenuHeader.height / 2 - paddingS / 2, mainMenuHeader.text, mainMenuHeader.scale, mainMenuHeader.scale, 0);
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	
	draw_set_color(c_white);
}