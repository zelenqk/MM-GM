/// @description mbuff_add(target, source)
/// @param target
/// @param source
function mbuff_add(trg, src) {
	/*
		Returns a new array containing both source and target arrays
	
		Script created by TheSnidr, 2019
		www.TheSnidr.com
	*/
	var trgNum = array_length(trg);
	var srcNum = array_length(src);
	array_copy(trg, trgNum, src, 0, srcNum);

	return trg;
}
