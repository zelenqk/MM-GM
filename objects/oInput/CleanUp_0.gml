if (type = 0 and surface_exists(surface)) surface_free(surface);

for(var i = 0; i < array_length(surfaces); i++){
	if (!surface_exists(surfaces[i])) array_delete(surfaces, i, 1);
}