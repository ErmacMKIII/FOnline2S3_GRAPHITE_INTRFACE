//
// FOnline default effect
// For primitives (light, mini-map, pip-boy maps, etc)
//

#include "IOStructures.inc"


// Vertex shader
AppToVsToPs_2DPrimitive VSSimple(AppToVsToPs_2DPrimitive input)
{
	// Just pass forward
	return input;
}


// Pixel shader *edited by Ermac* on 2019-03-28
const float SPEC = 80.0f / 255.0f; // is special const
const float3 WHITE = float3(1.0f, 1.0f, 1.0f); // is white RGB as a const
float4 PSSimple(AppToVsToPs_2DPrimitive input) : COLOR 
{
	// assumption is made that we're gonna keep the color
	float3 resCol = float3(input.Diffuse.r, input.Diffuse.g, input.Diffuse.b); // is result color	
	float resA = input.Diffuse.a; // is result alpha		
	
	// *this demonstrates both inverting the color of weapon and sight range	
	// and increasing it's line thickness*
	
	// A) in case it's red color for weapon range
    if(input.Diffuse.r == 1.0f && input.Diffuse.g == 0.0f && input.Diffuse.b == 0.0f) { 
        resCol = WHITE - resCol; // invert the color
        if (input.Diffuse.a == SPEC) { // increase the thickness
            resA = 1.0f;
        }
	// B) otherwise in case it's green color for sight range	
    } else if (input.Diffuse.r == 0.0f && input.Diffuse.g == 1.0f && input.Diffuse.b == 0.0f) {
        resCol = WHITE - resCol; // invert the color
        if (input.Diffuse.a == SPEC) { // increase the thickness
            resA = 1.0f;
        }
	// C) in case of Fog of War	
	} else if (input.Diffuse.r == 0.0f && input.Diffuse.g == 0.0f 
				&& input.Diffuse.b == 0.0f && input.Diffuse.a == SPEC) {
		resCol = float3(SPEC / 2.0f, SPEC / 2.0f, SPEC / 2.0f);
		resA = 2.0f * SPEC;
	}				
    return float4(resCol.r, resCol.g, resCol.b, resA);
}


// Techniques
technique Simple
{
	pass p0
	{
		VertexShader = (compile vs_2_0 VSSimple());
		PixelShader  = (compile ps_2_0 PSSimple());
	}
}