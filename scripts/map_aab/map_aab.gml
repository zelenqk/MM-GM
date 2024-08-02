function map_aab(sAABB, tAABB){
// Calculate the size of the source bounding box
    var source_width  = sAABB[3] - sAABB[0];
    var source_height = sAABB[4] - sAABB[1];
    var source_depth  = sAABB[5] - sAABB[2];
    
    // Calculate the size of the target bounding box
    var target_width  = tAABB[3] - tAABB[0];
    var target_height = tAABB[4] - tAABB[1];
    var target_depth  = tAABB[5] - tAABB[2];
    
    // Calculate the scale factors for each dimension
    var scaleX = target_width / source_width;
    var scaleY = target_height / source_height;
    var scaleZ = target_depth / source_depth;
    
    // Use the largest scale factor to ensure the source fits inside the target while maximizing its size
    var scale = min(scaleX, scaleY, scaleZ);
    
    // Calculate the dimensions of the scaled source bounding box
    var scaled_width  = source_width  * scale;
    var scaled_height = source_height * scale;
    var scaled_depth  = source_depth  * scale;
    
    // Calculate the center of the source bounding box
    var source_center_x = (sAABB[3] + sAABB[0]) / 2;
    var source_center_y = (sAABB[4] + sAABB[1]) / 2;
    var source_center_z = (sAABB[5] + sAABB[2]) / 2;
    
    // Calculate the center of the target bounding box
    var target_center_x = (tAABB[3] + tAABB[0]) / 2;
    var target_center_y = (tAABB[4] + tAABB[1]) / 2;
    var target_center_z = (tAABB[5] + tAABB[2]) / 2;
    
    // Calculate the new coordinates of the scaled and centered bounding box
    var new_x_min = target_center_x - (scaled_width / 2);
    var new_y_min = target_center_y - (scaled_height / 2);
    var new_z_min = target_center_z - (scaled_depth / 2);
    
    var new_x_max = new_x_min + scaled_width;
    var new_y_max = new_y_min + scaled_height;
    var new_z_max = new_z_min + scaled_depth;
    
    // Return the new centered and scaled bounding box
    return [scale, target_center_x, target_center_y, target_center_z];
}