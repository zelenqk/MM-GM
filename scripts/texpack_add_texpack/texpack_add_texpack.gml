/// @description texpack_add_texpack(target, source)
/// @param target
/// @param source
function texpack_add_texpack(trg, src) 
{
	var trgNum = array_length(trg);
	var srcNum = array_length(src);
	array_copy(trg, trgNum, src, 0, srcNum);
	return trg;
}