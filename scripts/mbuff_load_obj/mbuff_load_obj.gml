/// @description mbuff_load_obj(fname)
/// @param fname
function mbuff_load_obj(fname) {
	/*
		Loads an OBJ file and returns an array of buffers.
	
		Script created by TheSnidr, 2019
		www.thesnidr.com
	*/
	var buff = buffer_load(fname);
	var model = mbuff_load_obj_from_buffer(buff, false);
	buffer_delete(buff);
	return model[0];
}
