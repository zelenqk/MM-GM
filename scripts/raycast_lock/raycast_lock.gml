// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function raycast_lock(container, xTo = noone, yTo = noone, zTo = noone, length = 10000){
	var mx = ((device_mouse_x_to_gui(0) + gui.mx) - view.x) / view.width;
	var my = ((device_mouse_y_to_gui(0) + gui.my) - view.y) / view.height;
	
	var vmat = camera_get_view_mat(view_camera[0]);
	var pmat = camera_get_proj_mat(view_camera[0]);
	
	var v = cm_2d_to_3d(vmat, pmat, mx, my);
	
	xTo = (xTo == noone) ? view.camX + v[0] * length : xTo;
	yTo = (yTo == noone) ? view.camY + v[1] * length : yTo;
	zTo = (zTo == noone) ? view.camZ + v[2] * length : zTo;
	
	var ray = cm_cast_ray(container, cm_ray(view.camX, view.camY, view.camZ, xTo, yTo, zTo));

	return ray;
}