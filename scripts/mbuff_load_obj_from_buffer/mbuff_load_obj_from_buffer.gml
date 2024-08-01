/// @description mbuff_load_obj_from_buffer(fname, load_textures)
/// @param fname
/// @param load_textures
function mbuff_load_obj_from_buffer(buffer, path = "", load_textures = true) {
	/*
		Loads an OBJ file and returns an array containing the following:
		[mBuff, texPack]
	
		Script created by TheSnidr, 2019
		www.thesnidr.com
	*/
	var currentMaterial = "Default";
	var materialList = ds_list_create();
	var mtlFname = "";

	//Create the necessary lists
	var V, N, T, Fa, F, m, ind;
	var V = ds_list_create();
	var N = ds_list_create();
	var T = ds_list_create();
	Fa[0] = ds_list_create();

	//Read .obj as textfile
	var file = buffer_read(buffer, buffer_string);
	while true
	{
		var pos = string_pos("\n", file);
		var str = string_copy(file, 1, pos);
		if (str == "")
		{
			break;
		}
		file = string_delete(file, 1, pos);
		str = string_replace_all(str,"  "," ");
		
		//Different types of information in the .obj starts with different headers
		switch string_copy(str, 1, 2)
		{
			//Load name of MTL library
			case "mt":
				mtlFname = string_delete(str, 1, string_pos(" ", str));
				mtlFname = filename_name(mtlFname);
				while string_count(".", mtlFname){
					mtlFname = filename_change_ext(mtlFname, "");}
				mtlFname += ".mtl";
				break;
			//Load vertex positions
			case "v ":
				ds_list_add(V, _mbuff_read_obj_line(str));
				break;
			//Load vertex normals
			case "vn":
				ds_list_add(N, _mbuff_read_obj_line(str));
				break;
			//Load vertex texture coordinates
			case "vt":
				ds_list_add(T, _mbuff_read_obj_line(str));
				break;
			//Load material name
			case "us":
				currentMaterial = string_delete(str, 1, string_pos(" ", str));
				if (ds_list_find_index(materialList, currentMaterial) < 0)
				{
					ds_list_add(materialList, currentMaterial);
					ind = ds_list_find_index(materialList, currentMaterial);
					Fa[ind] = ds_list_create();
				}
				break;
			//Load faces
			case "f ":
				m = max(ds_list_find_index(materialList, currentMaterial), 0);
				_mbuff_read_obj_face(Fa[m], str);
				break;
		}
	}

	//Loop through the loaded information and generate a mesh
	var bytesPerVert, modelNum, vnt, vertNum, mBuff, v, n, t;
	bytesPerVert = mBuffBytesPerVert;
	modelNum = array_length(Fa);
	mBuff = array_create(modelNum);
	for (var m = 0; m < modelNum; m ++)
	{
		F = Fa[m];
		vertNum = ds_list_size(F);
		mBuff[m] = buffer_create(vertNum * bytesPerVert, buffer_fixed, 1);
		for (var f = 0; f < vertNum; f ++)
		{
			vnt = F[| f];
		
			//Add the vertex to the model buffer
			v = V[| vnt[0]];
			if !is_array(v){v = [0, 0, 0];}
			buffer_write(mBuff[m], buffer_f32, v[0]);
			buffer_write(mBuff[m], buffer_f32, v[2]);
			buffer_write(mBuff[m], buffer_f32, v[1]);
		
			//Vertex normal
			n = N[| vnt[1]];
			if !is_array(n){n = [0, 0, 1];}
			buffer_write(mBuff[m], buffer_f32, n[0]);
			buffer_write(mBuff[m], buffer_f32, n[2]);
			buffer_write(mBuff[m], buffer_f32, n[1]);
		
			//Vertex UVs
			t = T[| vnt[2]];
			if !is_array(t){t = [.5, .5];}
			buffer_write(mBuff[m], buffer_f32, t[0]);
			buffer_write(mBuff[m], buffer_f32, 1-t[1]);
			
			//Auxiliary attributes
			buffer_write(mBuff[m], buffer_u32, c_white); //Colour, white by default
			buffer_write(mBuff[m], buffer_u32, 0); //Bone indices
			buffer_write(mBuff[m], buffer_u32, 1); //Bone weights
		}
	}

	//Copy the contents of the materialList over to an array
	n = ds_list_size(materialList);
	var mtlNames = array_create(n);
	for (var i = 0; i < n; i ++)
	{
		mtlNames[i] = materialList[| i];
	}

	ds_list_destroy(F);
	ds_list_destroy(V);
	ds_list_destroy(N);
	ds_list_destroy(T);
	ds_list_destroy(materialList);

	//Load MTL file
	var texPack = [];
	if load_textures
	{
		var mtlPath = filename_path(path) + filename_name(mtlFname);
		texPack = texpack_load_mtl(mtlPath, mtlNames);
	}

	//Return array containing the mBuff array, the name of the mtl file and the names of the materials of the submodels
	return [mBuff, texPack];
}
