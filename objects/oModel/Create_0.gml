if (model = noone) instance_destroy();
else model = load_model(model);

if (!is_array(customVariables)) customVariables = [];

modelMat = matrix_build(x, y, z, xRotation, yRotation, zRotation, xScale, yScale, -zScale);
collisionMesh = cm_add(editor.level, cm_dynamic(model.cm, modelMat));

cm_custom_parameter_set(collisionMesh, {
	"id": id,
});