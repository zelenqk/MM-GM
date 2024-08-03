// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function cm_load_obj(filename, matrix = undefined, singlesided = true, smoothnormals = false, group = CM_GROUP_SOLID) {
	return cm_add_obj(cm_list(), filename, matrix, singlesided, smoothnormals, group);
}

function cm_add_obj(container, filename, matrix = undefined, singlesided = true, smoothnormals = false, group = CM_GROUP_SOLID) {
	var buffer = buffer_load(filename);
	if (buffer == -1) {
		cm_debug_message("Function cm_add_obj: Failed to load model " + string(filename));
		return -1;
	}
	cm_debug_message("Function cm_add_obj: Loading obj file " + string(filename));

	var contents = buffer_read(buffer, buffer_text);
	var lines = string_split(contents, "\n");
	var num = array_length(lines);

	// Initialize arrays
	var V = [];
	var N = [];
	var T = [];
	var F = [];

	// Process lines to populate vertex, normal, texture, and face arrays
	var i = 0;
	repeat (num) {
		var this_line = lines[i];
		// Basic whitespace removal
		this_line = string_replace(this_line, "  ", " ");
		while (string_pos("  ", this_line) > 0) {
			this_line = string_replace(this_line, "  ", " ");
		}
		
		// Skip empty lines
		if (this_line == "") {
			i++;
			continue;
		}

		var tokens = string_split(this_line, " ");
		var type = tokens[0];

		switch (type) {
			case "v":
				V[array_length(V)] = [real(tokens[1]), real(tokens[2]), real(tokens[3])];
				break;
			case "vn":
				N[array_length(N)] = [real(tokens[1]), real(tokens[2]), real(tokens[3])];
				break;
			case "vt":
				T[array_length(T)] = [real(tokens[1]), real(tokens[2])];
				break;
			case "f":
				var vert_count = array_length(tokens) - 1;
				var face = [];
				var j = 0;
				repeat (vert_count) {
					var info = tokens[j + 1];
					var indices = string_split(info, "/");
					var pos = real(indices[0]) - 1;
					var uv = (array_length(indices) > 1) ? real(indices[1]) - 1 : 0;
					var norm = (array_length(indices) > 2) ? real(indices[2]) - 1 : 0;
					face[j] = [pos, uv, norm];
					j++;
				}

				// Triangulate faces assuming they are in a fan format
				var k = 1;
				repeat (vert_count - 2) {
					F[array_length(F)] = [face[0], face[k + 1], face[k]];
					k++;
				}
				break;
		}
		i++;
	}
	buffer_delete(buffer);

	// Precompute normal matrix if required
	var normalmatrix = is_array(matrix) ? cm_matrix_transpose(cm_matrix_invert_orientation(matrix)) : undefined;

	// Process faces and vertices into the container
	var f = 0;
	repeat (array_length(F)) {
		var face = F[f];
		var v1 = V[face[0][0]];
		var v2 = V[face[1][0]];
		var v3 = V[face[2][0]];

		if (smoothnormals){
			var n1 = (array_length(N) > face[0][2]) ? N[face[0][2]] : [0, 0, 1];
			var n2 = (array_length(N) > face[1][2]) ? N[face[1][2]] : [0, 0, 1];
			var n3 = (array_length(N) > face[2][2]) ? N[face[2][2]] : [0, 0, 1];

			if (is_array(normalmatrix)) {
				n1 = matrix_transform_vertex(normalmatrix, n1[0], n1[1], n1[2], 0);
				n2 = matrix_transform_vertex(normalmatrix, n2[0], n2[1], n2[2], 0);
				n3 = matrix_transform_vertex(normalmatrix, n3[0], n3[1], n3[2], 0);
			}

			// Normalize normals
			var l1 = point_distance_3d(0, 0, 0, n1[0], n1[1], n1[2]);
			var l2 = point_distance_3d(0, 0, 0, n2[0], n2[1], n2[2]);
			var l3 = point_distance_3d(0, 0, 0, n3[0], n3[1], n3[2]);
			n1 = [n1[0] / l1, n1[1] / l1, n1[2] / l1];
			n2 = [n2[0] / l2, n2[1] / l2, n2[2] / l2];
			n3 = [n3[0] / l3, n3[1] / l3, n3[2] / l3];
		}else{
			var n1 = [0, 0, 1];
			var n2 = [0, 0, 1];
			var n3 = [0, 0, 1];
		}

		// Apply transformation to vertices
		v1 = is_array(matrix) ? matrix_transform_vertex(matrix, v1[0], v1[1], v1[2]) : v1;
		v2 = is_array(matrix) ? matrix_transform_vertex(matrix, v2[0], v2[1], v2[2]) : v2;
		v3 = is_array(matrix) ? matrix_transform_vertex(matrix, v3[0], v3[1], v3[2]) : v3;

		cm_add(container, cm_triangle(singlesided, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2], n1, n2, n3, group));

		f++;
	}

	cm_debug_message("Script cm_add_obj: Successfully loaded obj " + string(filename));
	return container;
}
