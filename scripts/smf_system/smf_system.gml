/// @description smf_model_create()
global.SMFtempSample = array_create(128);
global.animTempV = array_create(3);
global.AnimTempQ1 = array_create(8);
global.AnimTempQ2 = array_create(8);
global.AnimTempQ3 = array_create(8);
global.AnimTempQ4 = array_create(8);
global.AnimTempM = array_create(16);
global.AnimUniMap = ds_map_create();
global.AnimTempWorldDQ = [];

//Async loading
global._SMFAsyncQueue = ds_queue_create();
global._SMFAsyncBuffer = buffer_create(1, buffer_grow, 1);
global._SMFAsyncHandle = -1;
global._SMFAsyncModel = -1;
global._SMFAsyncText = "";
#macro SMFAsyncDebug true
	
enum eAnimInterpolation{
	Keyframe, Linear, Quadratic}
		
enum eAnimNode{
	Name, WorldDQ, LocalDQ, WorldDQConjugate, LocalDQConjugate, Parent, Children, Descendants, IsBone, Length, PrimaryAxis, Locked, LockedPos, Num}

function smf_model_load(path) 
{
	if !file_exists(path){return -1;}
	var ext = string_lower(filename_ext(path));
	if (ext == ".obj")
	{
		return smf_model_load_obj(path);
	}
	if (ext == ".smf")
	{
		var loadBuff = buffer_load(path); 
		var model = smf_model_load_from_buffer(loadBuff, path);
		buffer_delete(loadBuff);

		return model;
	}
	show_debug_message("smf_model_load could not load file " + string(path));
	return -1;
}

function smf_model_get_animation(model, name) 
{
	return model.get_animation(name);
}

function smf_model_load_from_buffer(loadBuff, path = "", targetModel = new smf_model()) 
{
	if (path != "")
	{
		var ext = string_lower(filename_ext(path))
		if (ext == ".obj")
		{
			var buff = buffer_load(path);
			if (buff < 0)
			{
				show_debug_message("smf_model_load_from_buffer: The given buffer does not contain a valid OBJ model");
			}
			var obj = mbuff_load_obj_from_buffer(buff, path, true);
			buffer_delete(buff);
			mbuff_add(targetModel.mBuff, obj[0]);
			texpack_add_texpack(targetModel.texPack, obj[1]);
			targetModel.vBuff = vbuff_create_from_mbuff(targetModel.mBuff);
			var modelNum = array_length(obj[0]);
			var texNum = array_length(obj[1]);
			show_debug_message("smf_model_load_from_buffer: Successfully loaded OBJ model " + string(path) + ", containing " + string(modelNum) + " models and " + string(texNum) + " textures");
			return targetModel;
		}
	}
	buffer_seek(loadBuff, buffer_seek_start, 0);
	var headerText = buffer_read(loadBuff, buffer_string);
	if (headerText != "SMF_v11_by_Snidr_and_Bart")
	{
		var model = smf_model_load_v10_from_buffer(loadBuff, path, targetModel);
		if (is_struct(model))
		{
			return model;
		}
		show_debug_message("smf_model_load_from_buffer: The given buffer does not contain a valid SMF model");
		return -1;
	}
	
	//Load buffer positions
	var texPos = buffer_read(loadBuff, buffer_u32);
	var modPos = buffer_read(loadBuff, buffer_u32);
	var rigPos = buffer_read(loadBuff, buffer_u32);
	var aniPos = buffer_read(loadBuff, buffer_u32);

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Load textures
	var texMap = ds_map_create();
	buffer_seek(loadBuff, buffer_seek_start, texPos);
	var texNum = buffer_read(loadBuff, buffer_u8);
	if (texNum > 0)
	{
		var s = surface_create(8, 8);
		surface_set_target(s);
		draw_clear(c_white);
		surface_reset_target();
		var blankSprite = sprite_create_from_surface(s, 0, 0, 8, 8, 0, 0, 0, 0);
		var texBuff = buffer_create(1, buffer_fast, 1);
		for (var t = 0; t < texNum; t ++)
		{
			var name = buffer_read(loadBuff, buffer_string);
			var w = buffer_read(loadBuff, buffer_u16);
			var h = buffer_read(loadBuff, buffer_u16);
			var spr = asset_get_index(filename_change_ext(filename_name(path), "_" + string(name)));
			if (sprite_exists(spr)) //Check if the texture is already in the game files
			{
				texMap[? name] = spr;
			}
			else if (w > 0 and h > 0)
			{
				surface_resize(s, w, h);
				buffer_resize(texBuff, w * h * 4)
				buffer_copy(loadBuff, buffer_tell(loadBuff), w * h * 4, texBuff, 0);
				buffer_set_surface(texBuff, s, 0);
				texMap[? name] = sprite_create_from_surface(s, 0, 0, w, h, 0, 0, 0, 0);
			}
			else if is_undefined(texMap[? name])
			{
				texMap[? name] = sprite_duplicate(blankSprite);
			}
			buffer_seek(loadBuff, buffer_seek_relative, w * h * 4);
		}
		sprite_delete(blankSprite);
		surface_free(s);
		buffer_delete(texBuff);
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//Load models
	buffer_seek(loadBuff, buffer_seek_start, modPos);
	var modelNum = buffer_read(loadBuff, buffer_u8);
	var model = targetModel;
	model.mBuff = array_create(modelNum);
	model.vBuff = array_create(modelNum);
	model.texPack = array_create(modelNum);
	model.vis = array_create(modelNum);
	model.subRigIndex = array_create(modelNum);
	for (var m = 0; m < modelNum; m ++)
	{
		//Read vertex buffers
		var size = buffer_read(loadBuff, buffer_u32);
		var mBuff = buffer_create(size, buffer_fixed, 1);
		buffer_copy(loadBuff, buffer_tell(loadBuff), size, mBuff, 0);
		buffer_seek(loadBuff, buffer_seek_relative, size);
		var vBuff = vertex_create_buffer_from_buffer(mBuff, global.mBuffFormat);
		vertex_freeze(vBuff);
		model.mBuff[m] = mBuff;
		model.vBuff[m] = vBuff;
		
		var matName = buffer_read(loadBuff, buffer_string);
		var texName = buffer_read(loadBuff, buffer_string);
		var texInd = texMap[? texName];
		model.texPack[m] = is_undefined(texInd) ? -1 : texInd;
		model.vis[m] = buffer_read(loadBuff, buffer_u8);
	}
	ds_map_destroy(texMap);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Load rig
	buffer_seek(loadBuff, buffer_seek_start, rigPos);
	var nodeNum = buffer_read(loadBuff, buffer_u32);
	if (nodeNum > 0)
	{
		for (var i = 0; i < nodeNum; i ++)
		{
			//Load the node as a dual quaternion
			var Q = array_create(8);
			for (var j = 0; j < 8; j ++)
			{
				Q[j] = buffer_read(loadBuff, buffer_f32);
			}
			
			//Create a node
			node = array_create(eAnimNode.Num, 0);
			node[@ eAnimNode.WorldDQ] = Q;
			node[@ eAnimNode.Parent] = buffer_read(loadBuff, buffer_u32);
			node[@ eAnimNode.IsBone] = buffer_read(loadBuff, buffer_u8);
			node[@ eAnimNode.Locked] = buffer_read(loadBuff, buffer_u8);
			
			//Load primary axis, which is used for IK. If no primary axis is stored, SMF will do an educated guess when needed.
			var px = buffer_read(loadBuff, buffer_f32);
			var py = buffer_read(loadBuff, buffer_f32);
			var pz = buffer_read(loadBuff, buffer_f32);
			node[@ eAnimNode.PrimaryAxis] = (px == 0 && py == 0 && pz == 0) ? undefined : [px, py, pz];
			
			//Add node to rig
			model.rig.nodeList[| i] = node;
			model.rig.update_node(i);
		}
		
		//Update the rig's bind map, for mapping bones to nodes
		model.rig.update_bindmap();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Load animation
	buffer_seek(loadBuff, buffer_seek_start, aniPos);
	var animNum = buffer_read(loadBuff, buffer_u8);
	var nodeList = model.rig.nodeList;
	var poseDQ = array_create(nodeNum);
	model.animations = array_create(animNum);
	model.sampleStrips = array_create(animNum);
	for (var a = 0; a < animNum; a ++)
	{
		var animName = buffer_read(loadBuff, buffer_string);
		var anim = new smf_anim(animName);
		anim.loop = buffer_read(loadBuff, buffer_u8);
		anim.playTime = buffer_read(loadBuff, buffer_f32);
		anim.interpolation = buffer_read(loadBuff, buffer_u8);
		anim.sampleFrameMultiplier = buffer_read(loadBuff, buffer_u8);
		anim.nodeNum = nodeNum;
		anim.update_playspeed();
		model.animMap[? animName] = a;
		model.animations[a] = anim;
		
		var frameNum = buffer_read(loadBuff, buffer_u32);
		for (var f = 0; f < frameNum; f ++)
		{
			var frameTime = buffer_read(loadBuff, buffer_f32);
			var keyframeInd = anim.keyframe_add(frameTime);
			if (f > 0)
			{
				var prevFrame = keyframe;
			}
			var keyframe = anim.keyframeGrid[# 1, keyframeInd];
			for (var i = 0; i < nodeNum; i ++)
			{
				var Q = array_create(8);
				for (var l = 0; l < 8; l ++)
				{
					Q[l] = buffer_read(loadBuff, buffer_f32);
				}
				poseDQ[i] = Q;
				
				var node = nodeList[| i];
				
				if (i == 0)
				{
					//The first node's keyframe DQ stores change in worldspace orientation
					keyframe[@ 0] = smf_dq_multiply(node[eAnimNode.WorldDQConjugate], poseDQ[i], array_create(8));
					continue;
				}
				
				//The keyframe stores change in local orientation from bind to current keyframe
				var poseLocalDQ = smf_dq_multiply(smf_dq_get_conjugate(poseDQ[node[eAnimNode.Parent]], array_create(8)), poseDQ[i], array_create(8));
				keyframe[@ i] = smf_dq_multiply(node[eAnimNode.LocalDQConjugate], poseLocalDQ, array_create(8));
			}
		}
	}

	show_debug_message("Successfully loaded SMF model " + string(path) + ", containing " + string(modelNum) + " models and " + string(texNum) + " textures");
	return model;
}

function smf_model_load_obj(path) 
{
	if (!file_exists(path)){return -1;}
	var model = new smf_model();
	var buff = buffer_load(path);
	var obj = mbuff_load_obj_from_buffer(buffer_load(path), path, true);
	buffer_delete(buff);
	if (!is_array(obj)){return -1;}
	model.mBuff = obj[0];
	model.texPack = obj[1];
	model.texPackPath = obj[2];
	model.vBuff = vbuff_create_from_mbuff(obj[0]);
	return model;
}

/// @func smf_model_submit(model, [sample]
function smf_model_submit() 
{
	var model = argument[0];
	if (argument_count == 1)
	{
		model.submit();
	}
	else
	{
		model.submit(argument[1]);
	}
}
function smf_model_destroy(model, deleteTextures) 
{
	model.destroy(deleteTextures);
	delete model;
}
function smf_model_enable_compatibility(model, bonesPerPart, extraBones)
{
	model.enable_compatibility(bonesPerPart, extraBones);
}
function smf_model_partition_rig(model, bonesPerPart, extraBones)
{
	model.partition_rig(bonesPerPart, extraBones);
}
function smf_model_save(model, path, incTex) 
{
	var mBuff = model.mBuff;
	var texPack = model.texPack;
	var vis = model.vis;
	var rig = model.rig;
	var animArray = model.animations;
	var partitioned = model.partitioned;
	var subRigIndex = model.subRigIndex;
	var subRigs = model.subRigs;
	var modelNum = array_length(mBuff);

	////////////////////////////////////////////////////////////////////
	//Create buffer and write header
	var saveBuff = buffer_create(100, buffer_grow, 1);
	buffer_write(saveBuff, buffer_string, "SMF_v11_by_Snidr_and_Bart");
	var texHeader = buffer_tell(saveBuff);	buffer_write(saveBuff, buffer_u32, 0); //Buffer position of the textures
	var modHeader = buffer_tell(saveBuff);	buffer_write(saveBuff, buffer_u32, 0); //Buffer position of the models
	var rigHeader = buffer_tell(saveBuff);	buffer_write(saveBuff, buffer_u32, 0); //Buffer position of the rig
	var aniHeader = buffer_tell(saveBuff);	buffer_write(saveBuff, buffer_u32, 0); //Buffer position of the animation
	buffer_write(saveBuff, buffer_u32, 0); //Placeholder

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Write textures
	
	//GPU Settings
	gpu_push_state();
	gpu_set_zwriteenable(false);
	gpu_set_ztestenable(false);
	gpu_set_cullmode(cull_noculling);
	var texPos = buffer_tell(saveBuff);
	buffer_poke(saveBuff, texHeader, buffer_u32, texPos); //Save a pointer to the buffer position of the textures to the header of the file
	buffer_write(saveBuff, buffer_u8, 0); //Number of textures, this will be overwritten later
	//Write the used textures
	var writtenTexMap = ds_map_create();
	var n = array_length(mBuff);
	gpu_set_blendmode_ext(bm_one, bm_zero);
	var s = surface_create(1, 1);
	var texBuff = buffer_create(1, buffer_fast, 1);
	for (var t = 0; t < modelNum; t ++)
	{
		var tex = texPack[t];
		if (!is_undefined(writtenTexMap[? tex])){continue;}
		writtenTexMap[? tex] = true;
		buffer_write(saveBuff, buffer_string, string(tex));
		if incTex
		{
			var w = sprite_get_width(tex);
			var h = sprite_get_height(tex);
			surface_resize(s, w, h);
			surface_set_target(s);
			draw_clear_alpha(c_white, 0);
			draw_sprite_ext(tex, 0, 0, h, 1, -1, 0, c_white, 1);
			surface_reset_target();
			buffer_resize(texBuff, w * h * 4);
			buffer_get_surface(texBuff, s, 0);
		
			buffer_write(saveBuff, buffer_u16, w);
			buffer_write(saveBuff, buffer_u16, h);
			buffer_copy(texBuff, 0, w * h * 4, saveBuff, buffer_tell(saveBuff));
			buffer_seek(saveBuff, buffer_seek_relative, w * h * 4);
		}
		else
		{
			buffer_write(saveBuff, buffer_u16, 0);
			buffer_write(saveBuff, buffer_u16, 0);
		}
	}
	surface_free(s);
	buffer_poke(saveBuff, texPos, buffer_u8, ds_map_size(writtenTexMap));
	ds_map_destroy(writtenTexMap);
	buffer_delete(texBuff);
	gpu_pop_state();

	if (!incTex)
	{
		//Save textures
		buffer_write(saveBuff, buffer_u8, 99);
		var texNum = min(array_length(texPack), array_length(mBuff));
		for (var i = 0; i < texNum; i ++)
		{
			sprite_save(texPack[i], 0, filename_change_ext(path, "_" + string(texPack[i]) + ".png"));
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Write models
	buffer_poke(saveBuff, modHeader, buffer_u32, buffer_tell(saveBuff));
	buffer_write(saveBuff, buffer_u8, modelNum);
	for (var m = 0; m < modelNum; m ++)
	{
		var size = buffer_get_size(mBuff[m]);
		buffer_write(saveBuff, buffer_u32, size);
		buffer_copy(mBuff[m], 0, size, saveBuff, buffer_tell(saveBuff));
		buffer_seek(saveBuff, buffer_seek_relative, size);
		buffer_write(saveBuff, buffer_string, "Default");
		buffer_write(saveBuff, buffer_string, string(texPack[m]));
		
		//Write whether or not this model is visible
		buffer_write(saveBuff, buffer_u8, vis[m]);
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Write rig
	buffer_poke(saveBuff, rigHeader, buffer_u32, buffer_tell(saveBuff));
	var nodeNum, nodeList, node, frameNum, DQ, i, k;
	nodeNum = 0;
	if (is_struct(rig))
	{
		nodeList = rig.nodeList;
		nodeNum = ds_list_size(nodeList);
	}
	buffer_write(saveBuff, buffer_u32, nodeNum);
	var M = array_create(16);
	
	//Write node hierarchy
	for (i = 0; i < nodeNum; i ++)
	{
		node = nodeList[| i];
		DQ = node[eAnimNode.WorldDQ];
		for (k = 0; k < 8; k ++)
		{
			buffer_write(saveBuff, buffer_f32, DQ[k]);
		}
		buffer_write(saveBuff, buffer_u32, node[eAnimNode.Parent]);
		buffer_write(saveBuff, buffer_u8, node[eAnimNode.IsBone]);
		buffer_write(saveBuff, buffer_u8, node[eAnimNode.Locked]);
		
		//Write primary axis
		var pAxis = node[eAnimNode.PrimaryAxis];
		if (is_array(pAxis))
		{
			buffer_write(saveBuff, buffer_f32, pAxis[0]);
			buffer_write(saveBuff, buffer_f32, pAxis[1]);
			buffer_write(saveBuff, buffer_f32, pAxis[2]);
		}
		else
		{
			buffer_write(saveBuff, buffer_f32, 0);
			buffer_write(saveBuff, buffer_f32, 0);
			buffer_write(saveBuff, buffer_f32, 0);
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Write animations
	buffer_poke(saveBuff, aniHeader, buffer_u32, buffer_tell(saveBuff));
	var animNum = array_length(animArray);
	buffer_write(saveBuff, buffer_u8, animNum);
	for (var a = 0; a < animNum; a ++)
	{
		var anim = animArray[a];
		buffer_write(saveBuff, buffer_string, anim.name);
		buffer_write(saveBuff, buffer_u8, anim.loop);
		buffer_write(saveBuff, buffer_f32, anim.playTime);
		buffer_write(saveBuff, buffer_u8, anim.interpolation);
		buffer_write(saveBuff, buffer_u8, anim.sampleFrameMultiplier);
		
		var keyframeGrid = anim.keyframeGrid;
		frameNum = ds_grid_height(keyframeGrid);
		buffer_write(saveBuff, buffer_u32, frameNum);
		for (var f = 0; f < frameNum; f ++)
		{
			buffer_write(saveBuff, buffer_f32, keyframeGrid[# 0, f]);
			for (var i = 0; i < nodeNum; i ++)
			{
				//Get the change in local orientation from the rig to the frame
				var DQ = anim.keyframe_get_node_dq(rig, f, i);
				for (var k = 0; k < 8; k ++)
				{
					buffer_write(saveBuff, buffer_f32, DQ[k]);
				}
			}
		}
	}
	
	buffer_save(saveBuff, path);
	buffer_delete(saveBuff);
}

/// @func smf_model_load_async(fname)
function smf_model_load_async(fname)
{
	var model = new smf_model();
	
	if (global._SMFAsyncHandle < 0)
	{
		_smf_async_start([fname, model]);
	}
	else
	{
		ds_queue_enqueue(global._SMFAsyncQueue, [fname, model]);
		
		global._SMFAsyncText = "SMF Async Loading: Enqueued model \"" + fname + "\"";
		if (SMFAsyncDebug)
		{
			show_debug_message(global._SMFAsyncText);
		}
	}
	
	return model;
}

/// @func _smf_async_start(model)
function _smf_async_start(model)
{
	global._SMFAsyncHandle = buffer_load_async(global._SMFAsyncBuffer, model[0], 0, -1);
	if (global._SMFAsyncHandle < 0)
	{
		global._SMFAsyncText = "ERROR: Failed to load \"" + global._SMFAsyncModel[0] + "\"";
		if (os_browser==browser_ie || os_browser==browser_ie_mobile )
		{
			global._SMFAsyncText = "Broswer does not support binary file loading";
		}
		if (SMFAsyncDebug)
		{
			show_debug_message(global._SMFAsyncText);
		}
		return false;
	}
	global._SMFAsyncModel = model;
	global._SMFAsyncText = "SMF Async Loading: Started loading model \"" + global._SMFAsyncModel[0] + "\"";
	if (SMFAsyncDebug)
	{
		show_debug_message(global._SMFAsyncText);
	}
}

/// @func smf_async_update()
function smf_async_update()
{
	//Returns true if loading is finished
	if (async_load[? "id"] == global._SMFAsyncHandle)
    {
		if (async_load[? "status"] == false)
        {
			global._SMFAsyncText = "SMF Async Loading: Load failed! \"" + global._SMFAsyncModel[0] + "\"";
			if (SMFAsyncDebug)
			{
				show_debug_message(global._SMFAsyncText);
			}
        }
		else
		{
			global._SMFAsyncText = "SMF Async Loading: Successfully loaded file \"" + global._SMFAsyncModel[0] + "\"";
			if (SMFAsyncDebug)
			{
				show_debug_message(global._SMFAsyncText);
			}
			smf_model_load_from_buffer(global._SMFAsyncBuffer, global._SMFAsyncModel[0], global._SMFAsyncModel[1]);
		}
		
		if (!ds_queue_empty(global._SMFAsyncQueue))
		{
			_smf_async_start(ds_queue_dequeue(global._SMFAsyncQueue));
			return false;
		}
		global._SMFAsyncText = "SMF Async Loading: Loading finished";
		if (SMFAsyncDebug)
		{
			show_debug_message(global._SMFAsyncText);
		}
		global._SMFAsyncHandle = -1;
		return true;
    }
}