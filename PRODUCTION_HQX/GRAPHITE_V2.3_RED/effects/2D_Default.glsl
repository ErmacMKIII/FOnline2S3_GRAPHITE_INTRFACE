// Game sprite effects with egg made by Ermac
// Review 2022-01-26 for GRAPHITE_V2.x

#version 110

//---------------------VERTEX_SHADER---------------------
#ifdef VERTEX_SHADER

uniform mat4 ProjectionMatrix;
attribute vec2 InPosition;
attribute vec4 InColor;
attribute vec2 InTexCoord;
attribute vec2 InTexEggCoord;

varying vec4 color;
varying vec2 texCoord;
varying vec2 texEggCoord;

void main() {
	gl_Position = ProjectionMatrix * vec4(InPosition, 0.0, 1.0);	
	color = InColor;
	texCoord = InTexCoord;
	texEggCoord = InTexEggCoord;
}

#endif
//-------------------------------------------------------

//--------------------FRAGMENT_SHADER--------------------
#ifdef FRAGMENT_SHADER

#extension GL_EXT_gpu_shader4 : enable

uniform sampler2D ColorMap; // Main texture
uniform vec4 ColorMapSize; // Main texture size: x - width, y - height, z - texel width, w - texel height
uniform sampler2D EggMap; // Egg texture
uniform float TimeGame; // Current game time [0,120), in seconds, cycled
varying vec4 color;
varying vec2 texCoord;
varying vec2 texEggCoord;

const float AMOUNT = 1.0; // is sharpening amount

// Single pass Gaussian Blur coefficients
const float A = 0.123317;
const float B = 0.077847;
const float C = 0.195346;

// LUMA Coefficients
const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

// calculate the average of nine surrounding pixels to get the blur, in RGBA
vec4 texBlurRGBA() { 
	vec2 offset = vec2(ColorMapSize.z, ColorMapSize.w);
	vec4 sum = A * (texture2D(ColorMap, vec2(texCoord.x - offset.x, texCoord.y)) +	// WEST
			   texture2D(ColorMap, vec2(texCoord.x + offset.x, texCoord.y)) + // EAST
			   texture2D(ColorMap, vec2(texCoord.x, texCoord.y - offset.y)) +	// NORTH
			   texture2D(ColorMap, vec2(texCoord.x, texCoord.y + offset.y))) +  // SOUTH			   
			   C * texture2D(ColorMap, texCoord) + // CENTER
			   B * (texture2D(ColorMap, vec2(texCoord.x - offset.x, texCoord.y - offset.y)) + // NORTHWEST
			   texture2D(ColorMap, vec2(texCoord.x + offset.x, texCoord.y + offset.y)) + // SOUTHEAST
			   texture2D(ColorMap, vec2(texCoord.x - offset.x, texCoord.y + offset.y)) + // SOUTHWEST
			   texture2D(ColorMap, vec2(texCoord.x + offset.x, texCoord.y - offset.y))); // NORTHEAST
	return sum;
}

void main() {
	vec4 texColor = texture2D(ColorMap, texCoord); // texture Color
	vec4 texBlur = texBlurRGBA(); // blurred texture Color 			
	float luma = dot(color.rgb * texColor.rgb, LUMA);
	
	vec3 shpColor = color.rgb * (texColor.rgb + (texColor.rgb - texBlur.rgb) * AMOUNT); // substract the blur to get the sharpness	
	vec3 hdrColor = shpColor + shpColor * vec3(luma) / (vec3(1.0) + vec3(luma));
	
	gl_FragColor.rgb = 2.0 * hdrColor; // increase contrast (default)
	gl_FragColor.a = color.a * texColor.a; // keep the alpha	
	
	if (texEggCoord.x > 0.0 || texEggCoord.y > 0.0) { // apply the egg
		vec4 eggColor = texture2D(EggMap, texEggCoord);
			// absolute cosine is breathing effect		
		gl_FragColor.rgb += eggColor.rgb * abs(cos(1.75 * TimeGame)); 		
		gl_FragColor.a *= eggColor.a * (1.0 + abs(cos(1.75 * TimeGame)));
	}
}
#endif
//-------------------------------------------------------