#version 110
precision mediump float;

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

varying vec4 color;
const float SPEC = 80.0 / 255.0;
const vec3 WHITE = vec3(1.0);

void main() {
    // Default case
    gl_FragColor = color;
    
    // Weapon range (red) or sight range (green)
    if ((color.rg == vec2(1.0, 0.0) || color.rg == vec2(0.0, 1.0)) && color.b == 0.0) {
        gl_FragColor.rgb = WHITE - color.rgb;
        if (color.a == SPEC) gl_FragColor.a = 1.0;
    }
    // Fog of War
    else if (color.rgb == vec3(0.0) && color.a == SPEC) {
        gl_FragColor.rgb = vec3(SPEC * 0.5);
        gl_FragColor.a = SPEC * 2.0;
    }
}

#endif
//-------------------------------------------------------