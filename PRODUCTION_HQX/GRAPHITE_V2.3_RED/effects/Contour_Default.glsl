// Full body (with contour) with breathing
// colorization variant made by Ermac
// Review 2022-01-26 for GRAPHITE_V2.x

#version 110

//---------------------VERTEX_SHADER---------------------
#ifdef VERTEX_SHADER

uniform mat4 ProjectionMatrix;
attribute vec2 InPosition;
attribute vec4 InColor;
attribute vec2 InTexCoord;

varying vec4 color;
varying vec2 texCoord;

void main() {
	gl_Position = ProjectionMatrix * vec4(InPosition, 0.0, 1.0);	
	color = InColor;
	texCoord = InTexCoord;
}

#endif
//-------------------------------------------------------

//--------------------FRAGMENT_SHADER--------------------
#ifdef FRAGMENT_SHADER
	 
uniform sampler2D ColorMap; // Main texture
uniform vec4 ColorMapSize; // Main texture size: x - width, y - height, z - texel width, w - texel height
uniform vec4 SpriteBorder; // Sprite border: x - left, y - top, z - right, w - bottom
uniform float TimeGame; // Current game time [0,120), in seconds, cycled
varying vec4 color;
varying vec2 texCoord;

const float OT = 1.5; // is OUTLINE THICKNESS
					// is non-negative decimal number 
const float AMOUNT = 0.5; // is sharpening amount
const float EXPOSURE = 2.0; // is exposure value
					
// Single pass Gaussian Blur coefficients
const float A = 0.123317;
const float B = 0.077847;
const float C = 0.195346;
		
// LUMA Coefficients		
const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

// calculate the average of nine surrounding pixels to get the blur, in RGBA			
vec4 texBlurRGBA() { 
	vec2 offset = OT * vec2(ColorMapSize.z, ColorMapSize.w);
	float west = clamp(texCoord.x - offset.x, SpriteBorder.x, SpriteBorder.z);
	float east = clamp(texCoord.x + offset.x, SpriteBorder.x, SpriteBorder.z);
	float north = clamp(texCoord.y - offset.y, SpriteBorder.y, SpriteBorder.w);
	float south = clamp(texCoord.y + offset.y, SpriteBorder.y, SpriteBorder.w);
	float x = clamp(texCoord.x, SpriteBorder.x, SpriteBorder.z);
	float y = clamp(texCoord.y, SpriteBorder.y, SpriteBorder.w);
	vec4 sum = A * (texture2D(ColorMap, vec2(west, y)) + // WEST
			   texture2D(ColorMap, vec2(east, y)) + // EAST
			   texture2D(ColorMap, vec2(x, north)) + // NORTH
			   texture2D(ColorMap, vec2(x, south))) +  // SOUTH			   
			   C * texture2D(ColorMap, vec2(x, y)) + // CENTER
			   B * (texture2D(ColorMap, vec2(west, north)) + // NORTHWEST
			   texture2D(ColorMap, vec2(east, south)) + // SOUTHEAST
			   texture2D(ColorMap, vec2(west, south)) + // SOUTHWEST
			   texture2D(ColorMap, vec2(east, north))); // NORTHEAST
	return sum;
}

// cvet effect from original file
vec3 cvet(vec2 texCoord, vec3 inCol) {
	vec3 outCol = inCol;
	float v = (texCoord.y - SpriteBorder.y) / (SpriteBorder.y - SpriteBorder.w);
	v += mod(1.75 * TimeGame, 2.0);
	if (v > 1.0) {
		v = 2.0 - v;
	} else if(v < 0.0) {
		v = -v;
	}
	outCol += v * 0.6 - 0.15;
	return outCol;
}

void main() {	
	vec4 texColor = texture2D(ColorMap, texCoord); // texture Color
	vec4 texBlur = texBlurRGBA(); // blurred texture Color 	
	float luma = dot(texColor.rgb, LUMA);
	
	// A) in case texture Color is opaque			
	if (texColor.a == 1.0) {
		// substract the blur to get the sharpness	
		vec3 shpColor = color.rgb  * (texColor.rgb + (texColor.rgb - texBlur.rgb) * AMOUNT); 								
		vec3 hdrColor = shpColor.rgb + shpColor.rgb * vec3(luma) / (vec3(1.0) + vec3(luma));	
		gl_FragColor.rgb = 2.0 * cvet(texCoord, hdrColor);
		gl_FragColor.a = 1.0;
	// B) and if it's not opaque and edge is detected			
	} else if (texColor.a < 1.0 && texBlur.a >= 0.2) {				
		vec3 hdrColor = color.rgb + color.rgb * vec3(luma) / (vec3(1.0) + vec3(luma));		
		gl_FragColor.rgb = 2.0 * cvet(texCoord, hdrColor);
		gl_FragColor.a = 1.0;
	// C) we're far from edge
	} else { 
		gl_FragColor = texColor;
	}	
}

#endif
//-------------------------------------------------------