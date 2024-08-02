xScale = abs(xScale);
yScale = abs(yScale);
zScale = abs(zScale);

// Before drawing your SMF object, set the texture size as a uniform
shader_set(sh_smf_static);

// Draw the instance
modelMat = matrix_build(x, y, z, xRotation, yRotation, zRotation, xScale, yScale, -zScale);

matrix_set(matrix_world, modelMat);
model.tempInstance.draw();
matrix_set(matrix_world, matrix_build_identity());

// Reset the shader
shader_reset();

/* Debug collision mesh stuff (WARNING! LAGGY AF WITH MORE THAN 1 OBJECTS)
shader_set(sh_cm_debug);

cm_debug_draw(collisionMesh);

shader_reset()