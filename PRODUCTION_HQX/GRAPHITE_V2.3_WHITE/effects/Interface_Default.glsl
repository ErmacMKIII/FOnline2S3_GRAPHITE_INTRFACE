// Interface effects made by Ermac
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
varying vec4 color;
varying vec2 texCoord;

// LUMA Coefficients
const vec3 LUMA = vec3(0.299, 0.587, 0.114);

void main() {
	vec4 texColor = texture2D(ColorMap, texCoord); // texture Color	
	float luma = dot(color.rgb * texColor.rgb, LUMA);
	
	vec3 originColor = color.rgb * texColor.rgb; // originalColor
	vec3 hdrColor = originColor + originColor * vec3(luma) / (vec3(1.0) + vec3(luma));
	
	gl_FragColor.rgb = 2.0 * hdrColor; // increase contrast (default)
	gl_FragColor.a = color.a * texColor.a; // keep the alpha		
}

#endif
//-------------------------------------------------------