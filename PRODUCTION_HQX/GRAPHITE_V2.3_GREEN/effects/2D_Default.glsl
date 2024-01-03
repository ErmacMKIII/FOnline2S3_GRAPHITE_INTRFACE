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

uniform sampler2D ColorMap; // Main texture
uniform vec4 ColorMapSize; // Main texture size: x - width, y - height, z - texel width, w - texel height
uniform sampler2D EggMap; // Egg texture
uniform float TimeGame; // Current game time [0,120), in seconds, cycled
varying vec4 color;
varying vec2 texCoord;
varying vec2 texEggCoord;

// LUMA Coefficients
const vec3 LUMA = vec3(0.299, 0.587, 0.114);

void main() {
	vec4 texColor = texture2D(ColorMap, texCoord); // texture Color	
	float luma = dot(color.rgb * texColor.rgb, LUMA);
	
	vec3 originColor = color.rgb * texColor.rgb; // originalColor
	vec3 hdrColor = originColor + originColor * vec3(luma) / (vec3(1.0) + vec3(luma));
	
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