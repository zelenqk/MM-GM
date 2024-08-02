function cm_dynamic_set_matrix(dynamic, matrix, moving) 
{	
	var M = CM_DYNAMIC_M;
	var I = CM_DYNAMIC_I;
	var P = CM_DYNAMIC_P;
	CM_DYNAMIC_MOVING = moving;
	
	array_copy(M, 0, matrix, 0, 16);
	
	// Assuming M needs to be adjusted to align with the expected forward/up directions:
	// Example: if forward should be along the Z-axis but is currently along the Y-axis, swap Y and Z
	swap_axes(M, "y", "z"); // Custom function to swap axes

	var scaleX = point_distance_3d(0, 0, 0, M[0], M[1], M[2]);
	var scaleY = point_distance_3d(0, 0, 0, M[4], M[5], M[6]);
	var scaleZ = point_distance_3d(0, 0, 0, M[8], M[9], M[10]);

	CM_DYNAMIC_SCALE_X = scaleX;
	CM_DYNAMIC_SCALE_Y = scaleY;
	CM_DYNAMIC_SCALE_Z = scaleZ;

	cm_matrix_orthogonalize(M);
	cm_matrix_scale(M, scaleX, scaleY, scaleZ);

	array_copy(P, 0, I, 0, 16);
	cm_matrix_invert_orientation(M, I);
	
	__cmi_dynamic_update_aabb(dynamic);
}

function swap_axes(matrix, axis1, axis2) 
{
    // Swap the specified axes in the matrix
    // For example, if axis1 is "y" and axis2 is "z", swap their corresponding rows/columns
    var temp;
    
    if (axis1 == "y" && axis2 == "z") {
        // Swap Y and Z axes
        temp = [matrix[4], matrix[5], matrix[6]];
        matrix[4] = matrix[8];
        matrix[5] = matrix[9];
        matrix[6] = matrix[10];
        matrix[8] = temp[0];
        matrix[9] = temp[1];
        matrix[10] = temp[2];
    }
}
