function draw_line_width_3d(xFrom, yFrom, zFrom, xTo, yTo, zTo, w) {
	// Angle between vector +z [0, 0, 1]  and this line vector
	// Theta = cos^-1 ( a dot b ) / (|a||b|)
	// Since we're normalizing both vectors, the magnitude parts are 1 and can be written out
	var vect = [xTo - xFrom, yTo - yFrom, zTo - zFrom];
	var vectMagn = sqrt( power(vect[0], 2) + power(vect[1], 2) + power(vect[2], 2) );
	if ( vectMagn <= 0 ) return;
	vect[0] /= vectMagn;
	vect[1] /= vectMagn;
	vect[2] /= vectMagn;
	var ang = arccos( dot_product_3d(vect[0], vect[1], vect[2], 0, 0, 1) );
	var mat = matrix_build(0, 0, zFrom, 0, 0, ang, 1, 1, 1 );
	matrix_stack_push(mat);
	matrix_set(matrix_world, matrix_stack_top());
	draw_line_width( xFrom, yFrom, xTo, yTo, w);	
	matrix_stack_pop();
	matrix_set(matrix_world, matrix_stack_top());
}