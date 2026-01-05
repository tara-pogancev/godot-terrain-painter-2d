shader_type canvas_item;

/* ========= TEXTURES ========= */
uniform sampler2D tex0;
uniform sampler2D tex1;

uniform sampler2D mask0;
uniform sampler2D mask1;

/* ========= SCALE ========= */
uniform float scale0 : hint_range(0.01, 10.0) = 1.0; // 1 = normal, <1 = more repeats, >1 = zoom in
uniform float scale1 : hint_range(0.01, 10.0) = 1.0;

/* ========= BASE TILING ========= */
uniform vec2 base_tile0 = vec2(1.0, 1.0);
uniform vec2 base_tile1 = vec2(1.0, 1.0);

/* ========= TEXTURE SIZE (for aspect ratio) ========= */
uniform vec2 tex0_size = vec2(256.0, 256.0);
uniform vec2 tex1_size = vec2(256.0, 256.0);

void fragment() {
    // Adjust tile counts by scale (scale >1 → zoom in → fewer repeats)
    vec2 tile0 = base_tile0 / scale0;
    vec2 tile1 = base_tile1 / scale1;

    // Keep texture aspect ratio
    tile0 *= tex0_size.y / tex0_size.x;
    tile1 *= tex1_size.y / tex1_size.x;

    // Scale UVs and repeat
    vec2 uv0 = fract(UV * tile0);
    vec2 uv1 = fract(UV * tile1);

    // Sample textures
    vec4 c0 = texture(tex0, uv0);
    vec4 c1 = texture(tex1, uv1);

    // Sample masks
    float m0 = texture(mask0, UV).r;
    float m1 = texture(mask1, UV).r;

    // Blend by mask
    float total = m0 + m1 + 0.0001;
    COLOR = (c0 * m0 + c1 * m1) / total;
}