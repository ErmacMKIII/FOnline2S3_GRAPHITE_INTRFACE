//
// FOnline Sprite Effect with Egg Transparency (ps_2_0 compatible)
// Optimized for GRAPHITE_V2.x
//

#include "IOStructures.inc"

sampler2D ColorMap;
sampler2D EggMap;

// Constants
static const float3 LUMA = float3(0.299f, 0.587f, 0.114f);
static const float CONTRAST_BOOST = 2.0f;
static const float EGG_THRESHOLD = 0.001f; // Added small epsilon for safety

// Vertex shader remains unchanged
AppToVsToPs_2DEgg VSSimple(AppToVsToPs_2DEgg input)
{
    return input;
}

// Pixel shader (ps_2_0 compatible)
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
    
    // Handle alpha - using lerp instead of branch
    float4 eggSample = tex2D(EggMap, input.TexEggCoord);
    float hasEgg = step(EGG_THRESHOLD, max(abs(input.TexEggCoord.x), abs(input.TexEggCoord.y)));
    float alpha = texColor.a * input.Diffuse.a * lerp(1.0f, eggSample.a, hasEgg);
    
    // Compose final output
    return float4(finalColor, alpha);
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