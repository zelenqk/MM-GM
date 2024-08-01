function cm_add_smf(container, smfmodel, matrix = undefined, singlesided = true, smoothnormals = false, group = CM_GROUP_SOLID)
{
	var v1 = array_create(3);
	var v2 = array_create(3);
	var v3 = array_create(3);
	var n1 = array_create(3);
	var n2 = array_create(3);
	var n3 = array_create(3);
	var models = smfmodel.mBuff;
	var modelNum = array_length(models);
 
	//Loop through the loaded information and generate a model
	if (is_array(matrix))
	{
		var normalmatrix = cm_matrix_transpose(cm_matrix_invert_orientation(matrix));
 
		for (var m = 0; m < modelNum; ++m)
		{
			var mbuff = models[m];
			var mbuff_bytes_per_vertex = 44;//mBuffBytesPerVert; //This is a macro in the SMF system
			var buffersize = buffer_get_size(mbuff);
			var b = 0;
			repeat (buffersize / mbuff_bytes_per_vertex) div 3
			{
				buffer_seek(mbuff, buffer_seek_start, (b++) * mbuff_bytes_per_vertex);
				v1[0] = buffer_read(mbuff, buffer_f32);
				v1[1] = buffer_read(mbuff, buffer_f32);
				v1[2] = buffer_read(mbuff, buffer_f32);
				n1[0] = buffer_read(mbuff, buffer_f32);
				n1[1] = buffer_read(mbuff, buffer_f32);
				n1[2] = buffer_read(mbuff, buffer_f32);
 
				buffer_seek(mbuff, buffer_seek_start, (b++) * mbuff_bytes_per_vertex);
				v2[0] = buffer_read(mbuff, buffer_f32);
				v2[1] = buffer_read(mbuff, buffer_f32);
				v2[2] = buffer_read(mbuff, buffer_f32);
				n2[0] = buffer_read(mbuff, buffer_f32);
				n2[1] = buffer_read(mbuff, buffer_f32);
				n2[2] = buffer_read(mbuff, buffer_f32);
 
				buffer_seek(mbuff, buffer_seek_start, (b++) * mbuff_bytes_per_vertex);
				v3[0] = buffer_read(mbuff, buffer_f32);
				v3[1] = buffer_read(mbuff, buffer_f32);
				v3[2] = buffer_read(mbuff, buffer_f32);
				n3[0] = buffer_read(mbuff, buffer_f32);
				n3[1] = buffer_read(mbuff, buffer_f32);
				n3[2] = buffer_read(mbuff, buffer_f32);
 
				//Add the vertex to the model buffer
				if (smoothnormals)
				{
					v1 = matrix_transform_vertex(matrix, v1[0], v1[1], v1[2]);
					n1 = matrix_transform_vertex(normalmatrix, n1[0], n1[1], n1[2], 0);
					var l1 = point_distance_3d(0, 0, 0, n1[0], n1[1], n1[2]);
					n1[0] /= l1; n1[1] /= l1; n1[2] /= l1;
 
					v2 = matrix_transform_vertex(matrix, v2[0], v2[1], v2[2]);
					n2 = matrix_transform_vertex(normalmatrix, n2[0], n2[1], n2[2], 0);
					var l2 = point_distance_3d(0, 0, 0, n2[0], n2[1], n2[2]);
					n2[0] /= l2; n2[1] /= l2; n2[2] /= l2;
 
					v3 = matrix_transform_vertex(matrix, v3[0], v3[1], v3[2]);
					n3 = matrix_transform_vertex(normalmatrix, n3[0], n3[1], n3[2], 0);
					var l3 = point_distance_3d(0, 0, 0, n3[0], n3[1], n3[2]);
					n3[0] /= l3; n3[1] /= l3; n3[2] /= l3;
 
					cm_add(container, cm_triangle(singlesided, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2], n1, n2, n3, group));
				}
				else
				{
					v1 = matrix_transform_vertex(matrix, v1[0], v1[1], v1[2]);
					v2 = matrix_transform_vertex(matrix, v2[0], v2[1], v2[2]);
					v3 = matrix_transform_vertex(matrix, v3[0], v3[1], v3[2]);
 
					cm_add(container, cm_triangle(singlesided, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2], undefined, undefined, undefined, group));
				}
			}
		}
	}
	else
	{
		for (var m = 0; m < modelNum; ++m)
		{
			var mbuff = models[m];
			var mbuff_bytes_per_vertex = 44;//mBuffBytesPerVert; //This is a macro in the SMF system
			var buffersize = buffer_get_size(mbuff);
			var b = 0;
			repeat (buffersize / mbuff_bytes_per_vertex) div 3
			{
				buffer_seek(mbuff, buffer_seek_start, (b++) * mbuff_bytes_per_vertex);
				v1[0] = buffer_read(mbuff, buffer_f32);
				v1[1] = buffer_read(mbuff, buffer_f32);
				v1[2] = buffer_read(mbuff, buffer_f32);
				n1[0] = buffer_read(mbuff, buffer_f32);
				n1[1] = buffer_read(mbuff, buffer_f32);
				n1[2] = buffer_read(mbuff, buffer_f32);
 
				buffer_seek(mbuff, buffer_seek_start, (b++) * mbuff_bytes_per_vertex);
				v2[0] = buffer_read(mbuff, buffer_f32);
				v2[1] = buffer_read(mbuff, buffer_f32);
				v2[2] = buffer_read(mbuff, buffer_f32);
				n2[0] = buffer_read(mbuff, buffer_f32);
				n2[1] = buffer_read(mbuff, buffer_f32);
				n2[2] = buffer_read(mbuff, buffer_f32);
 
				buffer_seek(mbuff, buffer_seek_start, (b++) * mbuff_bytes_per_vertex);
				v3[0] = buffer_read(mbuff, buffer_f32);
				v3[1] = buffer_read(mbuff, buffer_f32);
				v3[2] = buffer_read(mbuff, buffer_f32);
				n3[0] = buffer_read(mbuff, buffer_f32);
				n3[1] = buffer_read(mbuff, buffer_f32);
				n3[2] = buffer_read(mbuff, buffer_f32);
 
				//Add the vertex to the model buffer
				if (smoothnormals)
				{
					cm_add(container, cm_triangle(singlesided, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2], n1, n2, n3, group));
				}
				else
				{
					cm_add(container, cm_triangle(singlesided, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2], undefined, undefined, undefined, group));
				}
			}
		}
	}
	cm_debug_message("Script cm_add_smf: Successfully added SMF model to colmesh");
	return container;
}
