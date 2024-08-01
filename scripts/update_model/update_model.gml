// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function update_model(model){
	with (model){
		cm_dynamic_set_matrix(collisionMesh, matrix_build(x, y, z, xRotation, yRotation, zRotation, xScale, yScale, -zScale), true);
		cm_dynamic_update_container(collisionMesh, editor.level);
	}
	
	editor.saved = false;
}