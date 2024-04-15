varying vec4 v_vColour;
varying vec2 v_vTexcoord;

int palette = 7;
float gamma = 0.5;
uniform float width;
uniform float height;

void main()
{
    mat4 ditherMat1 = mat4(
        0.0, 32.0, 8.0, 40.0,
        48.0, 16.0, 56.0, 24.0,
        12.0, 44.0, 4.0, 36.0,
        60.0, 28.0, 52.0, 20.0
    );
    mat4 ditherMat2 = mat4(
        2.0, 34.0, 10.0, 42.0,
        50.0, 18.0, 58.0, 26.0,
        14.0, 46.0, 6.0, 38.0,
        62.0, 30.0, 54.0, 22.0
    );
    mat4 ditherMat3 = mat4(
        3.0, 35.0, 11.0, 43.0,
        51.0, 19.0, 59.0, 27.0,
        15.0, 47.0, 7.0, 39.0,
        63.0, 31.0, 55.0, 23.0
    );
    mat4 ditherMat4 = mat4(
        1.0, 33.0, 9.0, 41.0,
        49.0, 17.0, 57.0, 25.0,
        13.0, 45.0, 5.0, 37.0,
        61.0, 29.0, 53.0, 21.0
    );

    vec2 pTex = vec2(floor(v_vTexcoord.x * width), floor(v_vTexcoord.y * height));

    float dither = 0.;
    float ditherStrength = 0.018;

    if(mod(floor(pTex.x), 8.) <= 3.)
    {
        if(mod(floor(pTex.y), 8.) <= 3.)
        {
            dither = (ditherMat1[int(mod(floor(pTex.x), 4.))][int(mod(floor(pTex.y), 4.))] * 0.03125 - 0.5) * ditherStrength;
        }
        else
        {
            dither = (ditherMat2[int(mod(floor(pTex.x), 4.))][int(mod(floor(pTex.y), 4.))] * 0.03125 - 0.5) * ditherStrength;
        }
    }
    else
    {
        if(mod(floor(pTex.y), 8.) <= 3.)
        {
            dither = (ditherMat3[int(mod(floor(pTex.x), 4.))][int(mod(floor(pTex.y), 4.))] * 0.03125 - 0.5) * ditherStrength;
        }
        else
        {
            dither = (ditherMat4[int(mod(floor(pTex.x), 4.))][int(mod(floor(pTex.y), 4.))] * 0.03125 - 0.5) * ditherStrength;
        }
    }

    vec3 c = (texture2D( gm_BaseTexture, v_vTexcoord ) * v_vColour).rgb;
    float a = (texture2D( gm_BaseTexture, v_vTexcoord )).a;
    c.r = pow(abs(c.r + dither),gamma);
    c.g = pow(abs(c.g + dither),gamma);
    c.b = pow(abs(c.b + dither),gamma);

    vec3 col1 = vec3(1.);
    vec3 col2 = vec3(1.);
    vec3 col3 = vec3(1.);
    vec3 col4 = vec3(1.);

    if(palette == 0) {
        col1 = vec3(0.0,0.0,1.0);
        col2 = vec3(1.0,0.0,1.0);
        col3 = vec3(0.0,1.0,0.0);
        col4 = vec3(1.0,1.0,0.0);
    }
    if(palette == 1) {
        col1 = vec3(0.0);
        col2 = vec3(0.0,0.666,0.666);
        col3 = vec3(0.666,0.0,0.666);
        col4 = vec3(0.666,0.666,0.666);
    }
    if(palette == 2) {
        col1 = vec3(0.0);
        col2 = vec3(1.0,0.333,1.0);
        col3 = vec3(0.333,1.0,1.0);
        col4 = vec3(1.0);
    }
    if(palette == 3) {
        col1 = vec3(0.0);
        col2 = vec3(0.0,0.666,0.0);
        col3 = vec3(0.666,0.0,0.0);
        col4 = vec3(0.666,0.333,0.0);
    }
    if(palette == 4) {
        col1 = vec3(0.0);
        col2 = vec3(0.333,1.0,0.333);
        col3 = vec3(1.0,0.333,0.333);
        col4 = vec3(1.0,1.0,0.333);
    }
    if(palette == 5) {
        col1 = vec3(0.0);
        col2 = vec3(0.3764705);
        col3 = vec3(0.5686274);
        col4 = vec3(0.8984375);
    }
    if(palette == 6) {
        col1 = vec3(0.0);
        col2 = vec3(0.0,0.333,0.333);
        col3 = vec3(1.0,0.333,0.333);
        col4 = vec3(1.0);
    }
    if(palette == 7) {
        col1 = vec3(0.0);
        col2 = vec3(0.035,0.211,0.4);
        col3 = vec3(1.0,0.0,0.0);
        col4 = vec3(1.0);
    }

    float lum = (0.2126 * c.r) + (0.7152 * c.g) + (0.0722 * c.b);

    int index = int(floor(lum * 4. + 0.5));

    if(c != col1 && c != col2 && c != col3 && c != col4)
    {
        if(index == 0) {
            c = col1;
        }
        else if(index == 1) {
            c = col2;
        }
        else if(index == 2) {
            c = col3;
        }
        else {
            c = col4;
        }
    }

    gl_FragColor = vec4(c, floor(a + 0.5));
}
