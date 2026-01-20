// Optimized Full Body (with contour) with Breathing Effect
// Based on original by Ermac, optimized for GRAPHITE_V2.x

#version 110
precision mediump float; // Better performance on mobile GPUs

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

uniform sampler2D ColorMap;
uniform vec4 ColorMapSize;
uniform vec4 SpriteBorder;
uniform float TimeGame;
varying vec4 color;
varying vec2 texCoord;

// Configuration constants
const float OUTLINE_THICKNESS = 1.0;
const float SHARPEN_AMOUNT = 0.125;
const float BREATHE_RATE = 1.75;
const float BREATHE_INTENSITY = 0.6;
const float BREATHE_OFFSET = 0.15;
const float EDGE_THRESHOLD = 0.2;

// Optimized blur coefficients (5 samples instead of 9)
const float CENTER_WEIGHT = 0.4;
const float SIDE_WEIGHT = 0.15;

// LUMA Coefficients - CCIR 601
const vec3 LUMA = vec3(0.299, 0.587, 0.114);

// Breathing effect function
vec3 applyBreathingEffect(vec2 coord, vec3 inColor) {
    float v = (coord.y - SpriteBorder.y) / (SpriteBorder.y - SpriteBorder.w);
    v += mod(BREATHE_RATE * TimeGame, 2.0);
    v = abs(fract(v * 0.5) * 2.0 - 1.0); // Optimized wave calculation
    return inColor + (v * BREATHE_INTENSITY - BREATHE_OFFSET);
}

// Optimized blur function with border clamping
vec4 texBlurRGBA() {
    vec2 offset = OUTLINE_THICKNESS * vec2(ColorMapSize.z, ColorMapSize.w);
    vec2 clampedCoord = clamp(texCoord, SpriteBorder.xy, SpriteBorder.zw);
    
    vec4 sum = texture2D(ColorMap, clampedCoord) * CENTER_WEIGHT;
    sum += texture2D(ColorMap, vec2(clamp(texCoord.x - offset.x, SpriteBorder.x, SpriteBorder.z), clampedCoord.y)) * SIDE_WEIGHT;
    sum += texture2D(ColorMap, vec2(clamp(texCoord.x + offset.x, SpriteBorder.x, SpriteBorder.z), clampedCoord.y)) * SIDE_WEIGHT;
    sum += texture2D(ColorMap, vec2(clampedCoord.x, clamp(texCoord.y - offset.y, SpriteBorder.y, SpriteBorder.w))) * SIDE_WEIGHT;
    sum += texture2D(ColorMap, vec2(clampedCoord.x, clamp(texCoord.y + offset.y, SpriteBorder.y, SpriteBorder.w))) * SIDE_WEIGHT;
    
    return sum;
}

void main() {
    vec4 texColor = texture2D(ColorMap, texCoord);
    float luma = dot(texColor.rgb, LUMA);
    
    // Case A: Opaque texture
    if (texColor.a == 1.0) {
        vec4 texBlur = texBlurRGBA();
        vec3 sharpColor = color.rgb * (texColor.rgb * (1.0 + SHARPEN_AMOUNT) - texBlur.rgb * SHARPEN_AMOUNT);
        vec3 hdrColor = sharpColor * (1.0 + luma / (1.0 + luma));
        gl_FragColor.rgb = 2.0 * applyBreathingEffect(texCoord, hdrColor);
        gl_FragColor.a = 1.0;
    }
    // Case B: Semi-transparent with edge detection
    else if (texColor.a < 1.0 && texture2D(ColorMap, texCoord).a >= EDGE_THRESHOLD) {
        vec3 hdrColor = color.rgb * (1.0 + luma / (1.0 + luma));
        gl_FragColor.rgb = 2.0 * applyBreathingEffect(texCoord, hdrColor);
        gl_FragColor.a = 1.0;
    }
    // Case C: Default case
    else {
        gl_FragColor = texColor;
    }
}

#endif
//-------------------------------------------------------