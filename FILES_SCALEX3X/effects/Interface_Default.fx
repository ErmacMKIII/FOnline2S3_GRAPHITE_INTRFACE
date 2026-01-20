//
// Optimized FOnline Default Effect
// For interface sprites
// Based on original, optimized for GRAPHITE_V2.x
//

#include "IOStructures.inc"

sampler2D ColorMap;

// Constants
static const float3 LUMA = float3(0.299f, 0.587f, 0.114f);
static const float CONTRAST_BOOST = 2.0f;

// Vertex shader - simplified
AppToVsToPs_2D VSSimple(AppToVsToPs_2D input)
{
    // Just pass through all data
    return input;
}

// Optimized Pixel shader
float4 PSSimple(AppToVsToPs_2D input) : COLOR
{
    // Sample texture once
    float4 texColor = tex2D(ColorMap, input.TexCoord);
    
    // Calculate base color
    float3 baseColor = input.Diffuse.rgb * texColor.rgb;
    
    // Optimized HDR calculation
    float luma = dot(baseColor, LUMA);
    float3 hdrColor = baseColor * (1.0f + luma / (1.0f + luma));
    
    // Prepare output
    float4 output;
    output.rgb = hdrColor * CONTRAST_BOOST;
    output.a = texColor.a * input.Diffuse.a;
    
    return output;
}

// Techniques - unchanged but more readable
technique Simple
{
    pass p0
    {
        VertexShader = compile vs_2_0 VSSimple();
        PixelShader  = compile ps_2_0 PSSimple();
    }
}