#include "IOStructures.inc"

static const float SPEC = 80.0f / 255.0f;
static const float3 WHITE = float3(1.0f, 1.0f, 1.0f); // Fixed constructor

AppToVsToPs_2DPrimitive VSSimple(AppToVsToPs_2DPrimitive input)
{
    return input;
}

float4 PSSimple(AppToVsToPs_2DPrimitive input) : COLOR
{
    float4 output = input.Diffuse;
    
    // Calculate conditions without branching
    float isRed = step(0.99f, input.Diffuse.r) * step(input.Diffuse.g, 0.01f) * step(input.Diffuse.b, 0.01f);
    float isGreen = step(0.99f, input.Diffuse.g) * step(input.Diffuse.r, 0.01f) * step(input.Diffuse.b, 0.01f);
    float isFog = step(input.Diffuse.r + input.Diffuse.g + input.Diffuse.b, 0.01f) * 
                 step(abs(input.Diffuse.a - SPEC), 0.001f);
    
    // Weapon range (red) or sight range (green)
    float isWeaponOrSight = saturate(isRed + isGreen);
    output.rgb = lerp(output.rgb, WHITE - output.rgb, isWeaponOrSight);
    output.a = lerp(output.a, 1.0f, isWeaponOrSight * step(abs(input.Diffuse.a - SPEC), 0.001f));
    
    // Fog of War
    output.rgb = lerp(output.rgb, float3(SPEC * 0.5f, SPEC * 0.5f, SPEC * 0.5f), isFog);
    output.a = lerp(output.a, SPEC * 2.0f, isFog);
    
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