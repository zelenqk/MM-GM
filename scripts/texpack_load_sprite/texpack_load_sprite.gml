/// @description texpack_load_sprite(fname)
/// @param fname
function texpack_load_sprite(argument0) {
	var fname, ext, spr;
	fname = argument0;

	spr = -1;
	ext = string_lower(filename_ext(fname));
	switch ext
	{
		case ".jpg":
		case ".jpeg":
		case ".gif":
		case ".png":
			spr = sprite_add(fname, 0, true, 0, 0, 0);
			break;
		case ".bmp":
			spr = _load_bmp(fname);
			break;
	}

	global.TexMapExternalSprite[? spr] = true;

	return spr;


}
