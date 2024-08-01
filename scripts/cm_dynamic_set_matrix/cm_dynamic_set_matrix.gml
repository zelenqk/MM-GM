function cm_dynamic_set_matrix(dynamic, matrix, moving) 
{	
	/*	
		This script lets you make it seem like a colmesh instance has been transformed.
		What really happens though, is that the collision object is transformed by the inverse of the given matrix, 
		then it performs collision checks, and then it is transformed back. This is an efficient process.
		This script creates a new matrix from the given matrix, making sure that all the vectors are perpendicular, 
		and making sure the scaling is individual for each axis.
			
		Set moving to true if your object moves from frame to frame, and false if it's a static object that only uses a dynamic for static transformations.
	*/
	var M = CM_DYNAMIC_M;
	var I = CM_DYNAMIC_I;
	var P = CM_DYNAMIC_P;
	CM_DYNAMIC_MOVING = moving;
	
	//Make a copy of the given matrix instead of using it directly
	array_copy(M, 0, matrix, 0, 16);
		
	//Find the scale for each axis based on the columns of the matrix
	var scaleX = point_distance_3d(0, 0, 0, M[0], M[1], M[2]);
	var scaleY = point_distance_3d(0, 0, 0, M[4], M[5], M[6]);
	var scaleZ = point_distance_3d(0, 0, 0, M[8], M[9], M[10]);
	
	//Store the individual scales
	CM_DYNAMIC_SCALE_X = scaleX;
	CM_DYNAMIC_SCALE_Y = scaleY;
	CM_DYNAMIC_SCALE_Z = scaleZ;

	//Orthogonalize and normalize the vectors of the matrix
	cm_matrix_orthogonalize(M);
	
	//Rescale the matrix to the scales we found earlier
	cm_matrix_scale(M, scaleX, scaleY, scaleZ);
	
	//Store the previous inverse matrix
	array_copy(P, 0, I, 0, 16);
	
	//Invert the new world matrix
	cm_matrix_invert_orientation(M, I);
	
	//Update AABB
	__cmi_dynamic_update_aabb(dynamic);
}
