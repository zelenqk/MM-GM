enum CM_DYNAMIC
{
	TYPE,
	GROUP,
	AABB, 
	AABBPREV,
	OBJECT,
	M, 
	I, 
	P,
	SCALEX,
	SCALEY,
	SCALEZ,
	MOVING,
	NUM
}

#macro CM_DYNAMIC_BEGIN		var dynamic = array_create(CM_DYNAMIC.NUM, CM_OBJECTS.DYNAMIC)
#macro CM_DYNAMIC_TYPE		dynamic[@ CM_DYNAMIC.TYPE]
#macro CM_DYNAMIC_GROUP		dynamic[@ CM_DYNAMIC.GROUP]
#macro CM_DYNAMIC_OBJECT	dynamic[@ CM_DYNAMIC.OBJECT]
#macro CM_DYNAMIC_M			dynamic[@ CM_DYNAMIC.M]
#macro CM_DYNAMIC_I			dynamic[@ CM_DYNAMIC.I]
#macro CM_DYNAMIC_P			dynamic[@ CM_DYNAMIC.P]
#macro CM_DYNAMIC_SCALE_X		dynamic[@ CM_DYNAMIC.SCALEX]
#macro CM_DYNAMIC_SCALE_Y		dynamic[@ CM_DYNAMIC.SCALEY]
#macro CM_DYNAMIC_SCALE_Z		dynamic[@ CM_DYNAMIC.SCALEZ]
#macro CM_DYNAMIC_MOVING	dynamic[@ CM_DYNAMIC.MOVING]
#macro CM_DYNAMIC_AABB		dynamic[@ CM_DYNAMIC.AABB]
#macro CM_DYNAMIC_AABBPREV	dynamic[@ CM_DYNAMIC.AABBPREV]
#macro CM_DYNAMIC_UPDATE	cm_dynamic_set_matrix(dynamic, matrix, moving)
#macro CM_DYNAMIC_END		return dynamic
									
function cm_dynamic(object, matrix, moving = false, group = CM_GROUP_SOLID)
{
	CM_DYNAMIC_BEGIN;
	CM_DYNAMIC_GROUP = group;
	CM_DYNAMIC_OBJECT = object;
	CM_DYNAMIC_M = matrix_build_identity(); //World matrix
	CM_DYNAMIC_I = matrix_build_identity(); //Inverse world matrix
	CM_DYNAMIC_P = matrix_build_identity(); //Previous inverse world matrix
	CM_DYNAMIC_MOVING = moving;
	CM_DYNAMIC_SCALE_X = 1;
	CM_DYNAMIC_SCALE_Y = 1;
	CM_DYNAMIC_SCALE_Z = 1;
	CM_DYNAMIC_AABB = array_create(6);
	CM_DYNAMIC_AABBPREV = array_create(6);
	CM_DYNAMIC_UPDATE;
	CM_DYNAMIC_END;
} 