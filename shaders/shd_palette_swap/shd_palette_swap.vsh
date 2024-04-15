//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec4 v_vColour;
varying vec2 v_vTexcoord;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

    vec3 light = vec3(-2.6, -5.9, 2.6);

    vec3 lightDot = vec3(max(dot(in_Normal, normalize(light)), 0.1));

    v_vColour = in_Colour * vec4(lightDot, 1.0);
    v_vTexcoord = in_TextureCoord;
}
