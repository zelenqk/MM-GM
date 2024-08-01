// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function undo(){
	if (array_length(editor.undo) <= 0) return;
	
	var action = editor.undo[0];
	
	switch (action.type){
	case "modelUpdate":
		array_insert(editor.redo, 0, {
			"type": action.type,
			"model": action.model,
			"variable": action.variable,
			"newValue": variable_struct_get(action.model, action.variable),
			"saved": action.saved,
		});

		variable_struct_set(action.model, action.variable, action.oldValue);
		
		update_model(action.model);
		
		editor.saved = action.saved;
		
		array_delete(editor.undo, 0, 1);
		break;
	}
}