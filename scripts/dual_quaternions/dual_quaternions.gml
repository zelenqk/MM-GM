function smf_dq_create(radians, ax, ay, az, x, y, z) 
{
	//Creates a dual quaternion from axis angle and a translation vector
	//Source: http://en.wikipedia.org/wiki/Dual_quaternion
	var c, s;
	radians *= .5;
	var c = cos(radians);
	var s = sin(radians);
	ax *= s;
	ay *= s;
	az *= s;

	return [ax, ay, az, c,
			.5 * (x * c + y * az - z * ax),
			.5 * (y * c + z * ax - x * az),
			.5 * (z * c + x * ay - y * ax),
			.5 * (- x * ax - y * ay - z * az)];
}

/// @func smf_dq_create_from_matrix(M, targetDQ)
function smf_dq_create_from_matrix(M, DQ) 
{	
	//---------------Create dual quaternion from a matrix
	//Source: http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
	//Creates a dual quaternion from a matrix
	var T = 1 + M[0] + M[5] + M[10]
	if (T > 0.)
	{
	    var S = sqrt(T) * 2;
	    DQ[@ 0] = (M[9] - M[6]) / S;
	    DQ[@ 1] = (M[2] - M[8]) / S;
	    DQ[@ 2] = (M[4] - M[1]) / S;
	    DQ[@ 3] = -0.25 * S;  //I have modified this
	}
	else if (M[0] > M[5] && M[0] > M[10])
	{// Column 0: 
	   var S = sqrt(max(0., 1.0 + M[0] - M[5] - M[10])) * 2;
	    DQ[@ 0] = 0.25 * S;
	    DQ[@ 1] = (M[4] + M[1]) / S;
	    DQ[@ 2] = (M[2] + M[8]) / S;
	    DQ[@ 3] = (M[9] - M[6]) / S;
	} 
	else if (M[5] > M[10])
	{// Column 1: 
	    var S = sqrt(max(0., 1.0 + M[5] - M[0] - M[10])) * 2;
	    DQ[@ 0] = (M[4] + M[1]) / S;
	    DQ[@ 1] = 0.25 * S;
	    DQ[@ 2] = (M[9] + M[6]) / S;
	    DQ[@ 3] = (M[2] - M[8]) / S;
	} 
	else 
	{// Column 2:
		var S  = sqrt(max(0., 1.0 + M[10] - M[0] - M[5])) * 2;
	    DQ[@ 0] = (M[2] + M[8]) / S;
	    DQ[@ 1] = (M[9] + M[6]) / S;
	    DQ[@ 2] = 0.25 * S;
	    DQ[@ 3] = (M[4] - M[1]) / S;
	}
	DQ[@ 4] = .5 * (M[12] * DQ[3] + M[13] * DQ[2] - M[14] * DQ[1]);
	DQ[@ 5] = .5 * (M[13] * DQ[3] + M[14] * DQ[0] - M[12] * DQ[2]);
	DQ[@ 6] = .5 * (M[14] * DQ[3] + M[12] * DQ[1] - M[13] * DQ[0]);
	DQ[@ 7] =-.5 * (M[12] * DQ[0] + M[13] * DQ[1] + M[14] * DQ[2]);
	return DQ;
}
function smf_dq_duplicate(DQ) 
{	//Duplicates the given dual quaternion and returns the index of the new one
	var Q = array_create(8);
	array_copy(Q, 0, DQ, 0, 8);
	return Q;
}
function smf_dq_get_conjugate(DQ, targetDQ = array_create(8))
{
	targetDQ[@ 0] = -DQ[0];
	targetDQ[@ 1] = -DQ[1];
	targetDQ[@ 2] = -DQ[2];
	targetDQ[@ 3] =  DQ[3];
	targetDQ[@ 4] = -DQ[4];
	targetDQ[@ 5] = -DQ[5];
	targetDQ[@ 6] = -DQ[6];
	targetDQ[@ 7] =  DQ[7];
	return targetDQ;
}
function smf_dq_get_translation(DQ) 
{//Returns the translation of a given dual quaternion
	gml_pragma("forceinline");
	var q0 = DQ[0], q1 = DQ[1], q2 = DQ[2], q3 = DQ[3], q4 = DQ[4], q5 = DQ[5], q6 = DQ[6], q7 = DQ[7];
	return [2 * (-q7 * q0 + q4 * q3 + q6 * q1 - q5 * q2), 
			2 * (-q7 * q1 + q5 * q3 + q4 * q2 - q6 * q0), 
			2 * (-q7 * q2 + q6 * q3 + q5 * q0 - q4 * q1)];
}
function smf_dq_get_x(DQ) {
	//Returns the x component of the translation of a given dual quaternion
	gml_pragma("forceinline");
	return 2 * (-DQ[7] * DQ[0] + DQ[4] * DQ[3] + DQ[6] * DQ[1] - DQ[5] * DQ[2]);
}
function smf_dq_get_y(DQ) 
{	//Returns the y component of the translation of a given dual quaternion
	gml_pragma("forceinline");
	return 2 * (-DQ[7] * DQ[1] + DQ[5] * DQ[3] + DQ[4] * DQ[2] - DQ[6] * DQ[0]);
}
function smf_dq_get_z(DQ) 
{	//Returns the z component of the translation of a given dual quaternion
	gml_pragma("forceinline");
	return 2 * (-DQ[7] * DQ[2] + DQ[6] * DQ[3] + DQ[5] * DQ[0] - DQ[4] * DQ[1]);
}
function smf_dq_invert(DQ, targetDQ = DQ) 
{
	targetDQ[@ 0] = -DQ[0];
	targetDQ[@ 1] = -DQ[1];
	targetDQ[@ 2] = -DQ[2];
	targetDQ[@ 3] = -DQ[3];
	targetDQ[@ 4] = -DQ[4];
	targetDQ[@ 5] = -DQ[5];
	targetDQ[@ 6] = -DQ[6];
	targetDQ[@ 7] = -DQ[7];
	return targetDQ;
}
function smf_dq_lerp(DQ1, DQ2, amount, targetDQ = array_create(8)) 
{
	targetDQ[@ 0] = lerp(DQ1[0], DQ2[0], amount);
	targetDQ[@ 1] = lerp(DQ1[1], DQ2[1], amount);
	targetDQ[@ 2] = lerp(DQ1[2], DQ2[2], amount);
	targetDQ[@ 3] = lerp(DQ1[3], DQ2[3], amount);
	targetDQ[@ 4] = lerp(DQ1[4], DQ2[4], amount);
	targetDQ[@ 5] = lerp(DQ1[5], DQ2[5], amount);
	targetDQ[@ 6] = lerp(DQ1[6], DQ2[6], amount);
	targetDQ[@ 7] = lerp(DQ1[7], DQ2[7], amount);
	return targetDQ;
}
function smf_dq_multiply(R, S, targetDQ = array_create(8)) 
{
	//Multiplies two dual quaternions and outputs the result to target
	//R * S = (A * C, A * D + B * C)
	var r0 = R[0], r1 = R[1], r2 = R[2], r3 = R[3], r4 = R[4], r5 = R[5], r6 = R[6], r7 = R[7];
	var s0 = S[0], s1 = S[1], s2 = S[2], s3 = S[3], s4 = S[4], s5 = S[5], s6 = S[6], s7 = S[7];
	targetDQ[@ 0] = r3 * s0 + r0 * s3 + r1 * s2 - r2 * s1;
	targetDQ[@ 1] = r3 * s1 + r1 * s3 + r2 * s0 - r0 * s2;
	targetDQ[@ 2] = r3 * s2 + r2 * s3 + r0 * s1 - r1 * s0;
	targetDQ[@ 3] = r3 * s3 - r0 * s0 - r1 * s1 - r2 * s2;
	targetDQ[@ 4] = r3 * s4 + r0 * s7 + r1 * s6 - r2 * s5 + r7 * s0 + r4 * s3 + r5 * s2 - r6 * s1;
	targetDQ[@ 5] = r3 * s5 + r1 * s7 + r2 * s4 - r0 * s6 + r7 * s1 + r5 * s3 + r6 * s0 - r4 * s2;
	targetDQ[@ 6] = r3 * s6 + r2 * s7 + r0 * s5 - r1 * s4 + r7 * s2 + r6 * s3 + r4 * s1 - r5 * s0;
	targetDQ[@ 7] = r3 * s7 - r0 * s4 - r1 * s5 - r2 * s6 + r7 * s3 - r4 * s0 - r5 * s1 - r6 * s2;
	return targetDQ;
}
function smf_dq_normalize(DQ, targetDQ = DQ)
{
	var q0 = DQ[0], q1 = DQ[1], q2 = DQ[2], q3 = DQ[3], q4 = DQ[4], q5 = DQ[5], q6 = DQ[6], q7 = DQ[7];
	var l = 1 / sqrt(q0 * q0 + q1 * q1 + q2 * q2 + q3 * q3);
	targetDQ[@ 0] = q0 * l
	targetDQ[@ 1] = q1 * l
	targetDQ[@ 2] = q2 * l
	targetDQ[@ 3] = q3 * l
	var d = l * (q0 * q4 + q1 * q5 + q2 * q6 + q3 * q7);
	targetDQ[@ 4] = (q4 - q0 * d) * l;
	targetDQ[@ 5] = (q5 - q1 * d) * l;
	targetDQ[@ 6] = (q6 - q2 * d) * l;
	targetDQ[@ 7] = (q7 - q3 * d) * l;
	return targetDQ;
}
function smf_dq_quadratic_interpolate(A, B, C, amount, targetDQ = array_create(8)) 
{
	var t0 = .5 * sqr(1 - amount);
	var t1 = .5 * amount * amount;
	var t2 = 2 * amount * (1 - amount);
	var b0 = B[0], b1 = B[1], b2 = B[2], b3 = B[3], b4 = B[4], b5 = B[5], b6 = B[6], b7 = B[7];
	targetDQ[@ 0] = t0 * (A[0] + b0) + t1 * (b0 + C[0]) + t2 * b0;
	targetDQ[@ 1] = t0 * (A[1] + b1) + t1 * (b1 + C[1]) + t2 * b1;
	targetDQ[@ 2] = t0 * (A[2] + b2) + t1 * (b2 + C[2]) + t2 * b2;
	targetDQ[@ 3] = t0 * (A[3] + b3) + t1 * (b3 + C[3]) + t2 * b3;
	targetDQ[@ 4] = t0 * (A[4] + b4) + t1 * (b4 + C[4]) + t2 * b4;
	targetDQ[@ 5] = t0 * (A[5] + b5) + t1 * (b5 + C[5]) + t2 * b5;
	targetDQ[@ 6] = t0 * (A[6] + b6) + t1 * (b6 + C[6]) + t2 * b6;
	targetDQ[@ 7] = t0 * (A[7] + b7) + t1 * (b7 + C[7]) + t2 * b7;
	return targetDQ;
}
function smf_dq_set_translation(DQ, x, y, z) 
{
	DQ[@ 4] = .5 * (x * DQ[3] + y * DQ[2] - z * DQ[1]); 
	DQ[@ 5] = .5 * (y * DQ[3] + z * DQ[0] - x * DQ[2]);
	DQ[@ 6] = .5 * (z * DQ[3] + x * DQ[1] - y * DQ[0]); 
	DQ[@ 7] =-.5 * (x * DQ[0] + y * DQ[1] + z * DQ[2]);
}