// Optimized Fonts Effects Shader
// Based on original by Ermac, optimized for GRAPHITE_V2.x

#version 110

// Set medium precision for better performance on mobile GPUs
precision mediump float;

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
varying vec4 color;
varying vec2 texCoord;

// Define effect toggles (comment/uncomment as needed)
#define USE_SHARPEN
#define USE_HDR

const float AMOUNT = 0.125; // Sharpening amount

// Optimized 5-sample blur coefficients
const float CENTER_WEIGHT = 0.4;
const float SIDE_WEIGHT = 0.15;

// LUMA Coefficients - CCIR 601 
const vec3 LUMA = vec3(0.299, 0.587, 0.114);

// Pre-calculate texture offset
#define OFFSET vec2(ColorMapSize.z, ColorMapSize.w)

// Optimized blur function (5 samples instead of 9)
vec4 texBlurRGBA() {
    vec4 sum = texture2D(ColorMap, texCoord) * CENTER_WEIGHT;
    sum += texture2D(ColorMap, texCoord + vec2(-OFFSET.x, 0.0)) * SIDE_WEIGHT;
    sum += texture2D(ColorMap, texCoord + vec2(OFFSET.x, 0.0)) * SIDE_WEIGHT;
    sum += texture2D(ColorMap, texCoord + vec2(0.0, -OFFSET.y)) * SIDE_WEIGHT;
    sum += texture2D(ColorMap, texCoord + vec2(0.0, OFFSET.y)) * SIDE_WEIGHT;
    return sum;
}

void main() {
    vec4 texColor = texture2D(ColorMap, texCoord);
    
    #ifdef USE_SHARPEN
        vec4 texBlur = texBlurRGBA();
        // Optimized sharpening calculation
        vec3 shpColor = texColor.rgb * (1.0 + AMOUNT) - (texBlur.rgb * AMOUNT);
        shpColor *= color.rgb;
    #else
        vec3 shpColor = color.rgb * texColor.rgb;
    #endif
    
    #ifdef USE_HDR
        float luma = dot(shpColor, LUMA);
        vec3 hdrColor = shpColor + shpColor * vec3(luma) / (vec3(1.0) + vec3(luma));
        gl_FragColor.rgb = 2.0 * hdrColor;
    #else
        gl_FragColor.rgb = shpColor * 2.0;
    #endif
    
    gl_FragColor.a = color.a * texColor.a;
}

#endif
//-------------------------------------------------------