// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function raycast(container, length = 10000){
	var mx = (device_mouse_x_to_gui(0) - view.x) / view.width;
	var my = (device_mouse_y_to_gui(0) - view.y) / view.height;
	
	var vmat = camera_get_view_mat(view_camera[0]);
	var pmat = camera_get_proj_mat(view_camera[0]);
	
	var v = cm_2d_to_3d(vmat, pmat, mx, my);
	var ray = cm_cast_ray(container, cm_ray(view.camX, view.camY, view.camZ, view.camX + v[0] * length, view.camY + v[1] * length, view.camZ + v[2] * length));
	return ray;
}