
function smf_vector_cross(u, v) 
{
	gml_pragma("forceinline");
	return [u[1] * v[2] - u[2] * v[1],
			u[2] * v[0] - u[0] * v[2],
			u[0] * v[1] - u[1] * v[0]];
}
function smf_vector_dot(u, v) 
{
	gml_pragma("forceinline");
	return u[0]*v[0] + u[1]*v[1] + u[2]*v[2];
}
function smf_vector_normalize(v) 
{
	//Returns the unit vector with the same direction
	//Also returns the length of the original vector
	gml_pragma("forceinline");
	var l = v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
	if l == 0{return [0, 0, 1, 0];}
	l = sqrt(l);
	var j = 1 / l;
	return [v[0] * j, v[1] * j, v[2] * j, l];
}
function smf_vector_orthogonalize(n, v) 
{
	gml_pragma("forceinline");
	var l = n[0] * v[0] + n[1] * v[1] + n[2] * v[2];
	return [v[0] - n[0] * l,
			v[1] - n[1] * l,
			v[2] - n[2] * l];
}
function smf_vector_rotate(v, axis, radians) 
{
	//Rotates the vector v around the given axis using Rodrigues' Rotation Formula
	var a = axis;
	var c = cos(radians);
	var s = sin(radians);
	var d = (1 - c) * (a[0] * v[0] + a[1] * v[1] + a[2] * v[2]);
	return [v[0] * c + a[0] * d + (a[1] * v[2] - a[2] * v[1]) * s,
			v[1] * c + a[1] * d + (a[2] * v[0] - a[0] * v[2]) * s,
			v[2] * c + a[2] * d + (a[0] * v[1] - a[1] * v[0]) * s]


}

function smf_cast_ray_sphere(sx, sy, sz, r, x1, y1, z1, x2, y2, z2, doublesided = false) 
{	
	/*	
		Finds the intersection between a line segment going from [x1, y1, z1] to [x2, y2, z2], and a sphere centered at (sx,sy,sz) with radius r.
		Returns false if the ray hits the sphere but the line segment is too short,
		returns true if the ray misses completely, 
		returns an array of the following format if there was and intersection between the line segment and the sphere:
			[x, y, z]
	*/
	var dx = sx - x1;
	var dy = sy - y1;
	var dz = sz - z1;

	var vx = x2 - x1;
	var vy = y2 - y1;
	var vz = z2 - z1;

	//dp is now the distance from the starting point to the plane perpendicular to the ray direction, times the length of dV
	var v = dot_product_3d(vx, vy, vz, vx, vy, vz);
	var d = dot_product_3d(dx, dy, dz, dx, dy, dz);
	var t = dot_product_3d(vx, vy, vz, dx, dy, dz);

	//u is the remaining distance from this plane to the surface of the sphere, times the length of dV
	var u = t * t + v * (r * r - d);

	//If u is less than 0, there is no intersection
	if (u < 0)
	{
		return -1;
	}
	
	u = sqrt(max(u, 0));
	if (t < u)
	{
		if (!doublesided)
		{
			return -1;
		}
		//Project to the inside of the sphere
		t += u; 
		if (t < 0)
		{
			//The sphere is behind the ray
			return -1;
		}
	}
	else
	{
		//Project to the outside of the sphere
		t -= u;
		if (t > v)
		{
			//The sphere is too far away
			return -1;
		}
	}
	
	t /= v;
	static ret = array_create(3);
	ret[0] = x1 + vx * t;
	ret[1] = y1 + vy * t;
	ret[2] = z1 + vz * t;
	return ret;
}