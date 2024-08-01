// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function import_model(){
	var path = get_open_filename("3D Objects|*.obj;*.smf*", "");
	if (path == "") return;
	
	header.message = ["Attempting to load model...", 100];

	try{
		load_model(path);
		header.message = ["Model loaded successfully", 100];
	}catch(e){
		header.message = ["Couldn't load model...", 100];
	}
}