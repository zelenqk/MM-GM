// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_assetbrowser(){
	draw_rectangle_color(assetBrowser.x, assetBrowser.y, assetBrowser.x + assetBrowser.width, assetBrowser.y + assetBrowser.height, easeDarkGray, easeDarkGray, easeDarkGray, easeDarkGray, false);

	var startx = assetBrowser.x + paddingM / 2;
	var starty = assetBrowser.y + paddingM / 2;
	
	var count = assetBrowser.width / assetBrowser.slotSize;
	
	for(var i = 0; i < array_length(assetBrowser.sorted); i++){
		var file = assetBrowser.sorted[i];
		
		var col = i mod count;
		var row = i div count;
		
		var tx = ((col * assetBrowser.slotSize) + (col * paddingM * 2)) + startx;
		var ty = ((row * assetBrowser.slotSize) + (row * paddingM * 2)) + starty;
		
		var pir = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), tx, ty, tx + assetBrowser.slotSize, ty + assetBrowser.slotSize);
		
		if (mouse_check_button_pressed(mb_left) and pir and inMouse == noone){
			inMouse = file;
			inMouse.xDelta = device_mouse_x_to_gui(0) - tx;
			inMouse.yDelta = device_mouse_y_to_gui(0) - ty;
			inMouse.iconSize = assetBrowser.slotSize;
		}
		
		draw_sprite_stretched(file.icon, 0, tx, ty, assetBrowser.slotSize, assetBrowser.slotSize);
		
		draw_set_halign(fa_center);
		draw_text_transformed(tx + assetBrowser.slotSize / 2, ty + assetBrowser.slotSize, file.name, assetBrowser.textScale, assetBrowser.textScale, 0);
		draw_set_halign(fa_left);
	}
}