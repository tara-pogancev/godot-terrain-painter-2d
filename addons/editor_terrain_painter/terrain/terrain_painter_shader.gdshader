shader_type canvas_item;

/* ========= TEXTURES ========= */
uniform sampler2D tex0;
uniform sampler2D tex1;

uniform sampler2D mask0;
uniform sampler2D mask1;

void fragment() {
    // Sample the textures using UVs
    vec4 c0 = texture(tex0, UV);
    vec4 c1 = texture(tex1, UV);

    // Sample the masks
    float m0 = texture(mask0, UV).r;
    float m1 = texture(mask1, UV).r;

    // Blend textures by mask
    float total = m0 + m1 + 0.0001; // avoid divide by zero
    COLOR = (c0 * m0 + c1 * m1) / total;
}
