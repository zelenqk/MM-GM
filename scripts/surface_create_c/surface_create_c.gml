globalvar surfaces;
surfaces = [];

function surface_create_c(w, h){
	var surface = surface_create(w + 2, h + 2);
	
	surfaces[array_length(surfaces)] = surface;
	
	return surface;
}