shader_type canvas_item;

uniform sampler2D tex0;   // grass texture
uniform sampler2D tex1;   // stone texture

uniform sampler2D mask0;  // grass mask
uniform sampler2D mask1;  // stone mask

void fragment() {
    vec4 base = texture(tex0, UV);
    vec4 overlay = texture(tex1, UV);

    float m = texture(mask1, UV).r;

    COLOR = mix(base, overlay, m);
}