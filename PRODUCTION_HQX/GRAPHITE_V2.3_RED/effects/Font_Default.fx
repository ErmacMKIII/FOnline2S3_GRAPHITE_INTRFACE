//
// FOnline default effect
// For font sprites
//
// Review 2022-01-29 for GRAPHITE_V2.x

#include "IOStructures.inc"

sampler2D ColorMap;

// LUMA Coefficients
const float3 LUMA = float3(0.2126f, 0.7152f, 0.0722f);

// Vertex shader
AppToVsToPs_2D VSSimple(AppToVsToPs_2D input)
{
	// Just pass forward
	return input;
}


// Pixel shader
float4 PSSimple(AppToVsToPs_2D input) : COLOR
{
	float4 output;

	// Sample
	float4 texColor = tex2D(ColorMap, input.TexCoord);
	
	// sample color (which would be default)
	float3 scolor =  input.Diffuse.rgb * texColor.rgb;
	float luma = dot(scolor, LUMA);
		
	// HDR Version	
	output.rgb = scolor + scolor * float3(luma, luma, luma) / (float3(1.0f, 1.0f, 1.0f) + float3(luma, luma, luma));
	output.rgb *= 2.0f;
	
	output.a = texColor.a * input.Diffuse.a;

	return output;
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

