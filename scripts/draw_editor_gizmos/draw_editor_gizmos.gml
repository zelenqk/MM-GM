// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_editor_gizmos(){
	if (editor.selected == noone) return;
	
	if (view.enabled == false and editor.selected != noone and editor.gizmos.lock == noone){
		if (keyboard_check_pressed(ord("A"))) editor.gizmos.type = "pos";
		if (keyboard_check_pressed(ord("S"))) editor.gizmos.type = "scale";
	}
	
	gpu_set_ztestenable(false);
	gpu_set_zwriteenable(false);
	
	var gismoScale = point_distance_3d(editor.selected.x, editor.selected.y, editor.selected.z, view.camX, view.camY, view.camZ) / 12.5;
	
	var col = shader_get_uniform(sh_smf_color, "u_uColor")
	shader_set(sh_smf_color);
	
	//X
	shader_set_uniform_f_array(col, [1, 0, 0, 1]);
	matrix_set(matrix_world, matrix_build(editor.selected.x, editor.selected.y, editor.selected.z, 0, 0, 0, gismoScale, gismoScale, -gismoScale));
	switch (editor.gizmos.type){
	case "pos":
		editor.gizmos.pos.base.model.draw();
		break;
	case "scale":
		editor.gizmos.scale.base.model.draw();
		break;
	}
	
	//Y
	shader_set_uniform_f_array(col, [0, 1, 0, 1]);
	matrix_set(matrix_world, matrix_build(editor.selected.x, editor.selected.y, editor.selected.z, 0, 0, 90, gismoScale, gismoScale, -gismoScale));
	switch (editor.gizmos.type){
	case "pos":
		editor.gizmos.pos.base.model.draw();
		break;
	case "scale":
		editor.gizmos.scale.base.model.draw();
		break;
	}
	
	//Z
	shader_set_uniform_f_array(col, [0, 0, 1, 1]);
	matrix_set(matrix_world, matrix_build(editor.selected.x, editor.selected.y, editor.selected.z, 0, 270, 0, gismoScale, gismoScale, -gismoScale));
	switch (editor.gizmos.type){
	case "pos":
		editor.gizmos.pos.base.model.draw();
		break;
	case "scale":
		editor.gizmos.scale.base.model.draw();
		break;
	}
	
	//COLMESH STuFF
	var xMat = matrix_build(editor.selected.x, editor.selected.y, editor.selected.z,  0, 0, 0, gismoScale, gismoScale, gismoScale);
	var yMat = matrix_build(editor.selected.x, editor.selected.y, editor.selected.z,  0, 0, 90, gismoScale, gismoScale, -gismoScale);
	var zMat = matrix_build(editor.selected.x, editor.selected.y, editor.selected.z,  0, 270, 0, gismoScale, gismoScale, -gismoScale);
	
	switch(editor.gizmos.type){
	case "pos":
		cm_dynamic_set_matrix(editor.gizmos.pos.x, xMat, false);
		cm_dynamic_set_matrix(editor.gizmos.pos.y, yMat, false);
		cm_dynamic_set_matrix(editor.gizmos.pos.z, zMat, false);
		
		cm_dynamic_update_container(editor.gizmos.pos.x, editor.gizmos.pos.base.cm);
		cm_dynamic_update_container(editor.gizmos.pos.y, editor.gizmos.pos.base.cm);
		cm_dynamic_update_container(editor.gizmos.pos.z, editor.gizmos.pos.base.cm);
		break;
	case "scale":
		cm_dynamic_set_matrix(editor.gizmos.scale.x, xMat, false);
		cm_dynamic_set_matrix(editor.gizmos.scale.y, yMat, false);
		cm_dynamic_set_matrix(editor.gizmos.scale.z, zMat, false);
		
		cm_dynamic_update_container(editor.gizmos.scale.x, editor.gizmos.scale.base.cm);
		cm_dynamic_update_container(editor.gizmos.scale.y, editor.gizmos.scale.base.cm);
		cm_dynamic_update_container(editor.gizmos.scale.z, editor.gizmos.scale.base.cm);
		break;
	}
	
	matrix_set(matrix_world, matrix_build_identity());
	shader_reset();
	
	gpu_set_ztestenable(true);
	gpu_set_zwriteenable(true);
}