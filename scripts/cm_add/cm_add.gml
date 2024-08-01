////////////////////////////////////////
// -- Add object to the given container --
var default_function = function(container, object)
{
	cm_debug_message("Function cm_add: Trying to add object to a primitive. The primitive is converted to a cm_list!");
	var primitive = [];
	array_copy(primitive, 0, container, 0, array_length(container));
	array_resize(container, CM_LIST_NUM);
	container[0] = CM_OBJECTS.LIST;
	cm_add(container, primitive);
	cm_add(container, object);
	return object;
}
global.__cmi_container_add = array_create(CM_OBJECTS.NUM, default_function);
global.__cmi_container_add[CM_OBJECTS.DYNAMIC]		= function(dynamic, object){CM_DYNAMIC_OBJECT = object;};
global.__cmi_container_add[CM_OBJECTS.LIST]			= cm_list_add;
global.__cmi_container_add[CM_OBJECTS.SPATIALHASH]	= cm_spatialhash_add;
global.__cmi_container_add[CM_OBJECTS.QUADTREE]		= cm_quadtree_add;
global.__cmi_container_add[CM_OBJECTS.OCTREE]		= cm_octree_add;
global.__cmi_container_add[CM_OBJECTS.FLSSTRIANGLE]	= default_function;
global.__cmi_container_add[CM_OBJECTS.FLDSTRIANGLE]	= default_function;
global.__cmi_container_add[CM_OBJECTS.SMSSTRIANGLE]	= default_function;
global.__cmi_container_add[CM_OBJECTS.SMDSTRIANGLE]	= default_function;
global.__cmi_container_add[CM_OBJECTS.SPHERE]		= default_function;
global.__cmi_container_add[CM_OBJECTS.CAPSULE]		= default_function;
global.__cmi_container_add[CM_OBJECTS.CYLINDER]		= default_function;
global.__cmi_container_add[CM_OBJECTS.AAB]			= default_function;
global.__cmi_container_add[CM_OBJECTS.BOX]			= default_function;
global.__cmi_container_add[CM_OBJECTS.DISK]			= default_function;
global.__cmi_container_add[CM_OBJECTS.TORUS]		= default_function;
#macro CM_CONTAINER_ADD global.__cmi_container_add[container[0]]
function cm_add(container, object)
{
	if (!is_array(object)){return false;}
	return CM_CONTAINER_ADD(container, object);
}