/*////////////////////////////////////////////////////////////////////////
    SMF static fragment shader
    This is the standard shader that comes with the SMF system.
    This does some basic diffuse, specular and rim lighting.
	
	
	EDITED TO DRAW SMF OBJECTS WITH A CUSTOM COLOR 
*/////////////////////////////////////////////////////////////////////////

varying vec2 v_vTexcoord;
varying vec3 v_eyeVec;
varying vec3 v_vNormal;
varying float v_vRim;

uniform vec4 u_uColor;

void main(){
	gl_FragColor = u_uColor;
}
