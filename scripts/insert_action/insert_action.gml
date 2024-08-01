// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function insert_action(type, model, variable, oldValue){
	array_insert(editor.undo, 0, {
		"type": type,
		"variable": variable,
		"model": model,
		"oldValue": oldValue,
		"saved": editor.saved
	})
}