// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function paste(){
	if (instance_exists(editor.clipboard)) with(editor.clipboard) {
		instance_create_depth(x, y, depth, oModel, {
			"z": z,
			"xScale": xScale,
			"yScale": yScale,
			"zScale": zScale,
			"xRotation": xRotation,
			"yRotation": yRotation,
			"zRotation": zRotation,
			"model": model.path,
			"customVariables": customVariables,
		})
	}
}