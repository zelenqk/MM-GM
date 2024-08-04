// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_convert_smf(model){
	//This script was requested by somebody on the forums.
	//Creates a ColMesh-compatible buffer from an SMF model.
	//Remember to destroy the buffer after you're done using it!
	var mBuff = model.mBuff;
	var num = array_length(mBuff);
	
	var newBuff = buffer_create(1, buffer_grow, 1);
	var size = 0;
	
	//Convert to ColMesh-compatible format
	var num = array_length(mBuff);
	var SMFbytesPerVert = 44;
	var targetBytesPerVert = 36;
	for (var m = 0; m < num; m ++){
		var buff = mBuff[m];
		var buffSize = buffer_get_size(buff);
		var vertNum = buffSize div SMFbytesPerVert;
		for (var i = 0; i < vertNum; i ++){
			//Copy position and normal
			buffer_copy(buff, i * SMFbytesPerVert, targetBytesPerVert, newBuff, size + i * targetBytesPerVert);
		}
		size += buffSize * targetBytesPerVert / SMFbytesPerVert;
	}
	
	buffer_resize(newBuff, size);
	return newBuff;
}