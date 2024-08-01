// Before drawing your SMF object, set the texture size as a uniform
shader_set(sh_smf_static);

// Draw the instance
modelMat = matrix_build(x, y, z, xRotation - 90, yRotation, zRotation, xScale, yScale, -zScale);

matrix_set(matrix_world, modelMat);
model.tempInstance.draw();
matrix_set(matrix_world, matrix_build_identity());

// Reset the shader
shader_reset();