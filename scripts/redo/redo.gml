// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function redo(){
	if (array_length(editor.redo) <= 0) return;
	
	var action = editor.redo[0];
	
	switch (action.type){
	case "modelUpdate":
		array_insert(editor.undo, 0, {
			"type": action.type,
			"model": action.model,
			"variable": action.variable,
			"oldValue": variable_struct_get(action.model, action.variable),
			"saved": action.saved,
		});

		variable_struct_set(action.model, action.variable, action.newValue);
		
		update_model(action.model);
		
		editor.saved = action.saved;
		
		array_delete(editor.redo, 0, 1);
		break;
	}
}