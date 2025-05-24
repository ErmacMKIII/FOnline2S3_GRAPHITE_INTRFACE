#include "IOStructures.inc"

static const float SPEC = 80.0f / 255.0f;
static const float3 WHITE = float3(1.0f);

AppToVsToPs_2DPrimitive VSSimple(AppToVsToPs_2DPrimitive input)
{
    return input;
}

float4 PSSimple(AppToVsToPs_2DPrimitive input) : COLOR
{
    float4 output = input.Diffuse;
    
    // Weapon range (red) or sight range (green)
    if ((input.Diffuse.rg == float2(1.0f, 0.0f) || input.Diffuse.rg == float2(0.0f, 1.0f)) 
        && input.Diffuse.b == 0.0f) 
    {
        output.rgb = WHITE - input.Diffuse.rgb;
        if (input.Diffuse.a == SPEC) output.a = 1.0f;
    }
    // Fog of War
    else if (input.Diffuse.rgb == float3(0.0f) && input.Diffuse.a == SPEC) 
    {
        output.rgb = SPEC * 0.5f;
        output.a = SPEC * 2.0f;
    }
    
    return output;
}

technique Simple
{
    pass p0
    {
        VertexShader = compile vs_2_0 VSSimple();
        PixelShader = compile ps_2_0 PSSimple();
    }
}