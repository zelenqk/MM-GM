function smf_smoothstep(_min, _max, val) 
{
	// Scale, bias and saturate x to 0..1 range
	var xx = clamp((val - _min) / (_max - _min), 0.0, 1.0); 
	// Evaluate polynomial
	return xx * xx * (3 - 2 * xx);
}
function smf_quadratic_interpolate(A, B, C, amount) 
{
	var t0 = .5 * sqr(1 - amount);
	var t1 = .5 * amount * amount;
	var t2 = 2 * amount * (1 - amount);
	return t0 * (A + B) + t1 * (B + C) + t2 * B;
}
function smf_get_array_index(array, val) 
{	/*	Returns the array index of the given value.
		-1 if the value does not exist in the array*/
	for (var i = array_length(array) - 1; i >= 0; i --)
	{
		if (val == array[i])
		{
			return i;
		}
	}
	return -1;
}


function smf_model_load_v7_from_buffer(loadBuff, path = "", targetModel = new smf_model()) 
{
	buffer_seek(loadBuff, buffer_seek_start, 0);
	var HeaderText = buffer_read(loadBuff, buffer_string);
	var versionNum = 0;
	if HeaderText != "SnidrsModelFormat"
	{
		show_debug_message("The given buffer does not contain a valid SMF model");
		return -1;
	}
	versionNum = buffer_read(loadBuff, buffer_f32);

	var partitioned = false;
	var compatibility = false;

	//This importer supports versions 6, 7 and 8
	if (versionNum > 8)
	{
		show_error("This was made with a newer version of SMF.", false);
		return -1;
	}
	else if (versionNum == 8)
	{
		partitioned = true;
		compatibility = buffer_read(loadBuff, buffer_bool);
	}
	else if (versionNum < 6)
	{
		show_error("This was made with an unsupported version of SMF.", false);
		return -1;
	}

	//Create SMF model container
	var model = targetModel;

	//Load buffer positions
	var texPos = buffer_read(loadBuff, buffer_u32);
	var matPos = buffer_read(loadBuff, buffer_u32);
	var modPos = buffer_read(loadBuff, buffer_u32);
	var nodPos = buffer_read(loadBuff, buffer_u32);
	var colPos = buffer_read(loadBuff, buffer_u32);
	var rigPos = buffer_read(loadBuff, buffer_u32);
	var aniPos = buffer_read(loadBuff, buffer_u32);
	var selPos = buffer_read(loadBuff, buffer_u32);
	var subPos = buffer_read(loadBuff, buffer_u32);
	buffer_read(loadBuff, buffer_u32); //Placeholder

	//Version 6 "compiled"
	if (versionNum == 6)
	{
		if buffer_read(loadBuff, buffer_u8) //If compiled
		{
			show_error("This was made with an unsupported version of SMF.", false);
			return -1;
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Load number of models
	var modelNum = buffer_read(loadBuff, buffer_u8);

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
		var vBuff = vertex_create_buffer_from_buffer(mBuff, compatibility ? global.mBuffStdFormat : global.mBuffFormat);
		vertex_freeze(vBuff);
		model.mBuff[m] = mBuff;
		model.vBuff[m] = vBuff;
		model.subRigIndex[m] = 0;
	
		buffer_seek(loadBuff, buffer_seek_relative, size);
	
		var matName = buffer_read(loadBuff, buffer_string);
		var texName = buffer_read(loadBuff, buffer_string);
		var texInd = texMap[? texName];
		model.texPack[m] = is_undefined(texInd) ? -1 : texInd;
		model.vis[m] = buffer_read(loadBuff, buffer_u8);
		
		//Ignore skinning info
		var n = buffer_read(loadBuff, buffer_u32);
		repeat n{buffer_seek(loadBuff, buffer_seek_relative, buffer_read(loadBuff, buffer_u8) * 4);}
		var n = buffer_read(loadBuff, buffer_u32);
		buffer_seek(loadBuff, buffer_seek_relative, n * 4);
	
		//Read partition index
		if partitioned
		{
			model.subRigIndex[m] = buffer_read(loadBuff, buffer_u8);
		}
	}
	ds_map_destroy(texMap);

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Load rig
	buffer_seek(loadBuff, buffer_seek_start, rigPos);
	var nodeNum, i, j, nodeList, node, worldDQ;
	nodeNum = buffer_read(loadBuff, buffer_u8);
	if (nodeNum > 0)
	{
		model.rig = new smf_rig();
		nodeList = model.rig.nodeList;
		for (i = 0; i < nodeNum; i ++)
		{
			node = array_create(eAnimNode.Num, 0);
			worldDQ = array_create(8);
			for (j = 0; j < 8; j ++)
			{
				worldDQ[j] = buffer_read(loadBuff, buffer_f32);
			}
			node[@ eAnimNode.WorldDQ] = worldDQ;
			node[@ eAnimNode.Parent] = buffer_read(loadBuff, buffer_u8);
			node[@ eAnimNode.IsBone] = buffer_read(loadBuff, buffer_u8);
			node[@ eAnimNode.PrimaryAxis] = [0, 0, 1];
	
			//Add node to node list
			nodeList[| i] = node;
			_anim_rig_update_node(model.rig, i);
		}
		_anim_rig_update_bindmap(model.rig);
	}
	if (buffer_read(loadBuff, buffer_u8) == 232) //An extension to the rig format
	{
		var bytesPerNode = buffer_read(loadBuff, buffer_u8);
		var buffPos = buffer_tell(loadBuff);
		for (var i = 0; i < nodeNum; i ++)
		{
			node = nodeList[| i];
			node[@ eAnimNode.Locked] = buffer_peek(loadBuff, buffPos + bytesPerNode * i, buffer_u8);
			if (bytesPerNode >= 13)
			{
				var pAxis = array_create(3);
				pAxis[0] = buffer_peek(loadBuff, buffPos + bytesPerNode * i + 1, buffer_f32);
				pAxis[1] = buffer_peek(loadBuff, buffPos + bytesPerNode * i + 5, buffer_f32);
				pAxis[2] = buffer_peek(loadBuff, buffPos + bytesPerNode * i + 9, buffer_f32);
				node[@ eAnimNode.PrimaryAxis] = pAxis;
			}
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Load rig partitions
	if (partitioned)
	{
		buffer_seek(loadBuff, buffer_seek_start, subPos);
		var num = buffer_read(loadBuff, buffer_u8);
		model.subRigs = array_create(num);
		for (var i = 0; i < num; i ++)
		{
			var boneNum = buffer_read(loadBuff, buffer_u8);
			var subRig = array_create(boneNum);
			for (var j = 0; j < boneNum; j ++)
			{
				subRig[j] = buffer_read(loadBuff, buffer_u8);
			}
			model.subRigs[i] = subRig;
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Load animation
	buffer_seek(loadBuff, buffer_seek_start, aniPos);
	var animNum, animName, anim, keyframeNum, keyframeGrid, keyframeTime, keyframeInd, deltaDQ, keyframe, a, f, i, l, localDQ;
	localDQ = array_create(8);
	animNum = buffer_read(loadBuff, buffer_u8);
	if (animNum > 0)
	{
		model.animations = array_create(animNum);
		for (a = 0; a < animNum; a ++)
		{
			animName = buffer_read(loadBuff, buffer_string);
			anim = new smf_anim(animName);
			keyframeNum = buffer_read(loadBuff, buffer_u8);
			keyframeGrid = anim.keyframeGrid;
			anim.loop = true;
			anim.nodeNum = nodeNum;
			anim.interpolation = eAnimInterpolation.Quadratic;
			for (f = 0; f < keyframeNum; f ++)
			{
				keyframeTime = buffer_read(loadBuff, buffer_f32);
				keyframeInd = anim_add_keyframe(anim, keyframeTime);
				keyframe = keyframeGrid[# 1, keyframeInd];
				for (i = 0; i < nodeNum; i ++)
				{
					for (l = 0; l < 8; l ++)
					{
						//Read delta local dual quaternion of the keyframe node
						localDQ[l] = buffer_read(loadBuff, buffer_f32);
					}
					node = nodeList[| i];
					deltaDQ = keyframe[i];
					smf_dq_multiply(node[eAnimNode.LocalDQConjugate], localDQ, deltaDQ);
					if (node[eAnimNode.IsBone])
					{
						deltaDQ[@ 4] = 0;
						deltaDQ[@ 5] = deltaDQ[2] * node[eAnimNode.Length];
						deltaDQ[@ 6] = -deltaDQ[1] * node[eAnimNode.Length];
						deltaDQ[@ 7] = 0;
					}
				}
			}
			model.animMap[? animName] = a;
			model.animations[a] = anim;
		}
	}
	//Load additional animation info (only used in v8)
	if (buffer_read(loadBuff, buffer_u8) == 239)
	{
		for (a = 0; a < animNum; a ++)
		{
			anim = model.animations[a];
			anim.playTime = buffer_read(loadBuff, buffer_f32);
			anim.update_playspeed();
			anim.sampleFrameMultiplier = buffer_read(loadBuff, buffer_u8);
			anim.loop = buffer_read(loadBuff, buffer_bool);
		}
	}
	//Generate sample strips for each animation
	for (a = 0; a < animNum; a ++)
	{
		anim = model.animations[a];
		array_set(model.sampleStrips, a, new smf_samplestrip(model.rig, anim));
	}
	
	show_debug_message("Successfully loaded SMF model " + string(path) + 
		+ ", containing " + string(modelNum) + ((modelNum > 1) ? " models" : " model")
		+ " and " + string(texNum) + ((texNum > 1) ? " textures" : " texture"));
	return model;
}


function smf_model_load_v10_from_buffer(loadBuff, path = "", targetModel = new smf_model()) 
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
	if (headerText != "SMF_v10_by_Snidr_and_Bart")
	{
		var model = smf_model_load_v7_from_buffer(loadBuff, path, targetModel);
		if (is_struct(model))
		{
			return model;
		}
		show_debug_message("smf_model_load_from_buffer: The given buffer does not contain a valid SMF model");
		return -1;
	}
	
	//Load buffer positions
	var texPos = buffer_read(loadBuff, buffer_u32);
	var matPos = buffer_read(loadBuff, buffer_u32);
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
	var nodeNum = buffer_read(loadBuff, buffer_u8);
	if (nodeNum > 0)
	{
		var M = array_create(16);
		for (var i = 0; i < nodeNum; i ++)
		{
			//Load the node as a 4x4 matrix
			for (var j = 0; j < 16; j ++)
			{
				M[j] = buffer_read(loadBuff, buffer_f32);
			}
			
			smf_mat_orthogonalize(M);
			
			//Create a node
			node = array_create(eAnimNode.Num, 0);
			node[@ eAnimNode.WorldDQ] = smf_dq_create_from_matrix(M, array_create(8));
			node[@ eAnimNode.Parent] = buffer_read(loadBuff, buffer_u8);
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
	var M = array_create(16);
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
				for (var l = 0; l < 16; l ++)
				{
					M[l] = buffer_read(loadBuff, buffer_f32);
				}
				
				smf_mat_orthogonalize(M);
				poseDQ[i] = smf_dq_create_from_matrix(M, array_create(8));
				
				var node = nodeList[| i];
				if (i > 0)
				{
					//The keyframe stores change in local orientation from bind to current keyframe
					var poseLocalDQ = smf_dq_multiply(smf_dq_get_conjugate(poseDQ[node[eAnimNode.Parent]], array_create(8)), poseDQ[i], array_create(8));
					keyframe[@ i] = smf_dq_multiply(node[eAnimNode.LocalDQConjugate], poseLocalDQ, array_create(8));
					if (f == 0)
					{
						//Make sure the first frame is in the positive side of the hyper-hemisphere
						if (keyframe[i][3] < 0)
						{
							//smf_dq_invert(keyframe[i]);
						}
					}
					else
					{
						//Make sure the rotation from the previous frame is in the same side of the hyper-hemisphere
						if (smf_quat_dot(prevFrame[i], keyframe[i]) < 0)
						{
							smf_dq_invert(keyframe[i]);
						}
					}
				}
				else
				{
					//The first node's keyframe DQ stores change in worldspace orientation
					keyframe[@ i] = smf_dq_multiply(node[eAnimNode.WorldDQConjugate], poseDQ[i], array_create(8));
				}
			}
		}
	}

	show_debug_message("Successfully loaded SMF model " + string(path) + ", containing " + string(modelNum) + " models and " + string(texNum) + " textures");
	return model;
}
