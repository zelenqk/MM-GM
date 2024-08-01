// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function lock_mouse(){
	if (window_mouse_get_x() < 0){
		gui.mx -= window_get_width();
		display_mouse_set(window_get_x() + window_get_width(), display_mouse_get_y());
	}
	
	if (window_mouse_get_x() > window_get_width()){
		gui.mx += window_get_width();
		display_mouse_set(window_get_x(), display_mouse_get_y());
	}
	
	if (window_mouse_get_y() < 0){
		gui.my -= window_get_height();
		display_mouse_set(display_mouse_get_x(), window_get_y() + window_get_height());
	}
	
	if (window_mouse_get_y() > window_get_height()){
		gui.my += window_get_height();
		display_mouse_set(display_mouse_get_x(), window_get_y());
	}
}