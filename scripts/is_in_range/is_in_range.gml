// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function is_in_range(char, range){
	for(var i = 0; i < array_length(range); i++){
		if (ord(char) >= range[i][0] and ord(char) <= range[i][1]) return true;	
	}

	return false;
}