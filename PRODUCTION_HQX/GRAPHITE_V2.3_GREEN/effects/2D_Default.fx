//
// FOnline default effect
// For sprites
//

#include "IOStructures.inc"

sampler2D ColorMap;
sampler2D EggMap;

const float3 LUMA = float3(0.2126f, 0.7152f, 0.0722f);

// Vertex shader
AppToVsToPs_2DEgg VSSimple(AppToVsToPs_2DEgg input)
{
	// Just pass forward
	return input;
}


// Pixel shader
float4 PSSimple(AppToVsToPs_2DEgg input) : COLOR
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

	// Egg transparent
	if (input.TexEggCoord.x != 0.0f || input.TexEggCoord.y != 0.0f) {
		output.a *= tex2D(EggMap, input.TexEggCoord).a;
	}

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

