//
// Optimized FOnline Sprite Effect with Egg Transparency
// Based on original, optimized for GRAPHITE_V2.x
//

#include "IOStructures.inc"

sampler2D ColorMap;
sampler2D EggMap;

// Constants
static const float3 LUMA = float3(0.299f, 0.587f, 0.114f);
static const float CONTRAST_BOOST = 2.0f;
static const float EGG_THRESHOLD = 0.0f; // For egg coord comparison

// Vertex shader - remains simple pass-through
AppToVsToPs_2DEgg VSSimple(AppToVsToPs_2DEgg input)
{
    return input;
}

// Optimized Pixel shader
float4 PSSimple(AppToVsToPs_2DEgg input) : COLOR
{
    // Sample main texture
    float4 texColor = tex2D(ColorMap, input.TexCoord);
    
    // Calculate base color with diffuse
    float3 baseColor = input.Diffuse.rgb * texColor.rgb;
    
    // Optimized HDR calculation
    float luma = dot(baseColor, LUMA);
    float lumaFactor = luma / (1.0f + luma);
    float3 finalColor = baseColor * (1.0f + lumaFactor) * CONTRAST_BOOST;
    
    // Handle alpha
    float alpha = texColor.a * input.Diffuse.a;
    
    // Egg transparency effect - optimized branch
    [branch]
    if (any(input.TexEggCoord != EGG_THRESHOLD)) {
        alpha *= tex2D(EggMap, input.TexEggCoord).a;
    }
    
    // Compose final output
    float4 output;
    output.rgb = finalColor;
    output.a = alpha;
    
    return output;
}

// Techniques
technique Simple
{
    pass p0
    {
        VertexShader = compile vs_2_0 VSSimple();
        PixelShader = compile ps_2_0 PSSimple();
    }
}