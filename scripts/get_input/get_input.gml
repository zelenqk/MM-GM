// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function get_input(type, data){
	with (oInput){
		if (self.type == type and self.data == data) return id;
	}
	
	return noone;
}