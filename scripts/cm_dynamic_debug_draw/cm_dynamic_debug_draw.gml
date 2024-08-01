// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_dynamic_debug_draw(dynamic, tex = -1, color = c_blue)
{
	if (CM_RECURSION >= CM_MAX_RECURSIONS) return false;
	
	++ CM_RECURSION;
	
	var W = matrix_get(matrix_world);
	matrix_set(matrix_world, matrix_multiply(CM_DYNAMIC_M, W));
	cm_debug_draw(CM_DYNAMIC_OBJECT, tex, color);
	matrix_set(matrix_world, W);
	
	-- CM_RECURSION;
}