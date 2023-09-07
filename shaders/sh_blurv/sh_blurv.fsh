varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// thank you shadertoy
// original shader: https://www.shadertoy.com/view/Mtl3Rj (made by Loadus)

float SCurve(float x)
{
    x = x * 2.0 - 1.0;
	return -x * abs(x) * 0.5 + x + 0.5;
}

vec4 BlurV (float radius)
{
	if (radius >= 1.0)
	{
		vec4 A = vec4(0.0);
		vec4 C = vec4(0.0);

		float divisor = 0.0;
        float weight = 0.0;

        float width = 1.0 / 180.0;

        float radiusMultiplier = 1.0 / radius;

        // Hardcoded for radius 20 (normally we input the radius
        // in there), needs to be literal here

		for (float x = -ceil(radius); x <= floor(radius); x++)
		{
            A = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.0, x * width) );

            weight = SCurve(1.0 - (abs(x) * radiusMultiplier));

            C += A * weight;

			divisor += weight;
		}

		return vec4(C.rgb / divisor, 1.0);
	}
    else
    {
	    return texture2D( gm_BaseTexture, v_vTexcoord );
    }
}

void main()
{
    gl_FragColor = v_vColour * BlurV(20.0);
}
