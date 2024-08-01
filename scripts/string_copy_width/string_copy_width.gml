// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function string_copy_width(str, w, scale = 1){
	var offset = string_length(str);
	var newString = string_copy(str, 1, offset);
	
	while ((string_width(newString) * scale) > w){
		offset--;
		newString = string_copy(str, 1, offset);
	}
	
	return newString;
}