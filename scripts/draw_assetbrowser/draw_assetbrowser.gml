// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_assetbrowser(){
	draw_rectangle_color(assetBrowser.x, assetBrowser.y, assetBrowser.x + assetBrowser.width, assetBrowser.y + assetBrowser.height, easeDarkGray, easeDarkGray, easeDarkGray, easeDarkGray, false);

	var startx = paddingM / 2;
	var starty = paddingM / 2 - assetBrowser.sliderY;
	
	var count = 9
	
	var slotSize = (assetBrowser.width - paddingM * 1.5) / count;
	
	if (!surface_exists(assetBrowser.browserSurface)) assetBrowser.browserSurface = surface_create_c(assetBrowser.width - paddingM * 1.5, assetBrowser.height);
	
	surface_set_target(assetBrowser.browserSurface){
		draw_clear_alpha(c_black, 0);
		
		for(var i = 0; i < array_length(assetBrowser.sorted); i++){
			var file = assetBrowser.sorted[i];
			
			var col = i mod count;
			var row = i div count;
			
			var tx = ((col * slotSize) + (col * paddingM * 2)) + startx;
			var ty = ((row * slotSize) + (row * paddingM * 2)) + starty;
			
			var pir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), tx + assetBrowser.x, ty + assetBrowser.y, tx + assetBrowser.x + slotSize, ty + assetBrowser.y + slotSize);
			
			if (mouse_check_button_pressed(mb_left) and pir and inMouse == noone){
				inMouse = file;
				inMouse.xDelta = device_mouse_x_to_gui(0) - (tx + assetBrowser.x);
				inMouse.yDelta = device_mouse_y_to_gui(0) - (ty + assetBrowser.y);
				inMouse.iconSize = slotSize;
			}
			
			draw_sprite_stretched(file.icon, 0, tx, ty, slotSize, slotSize);
			
			draw_set_halign(fa_center);
			draw_text_transformed(tx + slotSize / 2, ty + slotSize, file.name, assetBrowser.textScale, assetBrowser.textScale, 0);
			draw_set_halign(fa_left);
		}
		
		surface_reset_target();
	}
	
	draw_surface(assetBrowser.browserSurface, assetBrowser.x, assetBrowser.y);
	
	ty = 1000;
	
	var sliderHeight = ty / (assetBrowser.height + paddingM);
	var sliderScale = assetBrowser.height / sliderHeight;
	
	pir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), assetBrowser.x + assetBrowser.width - paddingM * 0.9, (assetBrowser.y + assetBrowser.sliderY), assetBrowser.x + assetBrowser.width, (assetBrowser.y + assetBrowser.sliderY) + sliderScale);
	
	if (pir){
		if (mouse_check_button_pressed(mb_left)) assetBrowser.deltaY = (device_mouse_y_to_gui(0) - assetBrowser.y) - assetBrowser.sliderY;
	}
	
	if (mouse_check_button(mb_left) and assetBrowser.deltaY != noone){
		assetBrowser.sliderY = (device_mouse_y_to_gui(0) - assetBrowser.y) - assetBrowser.deltaY;
		assetBrowser.sliderY = clamp(assetBrowser.sliderY, 0, assetBrowser.height - sliderScale);
	}
	
	if (mouse_check_button_released(mb_left) and assetBrowser.deltaY != noone) assetBrowser.deltaY = noone;
	
	draw_sprite_stretched_ext(sBG, 0, assetBrowser.x + assetBrowser.width - paddingM * 0.9, assetBrowser.y, paddingM * 0.9, assetBrowser.height, c_black, 0.1);
	draw_sprite_stretched_ext(sBG, 0, assetBrowser.x + assetBrowser.width - paddingM * 0.9, assetBrowser.y + assetBrowser.sliderY, paddingM * 0.9, sliderScale, c_black, 0.4);
}