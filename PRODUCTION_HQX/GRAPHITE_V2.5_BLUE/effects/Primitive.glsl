// Primitive.glsl (weapon and range sight lines) edited by Ermac
// Review 2019-03-28
#version 110

//---------------------VERTEX_SHADER---------------------
#ifdef VERTEX_SHADER

uniform mat4 ProjectionMatrix;
attribute vec2 InPosition;
attribute vec4 InColor;

varying vec4 color;

void main() {
	gl_Position = ProjectionMatrix * vec4(InPosition, 0.0, 1.0);	
	color = InColor;	
}

#endif
//-------------------------------------------------------

//--------------------FRAGMENT_SHADER--------------------
#ifdef FRAGMENT_SHADER

varying vec4 color; // is parsed color (from the vertex shader) - important!
// this is value we're going to need to increase thickness of the line
const float SPEC = 80.0 / 255.0; 

void main() { 
	// *this demonstrates both inverting the color of weapon and sight range	
	// and increasing it's line thickness*
	
	// A) in case it's red color for weapon range
	if (color.r == 1.0 && color.g == 0.0 && color.b == 0.0) {
		gl_FragColor.rgb = vec3(1.0) - color.rgb; // invert the color
		if (color.a == SPEC) { // increase the thickness		
			gl_FragColor.a = 1.0;
		} else {
			gl_FragColor.a = color.a;
		}
	// B) otherwise in case it's green color for sight range	
	} else if (color.r == 0.0 && color.g == 1.0 && color.b == 0.0) {
		gl_FragColor.rgb = vec3(1.0) - color.rgb; // invert the color
		if (color.a == SPEC) {	// increase the thickness	
			gl_FragColor.a = 1.0;
		} else {
			gl_FragColor.a = color.a;
		}
	// C) in case of Fog of War
	} else if (color.r == 0.0 && color.g == 0.0 && color.b == 0.0 && color.a == SPEC) {
		gl_FragColor.rgb = vec3(SPEC / 2.0);
		gl_FragColor.a = 2.0 * SPEC;
	// D) in neither of these cases keep the color		
	} else {
		gl_FragColor = color;
	}	
}

#endif
//-------------------------------------------------------