/// @description smf_instance_create(modelInd)
/// @param modelInd
function smf_instance(_model) constructor 
{
	//Identifying info
	model = _model;
	anim = -1;
	
	//Animation settings
	timer = 0;
	smooth = true;
	animLerp = 1;
	lerpSpd = .2;
	animSpeed = 0;
	sampleStrip = -1;
	currAnimInd = -1;
	currAnimName = "";
	fastSampling = false;
	
	//Samples
	sample = -1;
	prevSample = -1;
	backupSample = -1;
	
	//Used for switching animations
	newAnimInd = -1;
	newTimer = 0;
	
	sample = sample_create_bind(model.rig);
	prevSample = sample_create_bind(model.rig);
	
	/// @func fastSampleTest() 
	#macro SMFfastSampleTest if (fastSampling){show_debug_message("Error in SMF instance: Can't edit fast-sampling instance!"); return true;}
	
	/// @func step(timeStep) 
	static step = function(timeStep)
	{
		//Animate and interpolate between animations for the given animation instance.
		//Must be used once per step.
		
		if (currAnimInd < 0 && currAnimName != "")
		{
			//If the current animation index is negative and the current animation name is not "", the model could still be loading. Check if the animation exists.
			var animInd = model.animMap[? currAnimName];
			newAnimInd = is_undefined(animInd) ? -1 : animInd;
			//animLerp = 1;
		}
		
		if (currAnimInd < 0 && newAnimInd < 0)
		{
			//If the current animation does not exist, create a bind pose sample and exit the script.
			sample_update_bind(model.rig, sample);
			exit;
		}

		//Update the current instance's sample
		if (currAnimInd >= 0)
		{
			if (fastSampling)
			{
				sample = sampleStrip.get_nearest_frame(timer);
			}
			else
			{
				sampleStrip.update_sample(timer, sample, smooth);

				//Linearly interpolate between the two samples
				if (animLerp < 1)
				{
					animLerp = min(1, animLerp + lerpSpd * timeStep);
					sample_lerp(prevSample, sample, animLerp, sample);
				}
			}
		}

		//Switch animations
		if (newAnimInd >= 0)
		{
			timer = newTimer;
			anim = model.animations[newAnimInd];
			sampleStrip = model.sampleStrips[newAnimInd];
			if (!is_struct(sampleStrip))
			{
				sampleStrip = new smf_samplestrip(model.rig, anim);
				model.sampleStrips[newAnimInd] = sampleStrip;
			}
			if (currAnimInd >= 0)
			{	//Copy the current sample over to the previous sample
				animLerp = 0;
				array_copy(prevSample, 0, sample, 0, array_length(sample));
			}
			if (currAnimInd < 0 || lerpSpd * timeStep >= 1)
			{	//If there was no previous animation, update the sample immediately
				sampleStrip.update_sample(newTimer, sample, smooth);
				animLerp = 1;
			}
			currAnimInd = newAnimInd;
			newAnimInd = -1;
		}
		
		//Increment the current animation's timer
		if (currAnimInd >= 0)
		{
			var spd = animSpeed;
			if (animSpeed == -1)
			{
				spd = anim.playSpeed;
			}
			if (anim.loop)
			{
				timer = frac(timer + spd * timeStep + 1);
			}
			else
			{
				timer = clamp(timer + spd * timeStep, 0, 1);
			}
		}
	}
	
	/// @func set_sample_from_keyframe(animName, keyframe)
	static set_sample_from_keyframe = function(animName, keyframe)
	{
		//This function lets you set the instance's sample to the time of the given keyframe index
		//Note that if you use smf_instance.step() after this, it will overwrite the sample.
		var animInd = model.animMap[? animName];
		if (is_undefined(animInd)){return false;}
		var anim = model.animations[animInd];
		var time = anim.keyframeGrid[# 0, keyframe];
		var strip = model.sampleStrips[animInd];
		if (!is_struct(strip))
		{
			strip = new smf_samplestrip(model.rig, anim);
			model.sampleStrips[animInd] = strip;
		}
		strip.update_sample(time, sample, false);
		return true;
	}
	
	/// @func draw() 
	static draw = function()
	{
		model.submit(sample);
	}
	
	/// @func fast_sampling(enable) 
	static fast_sampling = function(enable)
	{	/*	This script enables fast animation sampling from the animation instance.
			This means that the samples are not interpolated at all, but are taken directly from the sample strip.åå
	
			//IMPORTANT//
				When fast sampling is enabled, the sample must NOT be edited! This runs the risk of editing the sample strip itself,
				resulting in possibly breaking the entire animation.
			//IMPORTANT//*/
		if (enable && !fastSampling)
		{
			backupSample = sample;
		}
		if (!enable && fastSampling)
		{
			sample = backupSample;
		}
		fastSampling = enable;
	}
	
	/// @func play(animName, animSpeed, lerpSpeed, resetTimer) 
	static play = function(animName, spd, lerpSpeed, resetTimer) 
	{	/*	Play an animation in the given animation instance.
			If the animation is already playing, this script will only set the animation speed.*/
		currAnimName = animName;
		var animInd = model.animMap[? animName];
		
		//Set anim speed and lerp speed even if the animation index hasn't changed
		lerpSpd = lerpSpeed;
		animSpeed = spd;
		
		if is_undefined(animInd)
		{
			show_debug_message("Error in SMF instance's function \"play\": Could not find animation " + string(animName));
			return -1;
		}
		if (!resetTimer && currAnimInd == animInd)
		{
			exit;
		}
		newAnimInd = animInd;
		newTimer = (1 - resetTimer) * frac(timer);
	}
	
	/// @func lerp_sample(inst1, inst2, amount) 
	static lerp_sample = function(inst1, inst2, amount) 
	{	//Linearly interpolates between the samples of the two instances, and saves it to the target instance
		SMFfastSampleTest
		sample_lerp(inst1.sample, inst2.sample, amount, sample);
	}
	
	/// @func splice_branch(sourceInst, nodeInd, weight) 
	static splice_branch = function(sourceInst, nodeInd, weight) 
	{	/*	This script lets you combine one bone and all its descendants from one sample into another.
			Useful if you've only animated parts of the rig in one sample.
	
			weight should be between 0 and 1. At 0, there will be no change to the sample. At 1, the branch will be copied from the source to the destination.
			Anything inbetween will interpolate linearly. Note that the interpolation may accidentally detach bones from their parents.*/
		SMFfastSampleTest
		sample_splice_branch(model.rig, nodeInd, sample, sourceInst.sample, weight);
	}
	
	/// @func node_yaw(node, degrees)
	static node_yaw = function(node, degrees)
	{	//Yaw a node around its up axis
		SMFfastSampleTest
		sample_node_yaw(model.rig, node, sample, degtorad(degrees), true);
	}
	
	/// @func node_pitch(node, degrees)
	static node_pitch = function(node, degrees)
	{	//Pitch a node around its side axis
		SMFfastSampleTest
		sample_node_pitch(model.rig, node, sample, degtorad(degrees), true);
	}
	
	/// @func node_roll(node, degrees)
	static node_roll = function(node, degrees)
	{	//Roll a node around its axis
		SMFfastSampleTest
		sample_node_roll(model.rig, node, sample, degtorad(degrees), true);
	}
	
	/// @func node_rotate(node, degrees, ax, ay, az)
	static node_rotate = function(node, degrees, ax, ay, az)
	{	//Rotates a node around a custom rig-space axis
		SMFfastSampleTest
		sample_node_rotate_axis(model.rig, node, sample, degtorad(degrees), ax, ay, az, true);
	}
	
	/// @func node_rotate_x(node, degrees)
	static node_rotate_x = function(node, degrees) 
	{	//Rotates a node around the rig-space x-axis
		SMFfastSampleTest
		sample_node_rotate_x(model.rig, node, sample, degtorad(degrees));
	}
	
	/// @func node_rotate_y(node, degrees)
	static node_rotate_y = function(node, degrees) 
	{	//Rotates a node around the rig-space y-axis
		SMFfastSampleTest
		sample_node_rotate_y(model.rig, node, sample, degtorad(degrees));
	}
	
	/// @func node_rotate_z(node, degrees)
	static node_rotate_z = function(node, degrees) 
	{	//Rotates a node around the rig-space z-axis
		SMFfastSampleTest
		sample_node_rotate_z(model.rig, node, sample, degtorad(degrees));
	}
	
	/// @func node_drag(node, xx, yy, zz, transformChildren) 
	static node_drag = function(node, xx, yy, zz, transformChildren) 
	{	/*	Move a node towards a given coordinate.
			Given coordinates must be in the same space as the rig, not in world space.
	
			If the selected node is representing a bone, it will be restrained by its parents.
			If both its parent and its grandparent are bones, a two-joint inverse kinematic operation is performed.*/
		SMFfastSampleTest
		sample_node_drag(model.rig, node, sample, xx, yy, zz, transformChildren);
	}
	
	/// @func node_move_ik(node, xx, yy, zz, moveFromCurrent, transformChildren) 
	static node_move_ik = function(node, xx, yy, zz, moveFromCurrent, transformChildren) 
	{	/*	Move a node towards a given coordinate.
			Given coordinates must be in the same space as the rig, not in world space.
	
			If the selected node is representing a bone, it will be restrained by its parents.
			If both its parent and its grandparent are bones, a two-joint inverse kinematic operation is performed.*/
		SMFfastSampleTest
		sample_node_move(model.rig, node, sample, xx, yy, zz, moveFromCurrent, transformChildren);
	}
	
	/// @func node_move_ik_fast(node, xx, yy, zz, moveFromCurrent, transformChildren) 
	static node_move_ik_fast = function(node, xx, yy, zz, moveFromCurrent, transformChildren) 
	{	/*	Move a node towards a given coordinate.
			Given coordinates must be in the same space as the rig, not in world space.
	
			If the selected node is representing a bone, it will be restrained by its parents.
			If both its parent and its grandparent are bones, a two-joint inverse kinematic operation is performed.*/
		SMFfastSampleTest
		sample_node_move_fast(model.rig, node, sample, xx, yy, zz, moveFromCurrent, transformChildren);
	}
	
	/// @func node_get_dq(node) 
	static node_get_dq = function(node)
	{	//Returns the current rig-space dual quaternion of the given node
		return sample_get_node_dq(model.rig, node, sample);
	}
	
	/// @func node_get_matrix(node) 
	static node_get_matrix = function(node) 
	{	//Returns the rig-space matrix of the given node
		return sample_get_node_matrix(model.rig, node, sample);
	}
	
	/// @func node_get_position(node) 
	static node_get_position = function(node) 
	{	/*Returns the rig-space position of the node as an array of the following format:
				[x, y, z];*/
		return sample_get_node_position(model.rig, node, sample);
	}
	
	/// @func get_animation() 
	static get_animation = function() 
	{	//Returns the instance's current animation
		if (currAnimInd < 0){
			return -1;}
		var animArray = model.animations;
		return animArray[currAnimInd];
	}
	
	/// @func get_animation_time()
	static get_animation_time = function()
	{
		//Returns the speed of the current animation
		var ind = (newAnimInd > 0) ? newAnimInd : currAnimInd;
		if (ind < 0){
			return 0;}
		var animArray = model.animations;
		var anim = animArray[ind];
		return (anim.playTime / 1000) * game_get_speed(gamespeed_fps);
	}
	
	/// @func fix()
	static fix = function()
	{
		SMFfastSampleTest
		return sample_fix(model.rig, sample);
	}
	
	/// @func normalize()
	static normalize = function()
	{
		SMFfastSampleTest
		return sample_normalize(sample);
	}
}

//Compatibility scripts
function smf_instance_create(model)
{
	return new smf_instance(model);
}
function smf_instance_play_animation(inst, animName, animSpeed, lerpSpeed, resetTimer) 
{
	inst.play(animName, animSpeed, lerpSpeed, resetTimer);
}
function smf_instance_lerp(inst1, inst2, amount, target) 
{
	target.lerp_sample(inst1, inst2, amount);
}
function smf_instance_splice_branch(targetInst, sourceInst, nodeInd, weight) 
{
	targetInst.splice_branch(sourceInst, nodeInd, weight);
}
function smf_instance_node_yaw(inst, node, degrees)
{
	inst.node_yaw(node, degrees);
}
function smf_instance_node_pitch(inst, node, degrees)
{
	inst.node_pitch(node, degrees);
}
function smf_instance_node_roll(inst, node, degrees)
{
	inst.node_roll(node, degrees);
}
function smf_instance_node_rotate_axis(inst, node, degrees, ax, ay, az) 
{
	inst.node_rotate(node, degrees, ax, ay, az);
}
function smf_instance_node_rotate_x(inst, node, degrees) 
{	
	inst.node_rotate_x(node, degrees) 
}
function smf_instance_node_rotate_y(inst, node, degrees) 
{
	inst.node_rotate_y(node, degrees) 
}
function smf_instance_node_rotate_z(inst, node, degrees) 
{
	inst.node_rotate_z(node, degrees) 
}
function smf_instance_node_drag(inst, node, xx, yy, zz, transformChildren) 
{
	inst.node_drag(node, xx, yy, zz, transformChildren);
}
function smf_instance_node_move_ik(inst, node, xx, yy, zz, moveFromCurrent, transformChildren) 
{
	inst.node_move_ik(node, xx, yy, zz, moveFromCurrent, transformChildren);
}
function smf_instance_node_move_ik_fast(inst, node, xx, yy, zz, moveFromCurrent, transformChildren) 
{
	inst.node_move_ik_fast(node, xx, yy, zz, moveFromCurrent, transformChildren) 
}
function smf_instance_step(inst, timeStep) 
{
	inst.step(timeStep);
}
function smf_instance_draw(inst) 
{
	inst.draw();
}
function smf_instance_enable_fast_sampling(inst, enable) 
{
	inst.fast_sampling(enable);
}
function smf_instance_set_animation_speed(inst, animSpeed) 
{
	inst.animSpeed = animSpeed;
}
function smf_instance_set_smooth(inst, smooth) 
{
	inst.smooth = smooth;
}
function smf_instance_set_timer(inst, timer) 
{
	inst.timer = timer;
}
function smf_instance_get_node_dq(inst, node) 
{
	return inst.node_get_dq(node);
}
function smf_instance_get_node_matrix(inst, node) 
{
	return inst.node_get_matrix(node);
}
function smf_instance_get_node_position(inst, node) 
{
	return inst.node_get_position(node);
}
function smf_instance_get_sample(inst) 
{
	return inst.sample;
}
function smf_instance_get_timer(inst) 
{
	return inst.timer;
}
function smf_instance_get_animation(inst) 
{
	return inst.get_animation();
}
function smf_instance_get_fast_sampling(inst) 
{
	return inst.fastSampling;
}