// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function copy(){
	if (array_length(editor.selected)) editor.clipboard = editor.selected[0].id;
}