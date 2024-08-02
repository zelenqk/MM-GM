#macro mapListFname game_save_id + "mapList.json"

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

gpu_set_alphatestenable(true);
gpu_set_alphatestref(10);

gpu_set_tex_repeat(true);
//gpu_set_tex_mip_enable(true);


globalvar delta, projectPath, editor;

depth = -1;

targetDelta = 1 / 60;
delta = (delta_time / 1000000) / targetDelta;

projectPath = noone;

draw_set_font(fntUbuntu);