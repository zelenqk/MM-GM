#macro mapListFname game_save_id + "mapList.json"

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_counterclockwise);

globalvar delta, projectPath, editor;

depth = -1;

targetDelta = 1 / 60;
delta = (delta_time / 1000000) / targetDelta;

projectPath = noone;

draw_set_font(fntUbuntu);
