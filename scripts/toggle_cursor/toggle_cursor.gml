#macro cursorOn "|"
#macro cursorOff ""
#macro cursorTimer 16

function toggle_cursor(cursor){
	if (cursor == "") return cursorOn;
	
	return cursorOff;
}