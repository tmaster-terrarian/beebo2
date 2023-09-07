varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// Gaussian screen blur fragment shader, 0 uniforms
// Original shader code: https://www.shadertoy.com/view/XdfGDH by mrharicot. Modified to work within GMS2.

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

void main()
{
    vec2 res = vec2(320.0, 180.0);
	vec3 c = texture2D(gm_BaseTexture, v_vTexcoord).rgb;

    // declare stuff
    const int mSize = 7; // BLUR RADIUS IN PIXELS - MUST BE AN ODD NUMBER
    const int kSize = (mSize-1)/2;
    float kernel[mSize];
    vec3 final_colour = vec3(0.0);

    // create the 1-D kernel
    float sigma = 7.0;
    float Z = 0.0;
    for (int j = 0; j <= kSize; ++j)
    {
        kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
    }

    // get the normalization factor (as the gaussian has been clamped)
    for (int j = 0; j < mSize; ++j)
    {
        Z += kernel[j];
    }

    // read out the texels
    for (int i=-kSize; i <= kSize; ++i)
    {
        for (int j=-kSize; j <= kSize; ++j)
        {
            final_colour += kernel[kSize+j]*kernel[kSize+i]*texture2D(gm_BaseTexture, (v_vTexcoord + vec2(float(i),float(j)) / res.xy)).rgb;
        }
    }

    gl_FragColor = v_vColour * vec4(final_colour.rgb/(Z*Z), 1.0);
}
