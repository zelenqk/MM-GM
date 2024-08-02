function convert_3d_to_2d(x_, y_, z_) {
	var vx,vy, vz, l, pos,
	matrix_pos = matrix_get(matrix_world),
	matrix_view_projection = matrix_multiply(matrix_get(matrix_view), matrix_get(matrix_projection));
	
	matrix_pos[12] = argument0
	matrix_pos[13] = argument1
	matrix_pos[14] = argument2
	
	var matrix_screen_pos = matrix_multiply(matrix_pos, matrix_view_projection);
	
	l = 1 / matrix_screen_pos[15]
	
	vx = matrix_screen_pos[12] * l
	vy = matrix_screen_pos[13] * l
	vz = matrix_screen_pos[14] * l
	
	if abs(vx) > 1 || abs(vy) > 1 || vz > 1.00002
	{return false}
	
	pos[0] = floor(((vx + 1) * 0.5) * view.width);
	pos[1] = floor(((1 - vy) * 0.5) * view.height);
	
	return pos
}
