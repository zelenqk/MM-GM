function draw_bounding_box_3d(coords, line_width){
	//bottom face
	var x1 = coords[0];
	var x2 = coords[3];
	
	var y1 = coords[1];
	var y2 = coords[4];
	
	var z1 = coords[2];
	var z2 = coords[5];
	
	var width = x2 - x1;
	var length = y2 - y1;
	var height = z2 - z1;
	
	draw_line_width_3d(x1, y1, z1, x2, y1, z1, 1);
	draw_line_width_3d(x1, y2, z1, x2, y2, z1, 1);
	draw_line_width_3d(x2, y1, z1, x2, y2, z1, 1);
	draw_line_width_3d(x1, y1, z1, x1, y2, z1, 1);
	
	draw_line_width_3d(x1, y1, z2, x2, y1, z2, 1);
	draw_line_width_3d(x1, y2, z2, x2, y2, z2, 1);
	draw_line_width_3d(x2, y1, z2, x2, y2, z2, 1);
	draw_line_width_3d(x1, y1, z2, x1, y2, z2, 1);
}